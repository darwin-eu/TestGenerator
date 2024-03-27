#' Converts a sample of patients in XLSX format into Unit Testing Definition JSON file.
#'
#' @param filePath Path to the test patient data in Excel format. The Excel has sheets that represent tables from the OMOP-CDM, e.g. person, drug_exposure, condition_ocurrence, etc.
#' @param testName A name of the test population in character.
#' @param outputPath Path of the output file, if NULL, a folder will be created in the project folder inst/testCases.
#' @param cdmVersion cdm version, default "5.3".
#'
#' @return A JSON file with sample patients inside the project directory.
#'
#' @importFrom readxl read_excel excel_sheets
#' @importFrom jsonlite toJSON
#' @importFrom usethis use_directory
#' @importFrom fs path
#' @importFrom usethis proj_path
#' @importFrom checkmate assertDirectoryExists assertCharacter assertFileExists assert
#' @importFrom glue glue
#'
#' @examples
#' filePath <- system.file("extdata", "testPatientsRSV.xlsx", package = "TestGenerator")
#' readPatients_xl(filePath = filePath, outputPath = tempdir())
#'
#' @export
readPatients.xl <- function(filePath = NULL,
                              testName = "test",
                              outputPath = NULL,
                              cdmVersion = "5.3") {

  checkmate::assertCharacter(filePath)
  checkmate::assertFileExists(filePath)

  expectedTables <- spec_cdm_field[[cdmVersion]] %>%
    dplyr::pull(cdmTableName)

  patientTables <- readxl::excel_sheets(filePath)
  checkmate::assert(all(patientTables %in% unique(expectedTables)))

  listPatientTables <- lapply(patientTables,
                              readxl::read_excel,
                              path = filePath)

  names(listPatientTables) <- tolower(patientTables)

  testCaseFile <- jsonlite::toJSON(listPatientTables,
                                   dataframe = "rows",
                                   pretty = TRUE)

  if (is.null(outputPath)) {
    usethis::use_directory(fs::path("inst", "testCases"))
    outputPath <- fs::path("inst", "testCases")
    testPath <- paste0(outputPath, "/", testName, ".json")
  } else {
    checkmate::assertCharacter(outputPath)
    checkmate::assertDirectoryExists(outputPath)
    testPath <- paste0(outputPath, "/", testName, ".json")
  }
  write(testCaseFile, file = testPath)
  if (checkmate::checkFileExists(testPath)) {
    message(glue::glue("Unit Test Definition created successfully: {testName}"))
  } else {
    stop("Unit Test Definition creation failed")
  }
}

#' Converts a sample of patients in CSV format into a Unit Testing Definition JSON file.
#'
#' @param filePath Path to the test patient data in CSV format. Multiple CSV files representing tables tables from the OMOP-CDM must be provided, e.g. person.csv, drug_exposure.csv, condition_ocurrence.csv, etc.
#' @param testName Name for the test population file in character.
#' @param outputPath Path of the output file, if NULL, a folder will be created in the project folder inst/testCases.
#' @param cdmVersion cdm version, default "5.3".
#'
#' @return A JSON file with sample patients inside the project directory.
#'
#' @importFrom readr read_csv
#' @importFrom jsonlite toJSON
#' @importFrom usethis use_directory
#' @importFrom fs path
#' @importFrom usethis proj_path
#' @importFrom checkmate assertDirectoryExists assertCharacter assertFileExists assert
#' @importFrom glue glue
#' @importFrom tools file_path_sans_ext
#'
#' @examples
#' filePath <- system.file("extdata", "mimic_sample", package = "TestGenerator")
#' readPatients.csv(filePath = filePath, outputPath = tempdir())
#'
#' @export
readPatients.csv <- function(filePath = NULL,
                             testName = "test",
                             outputPath = NULL,
                             cdmVersion = "5.3") {

  checkmate::assertDirectoryExists(filePath)

  # Read list of csv files
  csvFiles <- list.files(filePath, pattern = ".csv", full.names = TRUE)
  csvFilesNames <- list.files(filePath, pattern = ".csv")

  checkmate::assertCharacter(csvFiles)

  listPatientTables <- list()
  # Check for the expected columns in the CDM
  for (i in 1:length(csvFiles)) {
    # i <- 2
    tableName <- tools::file_path_sans_ext(csvFilesNames[i])
    cdmTable <- readr::read_csv(csvFiles[i], show_col_types = FALSE)
    currentCoulumns <- names(cdmTable)
    expectedColumns <- spec_cdm_field[[cdmVersion]] %>%
      dplyr::filter(cdmTableName == tableName) %>%
      dplyr::pull(cdmFieldName)
    if (all(currentCoulumns %in% expectedColumns)) {
      listPatientTables[[tableName]] <- cdmTable
    } else {
      stop(glue::glue("{tableName} table columns do not match"))
    }
  }

  names(listPatientTables) <- tolower(listPatientTables)

  testCaseFile <- jsonlite::toJSON(listPatientTables,
                                   dataframe = "rows",
                                   pretty = TRUE)

  if (is.null(outputPath)) {
    usethis::use_directory(fs::path("inst", "testCases"))
    outputPath <- fs::path("inst", "testCases")
    testPath <- paste0(outputPath, "/", testName, ".json")
  } else {
    checkmate::assertCharacter(outputPath)
    checkmate::assertDirectoryExists(outputPath)
    testPath <- paste0(outputPath, "/", testName, ".json")
  }
  write(testCaseFile, file = testPath)
  if (checkmate::checkFileExists(testPath)) {
    message(glue::glue("Unit Test Definition created successfully: {testName}"))
  } else {
    stop("Unit Test Definition creation failed")
  }
}



