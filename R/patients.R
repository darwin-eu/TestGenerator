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

#' `patientsCDM()` takes a file with patients in JSON format and pushes them into a blank CDM.
#'
#' @param pathJson Directory where the sample populations in json are located. If NULL, gets the default inst/testCases directory.
#' @param testName Name of the sample population json file. If NULL it will push the first sample population in the testCases directory.
#'
#' @return A CDM reference object with a sample population.
#' @import dplyr
#' @importFrom usethis proj_path
#' @importFrom duckdb duckdb
#' @importFrom jsonlite fromJSON
#' @export
patientsCDM <- function(pathJson = NULL,
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
  }

  # Convert the JSON data into a data frame and append it to the blank CDM
  for (tableName in names(jsonData)) {
    # tableName <- "visit_occurrence"
    patientData <- as.data.frame(jsonData[[tableName]])
    DBI::dbAppendTable(conn, tableName, patientData)
  }
  return(cdm)
}

#' `pushPatients()` pushes sample patients into a blank CDM if a connection is provided.
#'
#' @param connection A DBI connection to a blank CDM.
#' @param cdmSchema CDM schema of the database. E.g. "cdm" or "main".
#' @param writeSchema Writing schema of the database.
#' @param pathJson Directory where the sample populations in json are located. If NULL, gets the default inst/testCases directory.
#' @param testName Name of the sample population json file. If NULL it will push the first sample population in the testCases directory.
#'
#' @return A CDM reference object.
#' @import dplyr
#' @importFrom CDMConnector cdmFromCon
#' @importFrom usethis proj_path
#' @importFrom duckdb duckdb
#' @importFrom jsonlite fromJSON
#' @export
pushPatients <- function(connection,
                         cdmSchema,
                         writeSchema,
                         pathJson = NULL,
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

  cdm <- CDMConnector::cdmFromCon(con = connection,
                                  cdmSchema = cdmSchema,
                                  writeSchema = cdmSchema)

  cdm <- emptyCDM(conn = connection, cdmSchema = cdmSchema, cdm = cdm)

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
  }

  # Convert the JSON data into a data frame and append it to the blank CDM
  for (tableName in names(jsonData)) {
    # tableName <- "visit_occurrence"
    patientData <- as.data.frame(jsonData[[tableName]])
    DBI::dbAppendTable(connection, tableName, patientData)
  }
  return(cdm)
  }

