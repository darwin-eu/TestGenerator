#' Converts a sample of patients into Unit Testing Definition JSON file.
#'
#' @param filePath Path to the test patient data in Excel format. The Excel has sheets that represent tables from the OMOP-CDM, e.g. person, drug_exposure, condition_ocurrence, etc.
#' @param testName A name of the test population in character.
#' @param outputPath Path of the output file, if NULL, a folder will be created in the project folder inst/testCases.
#' @param cdmVersion cdm version, default "5.3".
#' @param extraTable Name of non-standard tables to be included in the test CDM.
#'
#' @return A JSON file with sample patients inside the project directory.
#'
#' @importFrom readxl read_excel excel_sheets
#' @importFrom jsonlite toJSON
#' @importFrom checkmate assertDirectoryExists assertCharacter assertFileExists assert
#' @importFrom glue glue
#' @import cli
#'
#' @examples
#' filePath <- system.file("extdata", "testPatientsRSV.xlsx", package = "TestGenerator")
#' readPatients(filePath = filePath, outputPath = tempdir())
#'
#' @export
readPatients <- function(filePath = NULL,
                         testName = "test",
                         outputPath = NULL,
                         cdmVersion = "5.4",
                         extraTable = FALSE) {

  checkmate::assertFileExists(filePath)
  fileExtension <- tools::file_ext(filePath)
  checkmate::assertTRUE(fileExtension %in% c("csv", "xlsx"))

  if (fileExtension == "csv") {
    readPatients.csv(filePath = filePath,
                     testName = testName,
                     outputPath = outputPath,
                     cdmVersion = cdmVersion)
  } else {
    readPatients.xl(filePath = filePath,
                    testName = testName,
                    outputPath = outputPath,
                    cdmVersion = cdmVersion,
                    extraTable = extraTable)
  }
}

#' Converts a sample of patients in XLSX format into Unit Testing Definition JSON file.
#'
#' @param filePath Path to the test patient data in Excel format. The Excel has sheets that represent tables from the OMOP-CDM, e.g. person, drug_exposure, condition_ocurrence, etc.
#' @param testName A name of the test population in character.
#' @param outputPath Path to write the test JSON files. If NULL, the files will be written at the project's testthat folder, i.e. tests/testthat/testCases.
#' @param cdmVersion cdm version, default "5.3".
#' @param extraTable TRUE or FALSE. If TRUE, non-standard tables will be included in the test CDM.
#'
#' @return A directory with the test JSON files with sample patients inside the project directory.
#'
#' @importFrom readxl read_excel excel_sheets
#' @importFrom jsonlite toJSON
#' @importFrom checkmate assertDirectoryExists assertCharacter assertFileExists assert
#' @importFrom testthat test_path
#' @importFrom glue glue
#' @import cli
#'
#' @examples
#' filePath <- system.file("extdata", "testPatientsRSV.xlsx", package = "TestGenerator")
#' readPatients.xl(filePath = filePath, outputPath = tempdir())
#'
#' @export
readPatients.xl <- function(filePath = NULL,
                            testName = "test",
                            outputPath = NULL,
                            cdmVersion = "5.3",
                            extraTable = FALSE) {

  checkmate::assertCharacter(filePath)
  checkmate::assertFileExists(filePath)

  # Check columns

  cdmTables <- checkTablesColumns(cdmVersion, filePath, extraTable)


  # Convert to JSON
  testCaseFile <- jsonlite::toJSON(cdmTables,
                                   dataframe = "rows",
                                   pretty = TRUE)

  # Create testPath folder
  testPath <- createOutputFolder(outputPath, testName)

  # Write file
  write(testCaseFile, file = testPath)
  if (checkmate::checkFileExists(testPath)) {
    cli::cli_alert_success(glue::glue("Unit Test Definition Created Successfully: '{testName}'"))
  } else {
    cli::cli_alert_danger("Unit Test Definition Creation Failed")
    stop()
  }
}