#' Pushes test population into a blank CDM.
#'
#' @param pathJson Directory where the sample populations in json are located. If NULL, gets the default inst/testCases directory.
#' @param testName Name of the sample population JSON file. If NULL it will push the first sample population in the testCases directory.
#' @param cdmVersion cdm version, default "5.3".
#'
#' @return A CDM reference object with a sample population.
#' @import dplyr
#' @importFrom usethis proj_path
#' @importFrom DBI dbConnect dbAppendTable dbDisconnect
#' @importFrom duckdb duckdb
#' @importFrom jsonlite fromJSON
#' @importFrom CDMConnector downloadEunomiaData example_datasets eunomia_dir cdmFromCon
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
                        cdmVersion = "5.3") {

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

    vocabPath <- file.path(Sys.getenv("EUNOMIA_DATA_FOLDER"),
                           glue::glue("empty_cdm_{cdmVersion}.zip"))

    if (!file.exists(vocabPath)) {
      CDMConnector::downloadEunomiaData(datasetName = "empty_cdm",
                                        cdmVersion = cdmVersion,
                                        pathToData = Sys.getenv("EUNOMIA_DATA_FOLDER"),
                                        overwrite = TRUE)
    }

    conn <- DBI::dbConnect(duckdb::duckdb(CDMConnector::eunomia_dir("empty_cdm")))
    cdm <- CDMConnector::cdmFromCon(con = conn,
                                    cdmSchema = "main",
                                    writeSchema = "main")

  } else {

    # Get allergies 10K dataset
    vocabPath <- file.path(Sys.getenv("EUNOMIA_DATA_FOLDER"),
                           glue::glue("synthea-allergies-10k_{cdmVersion}.zip"))

    if (!file.exists(vocabPath)) {
      CDMConnector::downloadEunomiaData(datasetName = "synthea-allergies-10k")
    }

    # Empty CDM
    conn <- DBI::dbConnect(duckdb::duckdb(CDMConnector::eunomia_dir("synthea-allergies-10k")))
    cdm <- CDMConnector::cdmFromCon(con = conn,
                                    cdmSchema = "main",
                                    writeSchema = "main")
    cdm <- emptyCDM(conn = conn,
                    cdm = cdm)

  }

  # Read the JSON file into R
  jsonData <- jsonlite::fromJSON(fileName)
  # Check for the expected columns in the CDM
  for (tableName in names(jsonData)) {
    # tableName <- "visit_detail"
    currentCoulumns <- names(jsonData[[tableName]])
    expectedColumns <- spec_cdm_field[[cdmVersion]] %>%
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
  message(glue::glue("Patients pushed to blank CDM successfully"))
  return(cdm)
}
