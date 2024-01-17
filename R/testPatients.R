#' `testPatients()` takes a file with patients in SQL format, pushes them into the blank CDM and performs the test.
#'
#' @param dbConnection database connection
#' @param functionsToTest the functions to test
#' @param createSchemaPerTest if a schema should be created per test
#' @param cdmDatabaseSchema cdm schema
#' @param cohortDatabaseSchema cohort schema
#' @param unitTestOutputFolder unit test output folder
#' @param user db username
#' @param password db pwd
#' @param dbms dbms name
#' @param dbname database name
#' @param server database server
#' @param port database port number
#' @param cdm_version cdm version number
#' @param outputFolder output folder
#'
#' @importFrom DatabaseConnector createConnectionDetails connect
#'
#' @return Study results in the specified folder
#' @export
testPatients <- function(dbConnection,
                         functionsToTest = NULL,
                         createSchemaPerTest = FALSE,
                         cdmDatabaseSchema = Sys.getenv("UT_CDM_SCHEMA"),
                         cohortDatabaseSchema = Sys.getenv("UT_COHORT_SCHEMA"),
                         unitTestOutputFolder = Sys.getenv("UT_TEST_CASES_RESULTS_LOCATION"),
                         user = Sys.getenv("UT_DB_USER"),
                         password = Sys.getenv("UT_DB_PASSWORD"),
                         dbms = Sys.getenv("UT_DBMS"),
                         dbname = Sys.getenv("UT_DB_NAME"),
                         server = Sys.getenv("UT_DB_SERVER"),
                         port = Sys.getenv("UT_DB_PORT"),
                         cdm_version = "5.4",
                         outputFolder = "results") {

  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                  server = paste0(server, "/", dbname),
                                                                  user = user,
                                                                  password = password,
                                                                  port = port)
  connection <- DatabaseConnector::connect(connectionDetails)

  if (dir.exists(unitTestOutputFolder)) {
    unlink(unitTestOutputFolder, recursive = TRUE)
  }
  dir.create(unitTestOutputFolder)

  pathToTestCaseSql <- proj_path("inst", "testCases", "sql")
  testCaseSql <- list.files(path = pathToTestCaseSql, pattern=".*.sql", include.dirs = FALSE)

  for (i in 1:length(testCaseSql)) {
    sql <- SqlRender::readSql(file.path(pathToTestCaseSql, testCaseSql[i]))
    sql <- SqlRender::render(sql = sql, cdm_database_schema = cdmDatabaseSchema)
    ParallelLogger::logInfo(testCaseSql[i])
    DatabaseConnector::executeSql(connection,
                                  sql,
                                  progressBar = T)
    databaseName <- tools::file_path_sans_ext(testCaseSql[i])

    if (createSchemaPerTest) {
      resultsSchema <- paste0(cohortDatabaseSchema, i)
      cdm <- CDMConnector::cdm_from_con(con = db,
                                        cdm_schema = cdmDatabaseSchema,
                                        write_schema = resultsSchema,
                                        cdm_version = cdm_version)

      # Drop any existing schemas that might interfere with running
      # these tests. For now check if the DB is PostgreSQL and drop the
      # results schemas
      if (tolower(attr(connection, "dbms")) == tolower("postgresql")) {
        sql <- paste0("drop schema if exists ", resultsSchema, " cascade;")
        DatabaseConnector::executeSql(connection,
                                      sql,
                                      progressBar = F)
      }

      # Create a schema for the results
      DatabaseConnector::executeSql(connection,
                                    paste0("CREATE SCHEMA ", resultsSchema, ";"),
                                    progressBar = TRUE)

      for (i in functionsToTest) {
        outputFolder <- file.path(unitTestOutputFolder, testCaseSql[i])
        eval(parse(text = i))
      }
    } else {
      resultsSchema <- cohortDatabaseSchema
      cdm <- CDMConnector::cdm_from_con(con = dbConnection,
                                        cdm_schema = cdmDatabaseSchema,
                                        write_schema = resultsSchema,
                                        cdm_version = cdm_version)
      # outputFolder <- file.path(outputFolder, tools::file_path_sans_ext(testCaseSql[i]))
      # dir.create(outputFolder)
      for (i in functionsToTest) {
        eval(parse(text = i))
      }
    }
  }
}


# Helper Functions ------------------
testCleanup <- function(tableList) {
  templateSql <- "TRUNCATE TABLE @cohort_database_schema.@table_name;\nDROP TABLE @cohort_database_schema.@table_name;\n"
  sql <- ""
  for (i in 1:length(tableList)) {
    sql <- paste(sql, SqlRender::render(sql=templateSql, table_name = tableList[i]), sep="\n")
  }
  return(sql)
}