#' Converts a sample of patients in CSV format into a Unit Testing Definition JSON file.
#'
#' @param filePath Path to the test patient data in CSV format. Multiple CSV files representing tables tables from the OMOP-CDM must be provided, e.g. person.csv, drug_exposure.csv, condition_ocurrence.csv, etc.
#' @param testName Name for the test population file in character.
#' @param outputPath Path of the output file, if NULL, a folder will be created in the project folder inst/testCases.
#' @param cdmVersion cdm version, default "5.3".
#' @param reduceLargeIds Reduces the length of very long ids generally in int64 format, such as those found in the MIMIC-IV database.
#'
#' @return A JSON file with sample patients inside the project directory.
#'
#' @importFrom readr read_csv
#' @importFrom jsonlite toJSON
#' @importFrom checkmate assertDirectoryExists assertCharacter assertFileExists assert
#' @importFrom glue glue
#' @importFrom tools file_path_sans_ext
#' @import cli
#'
#' @examples
#' filePath <- system.file("extdata", "mimic_sample", package = "TestGenerator")
#' readPatients.csv(filePath = filePath, outputPath = tempdir())
#'
#' @export
readPatients.csv <- function(filePath = NULL,
                             testName = "test",
                             outputPath = NULL,
                             cdmVersion = "5.4",
                             reduceLargeIds = FALSE) {

  checkmate::assertDirectoryExists(filePath)
  checkmate::assertCharacter(cdmVersion)
  checkmate::assertTRUE(cdmVersion %in% c("5.3", "5.4"))

  # Check column
  cdmTables <- fileColumnCheck(filePath, cdmVersion)

  if (reduceLargeIds) {
    cdmTables <- convertIds(cdmTables)
  }

  # Convert to JSON
  testCaseFile <- jsonlite::toJSON(cdmTables,
                                   dataframe = "rows",
                                   pretty = TRUE)

  # Create testPath folder
  testPath <- createOutputFolder(outputPath, testName)

  # Write file
  write(testCaseFile, file = testPath)
  if (checkmate::checkFileExists(testPath)) {
    cli::cli_alert_success(glue::glue("Unit Test Definition Created Successfully: '{testName}'"))
  } else {
    cli::cli_alert_danger("Unit Test Definition Creation Failed")
    stop()
  }
}

#' Check if the given tables and columns are valid and return the loaded data.
#'
#' @param cdmVersion cdm version
#' @param filePath Path to the test patient data in xlsx format
#' @param extraTable if extra tables are provided or not, default FALSE
#'
#' @return a named list containing the loaded data
checkTablesColumns <- function(cdmVersion, filePath, extraTable = FALSE) {
  checkmate::assertFileExists(filePath)

  patientTables <- readxl::excel_sheets(filePath)

  expectedTables <- spec_cdm_field[[cdmVersion]] %>%
    dplyr::pull(cdmTableName) %>%
    unique()

  if (extraTable) {
    if (!all(patientTables %in% unique(expectedTables))) {
      nonStandardTables <- setdiff(tolower(patientTables), expectedTables)
      cli::cli_alert_success(glue::glue("All tables are valid. Non-standard table(s) in test data: {glue::glue_collapse(nonStandardTables, sep = ', ', last = ' and ')}"))
    }
  } else {
    invalidTables <- setdiff(tolower(patientTables), expectedTables)
    if (invalidTables %>% length() > 0) {
      cli::cli_alert_danger(glue::glue("The following tables are invalid: {glue::glue_collapse(invalidTables, sep = ', ', last = ' and ')}"))
      stop()
    } else {
      cli::cli_alert_success(glue::glue("All tables are valid"))
    }
  }
  cdmTables <- lapply(patientTables,
                      readxl::read_excel,
                      path = filePath,
                      .name_repair = tolower) # cast column names to lowercase
  names(cdmTables) <- tolower(patientTables)

  return(cdmTables)
}

