#' `readPatients()` converts a sample of patients in XLSX format into Unit Testing Definition in JSON format.
#'
#' @param filePath Path to the test patient data in Excel format.
#' @param testName Name of the test population in character.
#' @param outputPath Path of the output file, iff NULL, a folder will be created in the project folder inst/testCases
#'
#' @return A JSON file for testing inside the project directory.
#'
#' @importFrom readxl read_excel excel_sheets
#' @importFrom jsonlite toJSON
#' @importFrom usethis use_directory
#' @importFrom fs path
#' @importFrom usethis proj_path
#' @importFrom checkmate assertDirectoryExists assertCharacter assertFileExists assert
#' @importFrom glue glue
#'
#' @export
readPatients <- function(filePath = NULL,
                         testName = "test",
                         outputPath = NULL) {

  # filePath <- here::here("extras", "testPatients.xlsx")
  checkmate::assertCharacter(filePath)
  checkmate::assertFileExists(filePath)

  sheets <- c("person",
              "observation_period",
              "drug_exposure",
              "condition_occurrence",
              "visit_occurrence",
              "visit_context",
              "visit_detail",
              "death")

  patientTables <- readxl::excel_sheets(filePath)
  checkmate::assert(all(patientTables %in% sheets))

  listPatientTables <- lapply(patientTables,
                              readxl::read_excel,
                              path = filePath)
  # names(listPatientTables) <- tolower(paste0("", patientTables))
  names(listPatientTables) <- tolower(patientTables)

  testCaseFile <- jsonlite::toJSON(listPatientTables,
                                   dataframe = "rows",
                                   pretty = TRUE)

  if (is.null(outputPath)) {
    usethis::use_directory(fs::path("inst", "testCases"))
    outputPath <- fs::path("inst", "testCases")
    testName <- paste0(outputPath, "/", testName, ".json")
  } else {
    checkmate::assertCharacter(outputPath)
    checkmate::assertDirectoryExists(outputPath)
    testName <- paste0(outputPath, "/", testName, ".json")
  }
  write(testCaseFile, file = testName)
  if (checkmate::checkFileExists(testName)) {
    message(glue::glue("Unit Test Definition created in {outputPath}"))
  } else {
    stop("Unit Test Definition creation failed")
  }
}

#' `patientCDM()` takes a file with patients in JSON format, pushes them into the blank CDM and performs the test.
#'
#' @param pathJson If NULL, takes the project path to create the SQL files.
#' @param testName Name of the Unit Test Definition, if NULL it will push the first sample population in the testCases directory.
#'
#' @return Study results in the specified folder
#' @import dplyr
#' @importFrom usethis proj_path
#' @importFrom duckdb duckdb
#' @importFrom jsonlite fromJSON
#' @export
cdmPatients <- function(pathJson = NULL,
                        testName = NULL) {

  if (is.null(pathJson)) {
    pathJson <- proj_path("inst", "testCases")
  }

  checkmate::assertClass(pathJson, "character")
  checkmate::assertDirectoryExists(pathJson)

  if (identical(list.files(pathJson), character(0))) {
    stop("Directory empty. Provide Unit Test Definitions")
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

  if ("empty_cdm" %in% CDMConnector::example_datasets()) {

    vocabPath <- file.path(Sys.getenv("EUNOMIA_DATA_FOLDER"), "empty_cdm_5.3.zip")

    if (!file.exists(vocabPath)) {
      CDMConnector::downloadEunomiaData(datasetName = "empty_cdm",
                                        cdmVersion = "5.3",
                                        pathToData = Sys.getenv("EUNOMIA_DATA_FOLDER"),
                                        overwrite = TRUE)
    }

    conn <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir("empty_cdm"))
    cdm <- CDMConnector::cdmFromCon(con = conn, cdmSchema = "main", writeSchema = "main")

  } else {

    # Get allergies 10K dataset
    vocabPath <- file.path(Sys.getenv("EUNOMIA_DATA_FOLDER"), "synthea-allergies-10k_5.3.zip")

    if (!file.exists(vocabPath)) {
      CDMConnector::downloadEunomiaData(datasetName = "synthea-allergies-10k")
    }

    # Empty CDM
    conn <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir("synthea-allergies-10k"))
    cdm <- CDMConnector::cdmFromCon(con = conn, cdmSchema = "main", writeSchema = "main")
    cdm <- emptyCDM(conn = conn, cdm = cdm)

  }

  # Read the JSON file into R
  jsonData <- jsonlite::fromJSON(fileName)
  # Check for the expected columns in the CDM
  for (tableName in names(jsonData)) {
    # tableName <- "visit_detail"
    currentCoulumns <- names(jsonData[[tableName]])
    expectedColumns <- spec_cdm_field[["5.3"]] %>%
      dplyr::filter(cdmTableName == tableName) %>%
      dplyr::pull(cdmFieldName)
    jsonData[[tableName]] <- jsonData[[tableName]] %>%
      select(currentCoulumns[currentCoulumns %in% expectedColumns])
    # for (column in expectedColumns) {
    #   if (!column %in% names(jsonData[[tableName]])) {
    #     jsonData[[tableName]][, column] <- NA
    #   }
    # }
  }

  # Convert the JSON data into a data frame and append it to the blank CDM
  for (tableName in names(jsonData)) {
    # tableName <- "visit_occurrence"
    patientData <- as.data.frame(jsonData[[tableName]])
    DBI::dbAppendTable(conn, tableName, patientData)
  }

  return(cdm)
}