fileColumnCheck <- function(filePath, cdmVersion) {
  checkmate::assertDirectoryExists(filePath)
  checkmate::assertCharacter(cdmVersion)
  checkmate::assertTRUE(cdmVersion %in% c("5.3", "5.4"))
  csvFiles <- list.files(filePath, pattern = ".csv", full.names = TRUE)
  csvFilesNames <- list.files(filePath, pattern = ".csv")
  checkmate::assertCharacter(csvFiles, any.missing = FALSE, min.len = 1)
  checkmate::assertCharacter(csvFilesNames, any.missing = FALSE, min.len = 1)
  currentTables <- spec_cdm_field[[cdmVersion]] %>%
    dplyr::pull(cdmTableName) %>%
    unique()
  patientTables <- list()
  report <- list()
  for (i in 1:length(csvFiles)) {
    tableName <- tools::file_path_sans_ext(csvFilesNames[i])
    if (tableName %in% currentTables) {
      cdmTable <- readr::read_csv(csvFiles[i], show_col_types = FALSE)
      if (nrow(cdmTable) != 0) {
        names(cdmTable) <- tolower(names(cdmTable))
        currentCoulumns <- names(cdmTable)
        expectedColumns <- spec_cdm_field[[cdmVersion]] %>%
          dplyr::filter(cdmTableName == tableName) %>%
          dplyr::pull(cdmFieldName)
        expectedColumns <- gsub("\"", "", expectedColumns)
        if (all(currentCoulumns %in% expectedColumns)) {
          patientTables[[tableName]] <- cdmTable
        } else {
          cli::cli_alert_danger(glue::glue("'{tableName}' table columns do not match"))
          stop()
        }
      } else {
        report[["empty"]] <- append(report[["empty"]], glue::glue("{tableName}"))
      }
    }
  }
  if (!is.null(report[['empty']])) {
    empty <- paste(report[['empty']], collapse = ", ")
    cli::cli_alert_warning("Empty Tables Found:")
    cli::cli_text(empty)
  }
  names(patientTables) <- tolower(names(patientTables))
  return(patientTables)
}

convertIds <- function(cdmTables) {
  report <- list()
  for (tables in names(cdmTables)) {
    # tables <- "vocabulary"
    for (columns in names(cdmTables[[tables]])) {
      # columns <- "vocabulary_concept_id"
      if (columns %in% c("person_id",
                         "care_site_id",
                         "condition_era_id",
                         "condition_occurrence_id",
                         "device_exposure_id",
                         "visit_occurrence_id",
                         "dose_era_id",
                         "drug_era_id",
                         "drug_exposure_id",
                         "fact_id_1",
                         "fact_id_2",
                         "measurement_id",
                         "observation_id",
                         "observation_period_id",
                         "procedure_occurrence_id",
                         "specimen_id",
                         "visit_detail_id",
                         "preceding_visit_detail_id",
                         "preceding_visit_occurrence_id",
                         "vocabulary_concept_id")) {

        uniqueIdValues <- unique(cdmTables[[tables]][[columns]])
        idValues <- abs(cdmTables[[tables]][[columns]]) %>%
          abs() %>%
          format(scientific = FALSE, trim = TRUE) %>%
          substr(1, 9) %>%
          as.numeric()

        if (length(unique(idValues)) != length(unique(uniqueIdValues))) {
          if(!tables %in% c("person_id", "visit_occurrence_id", "condition_occurrence_id")) {
            cdmTables[[tables]][[columns]] <- seq(1, length(uniqueIdValues))
            report[["notUnique"]] <- append(report[["notUnique"]], glue::glue("{tables}"))
            # message(glue::glue("'{tables}' table with '{columns}' ids are not unique"))
            # message(glue::glue("'{tables}' table filled out with sequence of numbers"))
          } else {
            cli::cli_alert_danger(glue::glue("'{tables}' table with '{columns}' ids are not unique and couldn't fill with num sequence"))
            stop()
          }
        } else {
          cdmTables[[tables]][[columns]] <- idValues
          # report[["reduced"]] <- append(report[["reduced"]], glue::glue("{tables}"))
          # message(glue::glue("'{tables}' table and '{columns}' ids reduced succesfully"))
        }
      }
    }
  }
  if (!is.null(report[['notUnique']])) {
    notUnique <- paste(report[['notUnique']], collapse = ", ")
    cli::cli_alert_warning("Table with non unique ids and filled with num seq:")
    cli::cli_text(notUnique)
  }
  cli::cli_alert_success("IDs successfully reduced")
  # reduced <- paste(report[['reduced']], collapse = ", ")
  # cli::cli_text(reduced)
  return(cdmTables)
}

createOutputFolder <- function(outputPath, testName) {
  if (is.null(outputPath)) {
    testFolder <- testthat::test_path("testCases")
    if (!dir.exists(testFolder)) {
      dir.create(testFolder)
      testPath <- paste0(testFolder, "/", testName, ".json")
    } else {
      testPath <- paste0(testFolder, "/", testName, ".json")
    }
  } else {
    checkmate::assertCharacter(outputPath)
    checkmate::assertDirectoryExists(outputPath)
    testPath <- paste0(outputPath, "/", testName, ".json")
  }
  return(testPath)
}

#' Pushes test population into a blank CDM.
#'
#' @param pathJson Directory where the sample populations in json are located. If NULL, gets the default inst/testCases directory.
#' @param testName Name of the sample population JSON file. If NULL it will push the first sample population in the testCases directory.
#' @param cdmVersion cdm version, default "5.3".
#' @param cdmName Name of the cdm, default NULL.
#' @param dbms Database management system to use. One of "duckdb", "spark",
#'   or "sqlserver". Default is "duckdb" which creates a local
#'   DuckDB CDM. For remote databases the function creates the CDM locally,
#'   trims the vocabulary, uploads to a new schema on the remote database,
#'   and returns the remote CDM reference. Remote databases require
#'   environment variables to be set. Call \code{usethis::edit_r_environ()}
#'   to set them.
#' @param writeSchema Optional schema name to use on the remote database.
#'   If NULL (default), a unique schema is created automatically. Only used
#'   when \code{dbms} is not "duckdb".
#'
#' @return A CDM reference object with a sample population.
#' @import dplyr cli
#' @importFrom DBI dbConnect dbAppendTable dbDisconnect dbExecute
#' @importFrom duckdb duckdb
#' @importFrom jsonlite fromJSON
#' @importFrom CDMConnector downloadEunomiaData eunomiaDir cdmFromCon
#' @importFrom omopgenerics insertTable
#'
#' @examples
#' \donttest{
#' filePath <- system.file("extdata", "testPatientsRSV.xlsx", package = "TestGenerator")
#' TestGenerator::readPatients(filePath = filePath, outputPath = tempdir())
#' cdm <- TestGenerator::patientsCDM(pathJson = tempdir(), testName = "test")
#' duckdb::duckdb_shutdown(duckdb::duckdb())
#' }
#' @export
patientsCDM <- function(pathJson = NULL,
                        testName = NULL,
                        cdmVersion = "5.4",
                        cdmName = NULL,
                        dbms = "duckdb",
                        writeSchema = NULL) {

  dbms <- match.arg(dbms, c("duckdb", "spark", "sqlserver"))

  if (dbms != "duckdb") {
    .check_remote_env_vars(dbms)
    return(.patientsCDM_remote(
      pathJson = pathJson,
      testName = testName,
      cdmVersion = cdmVersion,
      cdmName = cdmName,
      dbms = dbms,
      writeSchema = writeSchema
    ))
  }

  if (is.null(pathJson)) {
    outputFolder <- testthat::test_path("testCases")
    if (dir.exists(outputFolder)) {
      pathJson <- outputFolder
    } else {
      cli::cli_alert_danger("testCases not found")
      stop()
    }
  }

  checkmate::assertClass(pathJson, "character")
  checkmate::assertDirectoryExists(pathJson)

  if (identical(list.files(pathJson), character(0))) {
    cli::cli_alert_danger("Directory empty. Provide Unit Test Definitions")
    stop()
  }

  testFiles <- list.files(pathJson, pattern = ".json")

  if (is.null(testName)) {
    testName <- testFiles[1]
  } else {
    checkmate::checkClass(testName, "character")
    testName <- paste0(testName, ".json")
  }

  fileName <- file.path(pathJson, testName)
  checkmate::assertFileExists(fileName)

  # Folder to download empty CDM

  if (!dir.exists(Sys.getenv("EUNOMIA_DATA_FOLDER"))) {
    Sys.setenv(EUNOMIA_DATA_FOLDER = tempdir())
  }

  # Check/Download vocabulary

  vocabPath <- file.path(Sys.getenv("EUNOMIA_DATA_FOLDER"),
                         glue::glue("empty_cdm_{cdmVersion}.zip"))

  if (!file.exists(vocabPath)) {
    CDMConnector::downloadEunomiaData(datasetName = "empty_cdm",
                                      cdmVersion = cdmVersion,
                                      pathToData = Sys.getenv("EUNOMIA_DATA_FOLDER"),
                                      overwrite = TRUE)
  }

  conn <- DBI::dbConnect(duckdb::duckdb(CDMConnector::eunomiaDir(datasetName = "empty_cdm",
                                                                 cdmVersion = cdmVersion)))
  cdm <- CDMConnector::cdmFromCon(con = conn,
                                  cdmSchema = "main",
                                  writeSchema = "main",
                                  cdmName = cdmName,
                                  cdmVersion = cdmVersion)

  # Read the JSON file into R
  jsonData <- jsonlite::fromJSON(fileName)

  # Check for the expected tables in the CDM
  expectedTables <- spec_cdm_field[[cdmVersion]] %>%
    dplyr::pull(cdmTableName) %>%
    unique()

  currentTables <- names(jsonData)

  nonStandardTables <- setdiff(currentTables, expectedTables)

  if (length(nonStandardTables) > 0) {
    cli::cli_alert_danger(glue::glue("Non-standard table(s) in test data: {glue::glue_collapse(nonStandardTables, sep = ', ', last = ' and ')}"))
  }
  standardTables <- setdiff(currentTables, nonStandardTables)
  cli::cli_alert_success(glue::glue("Standard table(s) in test data: {glue::glue_collapse(standardTables, sep = ', ', last = ' and ')}"))


  # Check for the expected columns in the CDM
  for (tableName in standardTables) {
    classTable <- class(jsonData[[tableName]])
    if (classTable == "data.frame") {
      currentCoulumns <- names(jsonData[[tableName]])
      expectedColumns <- spec_cdm_field[[cdmVersion]] %>%
        dplyr::filter(cdmTableName == tableName) %>%
        dplyr::pull(cdmFieldName)
      jsonData[[tableName]] <- jsonData[[tableName]] %>%
        select(currentCoulumns[currentCoulumns %in% expectedColumns])
      patientData <- as.data.frame(jsonData[[tableName]])
      DBI::dbAppendTable(conn, tableName, patientData)
    }
  }

  for (tableName in nonStandardTables) {
    patientData <- as.data.frame(jsonData[[tableName]])
    cdm <- omopgenerics::insertTable(cdm,
                                     tableName,
                                     patientData,
                                     overwrite = TRUE,
                                     temporary = FALSE)
  }

  cli::cli_alert_success("Patients pushed to blank CDM successfully")
  return(cdm)
}