#' `sqlPatients()` takes a file with patients in JSON format, pushes them into the blank CDM using DatabaseConnector.
#'
#' @param pathJson If NULL, takes the project path to create the SQL files
#'
#' @return Study results in the specified folder
#' @importFrom usethis proj_path
#' @importFrom SqlRender writeSql
#' @importFrom SqlRender render
#' @export
sqlPatients <- function(pathJson = NULL,
                        testName = NULL) {

  pathJson = NULL
  testName = NULL

  # Set project folder
  if (is.null(pathJson)) {
    pathJson <- usethis::proj_path("inst", "testCases")
  }

  # Checks
  checkmate::assertClass(pathJson, "character")
  checkmate::assertDirectoryExists(pathJson)

  # Clear any existing SQL file
  pathSQL <- file.path(pathJson, "sql")

  # Initialize the sql path
  # ! This will automatically remove sample patients SQL instructions
  if (dir.exists(pathSQL)) {
    unlink(pathSQL, recursive = TRUE)
  }
  dir.create(pathSQL)

  testFiles <- list.files(pathJson, pattern = ".json")

  if (is.null(testName)) {
    testName <- testFiles[1]
  } else {
    checkmate::checkClass(testName, "character")
    testName <- paste0(testName, ".json")
  }

  testCaseFile <- testName
  ParallelLogger::logInfo(paste("Creating SQL for", testCaseFile))

  # Read the JSON structure
  jsonData <- jsonlite::fromJSON(file.path(pathJson, testCaseFile))

  # jsonData <- jsonlite::read_json(file.path(pathJson, testCaseFile))

  # Check for the expected columns in the CDM
  for (tableName in names(jsonData)) {
    # tableName <- "person"
    currentCoulumns <- names(jsonData[[tableName]])
    expectedColumns <- spec_cdm_field[["5.3"]] %>%
      dplyr::filter(cdmTableName == tableName) %>%
      dplyr::pull(cdmFieldName)
    jsonData[[tableName]] <- jsonData[[tableName]] %>%
      select(currentCoulumns[currentCoulumns %in% expectedColumns])
    for (column in expectedColumns) {
      if (!column %in% names(jsonData[[tableName]])) {
        jsonData[[tableName]][, column] <- NA
      }
    }
  }

  # Initialze the test case
  sql <- initTestCase()
  # Person records
  if (!is.null(jsonData$person)) {
    for(p in 1:length(jsonData$person)) {
      sql <- paste(sql, createCdmPerson(jsonData$person[p,]), sep="\n")
    }
  }
  # Observation period records
  if (!is.null(jsonData$observation_period)) {
    for(p in 1:length(jsonData$observation_period)) {
      sql <- paste(sql, createCdmObservationPeriod(jsonData$observation_period[p,]), sep="\n")
    }
  }
  # Drug exposure records
  if (!is.null(jsonData$drug_exposure)) {
    for(p in 1:length(jsonData$drug_exposure)) {
      sql <- paste(sql, createCdmDrugExposure(jsonData$drug_exposure[p,]), sep="\n")
    }
  }
  # Condition occurrence records
  if (!is.null(jsonData$condition_occurrence)) {
    for(p in 1:length(jsonData$condition_occurrence)) {
      sql <- paste(sql, createCdmConditionOccurrence(jsonData$condition_occurrence[p,]), sep="\n")
    }
  }
  # Visit occurrence records
  if (!is.null(jsonData$visit_occurrence)) {
    for(p in 1:length(jsonData$visit_occurrence)) {
      sql <- paste(sql, createCdmVisitOccurrence(jsonData$visit_occurrence[p,]), sep="\n")
    }
  }
  # Visit detail records
  if (!is.null(jsonData$visit_detail)) {
    for(p in 1:length(jsonData$visit_detail)) {
      sql <- paste(sql, createCdmVisitDetail(jsonData$visit_detail[p,]), sep="\n")
    }
  }
  # Death records
  if (!is.null(jsonData$death)) {
    for(p in 1:length(jsonData$death)) {
      p <- 1
      sql <- paste(sql, createCdmDeath(jsonData$death[p,]), sep="\n")
    }
  }
  sqlFilePath <- file.path(pathJson, "sql", paste0(tools::file_path_sans_ext(testCaseFile), ".sql"))
  SqlRender::writeSql(sql, targetFile = sqlFilePath)
  if (file.exists(sqlFilePath)) {
    ParallelLogger::logInfo("SQL for ", testCaseFile, " successfully created")
  }
}

pushSQLpatients <- function(connection,
                            connectionDetails,
                            cdmDatabaseSchema,
                            pathSQL = NULL,
                            testName = NULL) {
  cdmDatabaseSchema = "main"
  pathSQL = NULL
  testName = NULL

  # Set project folder
  if (is.null(pathSQL)) {
    pathSQL <- proj_path("inst", "testCases", "sql")
  }

  # Checks
  checkmate::assertClass(pathSQL, "character")
  checkmate::assertDirectoryExists(pathSQL)

  testFiles <- list.files(path = pathSQL,
                          pattern = ".sql",
                          include.dirs = FALSE)

  if (is.null(testName)) {
    testName <- testFiles[1]
  } else {
    checkmate::checkClass(testName, "character")
    testName <- paste0(testName, ".sql")
  }

  sql <- SqlRender::readSql(file.path(pathSQL, testFiles))

  sql <- SqlRender::render(sql = sql, cdm_database_schema = cdmDatabaseSchema)
  ParallelLogger::logInfo("Pushing ", testName, " patients to cdm")
  DatabaseConnector::executeSql(connection = connnection,
                                sql = sql,
                                progressBar = TRUE)

}