# Internal: create test CDM on a remote database
.patientsCDM_remote <- function(pathJson, testName, cdmVersion, cdmName, dbms, writeSchema = NULL) {

  n_steps <- 5L

  # ---- Step 1: Create local DuckDB CDM ----
  cli::cli_progress_step("Step 1/{n_steps}: Creating local DuckDB test CDM")
  local_cdm <- patientsCDM(
    pathJson = pathJson,
    testName = testName,
    cdmVersion = cdmVersion,
    cdmName = cdmName,
    dbms = "duckdb"
  )

  # Track the duckdb file path so we can clean it up later
  local_con <- CDMConnector::cdmCon(local_cdm)
  duckdb_path <- local_con@driver@dbdir

  # ---- Step 2: Trim vocabulary ----
  cli::cli_progress_step("Step 2/{n_steps}: Trimming vocabulary")
  local_cdm <- CDMConnector::cdmTrimVocabulary(local_cdm)

  # ---- Step 3: Connect to remote database and create schema ----
  remote_con <- .connect_remote(dbms)
  if (!is.null(writeSchema)) {
    cli::cli_progress_step("Step 3/{n_steps}: Connecting to {dbms} using schema {.val {writeSchema}}")
    test_schema <- writeSchema
  } else {
    cli::cli_progress_step("Step 3/{n_steps}: Connecting to {dbms} and creating test schema")
    test_schema <- .create_test_schema(remote_con, dbms)
    cli::cli_alert_info("Created test schema: {.val {paste(test_schema, collapse = '.')}}")
  }

  # ---- Step 4: Upload CDM to remote database ----
  cli::cli_progress_step("Step 4/{n_steps}: Uploading test CDM to {dbms}")
  cdm_remote <- CDMConnector::copyCdmTo(
    con = remote_con,
    cdm = local_cdm,
    schema = test_schema,
    overwrite = TRUE
  )
  attr(cdm_remote, "dbcon") <- remote_con

  # ---- Step 5: Clean up local DuckDB resources ----
  cli::cli_progress_step("Step 5/{n_steps}: Cleaning up local DuckDB files")
  DBI::dbDisconnect(local_con, shutdown = TRUE)

  # Remove duckdb file and any WAL files
  if (nzchar(duckdb_path) && file.exists(duckdb_path)) {
    unlink(duckdb_path)
    unlink(paste0(duckdb_path, ".wal"))
  }

  cli::cli_alert_success("Remote test CDM ready on {dbms}")
  return(cdm_remote)
}

# Internal: early check that required env vars are set before doing any work
.check_remote_env_vars <- function(dbms) {
  required_vars <- switch(dbms,
                          "sqlserver" = c(
                            "DARWIN_SQLSERVER_SERVER",
                            "DARWIN_SQLSERVER_DBNAME",
                            "DARWIN_SQLSERVER_PORT",
                            "DARWIN_SQLSERVER_USER",
                            "DARWIN_SQLSERVER_PASSWORD"
                          ),
                          "spark" = c(
                            "DATABRICKS_HOST",
                            "DATABRICKS_TOKEN",
                            "DATABRICKS_HTTPPATH"
                          )
  )
  .check_env_vars(required_vars, dbms)
}

# Internal: connect to a remote database using environment variables
.connect_remote <- function(dbms) {
  switch(dbms,
         "sqlserver" = .connect_sqlserver(),
         "spark" = .connect_spark(),
         cli::cli_abort("Unsupported dbms: {.val {dbms}}")
  )
}

.connect_sqlserver <- function() {
  required_vars <- c(
    "DARWIN_SQLSERVER_SERVER",
    "DARWIN_SQLSERVER_DBNAME",
    "DARWIN_SQLSERVER_PORT",
    "DARWIN_SQLSERVER_USER",
    "DARWIN_SQLSERVER_PASSWORD"
  )
  .check_env_vars(required_vars, "SQL Server")

  DBI::dbConnect(
    odbc::odbc(),
    Driver   = Sys.getenv("SQL_SERVER_DRIVER", "ODBC Driver 18 for SQL Server"),
    Server   = Sys.getenv("DARWIN_SQLSERVER_SERVER"),
    Database = Sys.getenv("DARWIN_SQLSERVER_DBNAME"),
    UID      = Sys.getenv("DARWIN_SQLSERVER_USER"),
    PWD      = Sys.getenv("DARWIN_SQLSERVER_PASSWORD"),
    TrustServerCertificate = "yes",
    Port     = Sys.getenv("DARWIN_SQLSERVER_PORT")
  )
}

.connect_spark <- function() {
  required_vars <- c(
    "DATABRICKS_HOST",
    "DATABRICKS_TOKEN",
    "DATABRICKS_HTTPPATH"
  )
  .check_env_vars(required_vars, "Databricks/Spark")

  DBI::dbConnect(
    odbc::databricks(),
    Host           = Sys.getenv("DATABRICKS_HOST"),
    AuthMech       = 3,
    HTTPPath       = Sys.getenv("DATABRICKS_HTTPPATH"),
    UID            = Sys.getenv("DATABRICKS_USER", "token"),
    PWD            = Sys.getenv("DATABRICKS_TOKEN"),
    useNativeQuery = FALSE,
    bigint         = "numeric"
  )
}

# Internal: check that required environment variables are set
.check_env_vars <- function(vars, label) {
  missing <- vars[!nzchar(Sys.getenv(vars))]
  if (length(missing) > 0) {
    bullets <- stats::setNames(missing, rep("*", length(missing)))
    cli::cli_abort(c(
      "Missing required environment variables for {label}:",
      bullets,
      "i" = "Set them in your {.file .Renviron} by running {.code usethis::edit_r_environ()}"
    ))
  }
}

# Internal: create a unique test schema on the remote database
.create_test_schema <- function(con, dbms) {
  schema_name <- paste0("testgenerator_", format(Sys.time(), "%Y%m%d_%H%M%S"), "_", sample(1000:9999, 1))

  switch(dbms,
         "sqlserver" = {
           DBI::dbExecute(con, paste("CREATE SCHEMA", schema_name))
           schema_name
         },
         "spark" = {
           catalog <- Sys.getenv("DATABRICKS_WORKSPACE", "hive_metastore")
           schema <- c(catalog = catalog, schema = schema_name)
           DBI::dbExecute(con, paste0(
             "CREATE SCHEMA IF NOT EXISTS ",
             paste(schema, collapse = ".")
           ))
           schema
         }
  )
}

#' Clean up a test CDM on a remote database
#'
#' Drops the schema containing the test CDM and disconnects from the database.
#'
#' @param cdm A CDM reference object created by \code{patientsCDM()} with a
#'   remote database backend.
#'
#' @return Invisibly returns NULL.
#' @export
cleanupTestCdm <- function(cdm) {
  con <- CDMConnector::cdmCon(cdm)
  schema <- CDMConnector::cdmWriteSchema(cdm)
  writeSchema <- paste(schema, collapse = ".")
  dbms_class <- class(con)

  if (!grepl("test_generator", writeSchema, ignore.case = TRUE)) {
    cli::cli_abort("Refusing to drop schema {.val {writeSchema}} because it does not contain {.val test_generator} in the name.")
  }

  if (any(grepl("OdbcConnection", dbms_class)) || any(grepl("Microsoft SQL Server", dbms_class))) {
    # SQL Server: drop all tables first, then drop schema
    tables <- CDMConnector::listTables(con, schema = schema)
    schema_name <- if (length(schema) == 1) schema else schema[length(schema)]
    for (tbl in tables) {
      tryCatch(
        DBI::dbExecute(con, paste0("DROP TABLE IF EXISTS ", schema_name, ".", tbl)),
        error = function(e) NULL
      )
    }
    DBI::dbExecute(con, paste("DROP SCHEMA", schema_name))
    cli::cli_alert_success("Dropped SQL Server schema: {.val {schema_name}}")
  } else if (any(grepl("Spark|databricks", dbms_class, ignore.case = TRUE))) {
    # Databricks/Spark
    schema_full <- paste(schema, collapse = ".")
    DBI::dbExecute(con, paste0("DROP SCHEMA IF EXISTS ", schema_full, " CASCADE"))
    cli::cli_alert_success("Dropped Spark schema: {.val {schema_full}}")
  } else {
    cli::cli_abort("Could not detect database type for cleanup. Connection class: {.val {paste(dbms_class, collapse = ', ')}}")
  }

  DBI::dbDisconnect(con)
  cli::cli_alert_success("Disconnected from remote database")
  invisible(NULL)
}
