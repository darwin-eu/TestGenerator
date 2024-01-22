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
  # names(listPatientTables) <- tolower(paste0("cdm.", patientTables))
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
patientsCDM <- function(pathJson = proj_path("inst", "testCases"),
                        testName = NULL) {

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
    # tableName <- "visit_occurrence"
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

#' `pushPatientSQL()` takes a file with patients in JSON format, pushes them into the blank CDM and performs the test.
#'
#' @param pathJson If NULL, takes the project path to create the SQL files
#'
#' @return Study results in the specified folder
#' @importFrom usethis proj_path
#' @importFrom SqlRender writeSql
#' @importFrom SqlRender render
#' @export
pushPatientSQL <- function(pathJson = NULL) {

  if (is.null(pathToTestCases)) {
    pathToTestCases <- proj_path("inst", "testCases")
  }
  # Clear any existing SQL file
  pathToSqlFiles <- file.path(pathToTestCases, "sql")
  # Initialize the sql path - careful, this will automatically remove prior results!
  if (dir.exists(pathToSqlFiles)) {
    unlink(pathToSqlFiles, recursive = TRUE)
  }
  dir.create(pathToSqlFiles)

  checkmate::test_directory_exists(pathToTestCases)
  testCaseFiles <- list.files(pathToTestCases, pattern = ".json")

  for (i in 1:length(testCaseFiles)) {
    # i = 1
    testCaseFile <- testCaseFiles[i]
    ParallelLogger::logInfo(paste("Creating SQL for", testCaseFile))

    # Read the JSON structure
    jsonTestCase <- jsonlite::read_json(file.path(pathToTestCases, testCaseFile))
    # Initialze the test case
    sql <- initTestCase()
    # Person records
    if (!is.null(jsonTestCase$cdm.person)) {
      for(p in 1:length(jsonTestCase$cdm.person)) {
        sql <- paste(sql, createCdmPerson(jsonTestCase$cdm.person[[p]]), sep="\n")
      }
    }
    # Observation period records
    if (!is.null(jsonTestCase$cdm.observation_period)) {
      for(p in 1:length(jsonTestCase$cdm.observation_period)) {
        sql <- paste(sql, createCdmObservationPeriod(jsonTestCase$cdm.observation_period[[p]]), sep="\n")
      }
    }
    # Drug exposure records
    if (!is.null(jsonTestCase$cdm.drug_exposure)) {
      for(p in 1:length(jsonTestCase$cdm.drug_exposure)) {
        sql <- paste(sql, createCdmDrugExposure(jsonTestCase$cdm.drug_exposure[[p]]), sep="\n")
      }
    }
    # Condition occurrence records
    if (!is.null(jsonTestCase$cdm.condition_occurrence)) {
      for(p in 1:length(jsonTestCase$cdm.condition_occurrence)) {
        sql <- paste(sql, createCdmConditionOccurrence(jsonTestCase$cdm.condition_occurrence[[p]]), sep="\n")
      }
    }
    # Visit occurrence records
    if (!is.null(jsonTestCase$cdm.visit_occurrence)) {
      for(p in 1:length(jsonTestCase$cdm.visit_occurrence)) {
        sql <- paste(sql, createCdmVisitOccurrence(jsonTestCase$cdm.visit_occurrence[[p]]), sep="\n")
      }
    }
    # Visit detail records
    if (!is.null(jsonTestCase$cdm.visit_detail)) {
      for(p in 1:length(jsonTestCase$cdm.visit_detail)) {
        sql <- paste(sql, createCdmVisitDetail(jsonTestCase$cdm.visit_detail[[p]]), sep="\n")
      }
    }
    # Visit detail records
    if (!is.null(jsonTestCase$cdm.death)) {
      for(p in 1:length(jsonTestCase$cdm.death)) {
        sql <- paste(sql, createCdmDeath(jsonTestCase$cdm.death[[p]]), sep="\n")
      }
    }
    sqlFilePath <- file.path(pathToTestCases, "sql", paste0(tools::file_path_sans_ext(testCaseFile), ".sql"))
    SqlRender::writeSql(sql, targetFile = sqlFilePath)
    if (file.exists(sqlFilePath)) {
      ParallelLogger::logInfo(testCaseFile, " successfully created")
    }
  }
}

# Helper Functions ------------
initTestCase <- function() {
  tableList <- list("PERSON", "DRUG_EXPOSURE", "OBSERVATION_PERIOD", "CONDITION_OCCURRENCE", "VISIT_OCCURRENCE", "DEATH")
  templateSql <- "TRUNCATE TABLE @cdm_database_schema.@table_name;"
  sql <- ""
  for (i in 1:length(tableList)) {
    if (i == 1) {
      sql <- SqlRender::render(sql=templateSql, table_name = tableList[i])
    } else {
      sql <- paste(sql, SqlRender::render(sql=templateSql, table_name = tableList[i]), sep="\n")
    }
  }
  return(paste0(sql, "\n\n"))
}

nullify <- function(val) {
  returnVal <- ifelse(is.null(val), 'NULL', val)
  if (is.character(val)) {
    returnVal = paste0('\'', val, '\'')
  }
  return(returnVal)
}
createCdmPerson <- function(person) {
  templateSql <- "INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT @person_id, @gender_concept_id, @year_of_birth, @race_concept_id, @ethnicity_concept_id, @person_source_value;"

  sql <- SqlRender::render(sql=templateSql,
                           person_id = person$person_id,
                           gender_concept_id = person$gender_concept_id,
                           year_of_birth = person$year_of_birth,
                           race_concept_id = person$race_concept_id,
                           ethnicity_concept_id = person$ethnicity_concept_id,
                           person_source_value = nullify(person$person_source_value))
  return(sql)
}
createCdmObservationPeriod <- function(op) {
  templateSql <- "INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT @observation_period_id, @person_id, '@observation_period_start_date', '@observation_period_end_date', @period_type_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           observation_period_id = op$observation_period_id,
                           person_id = op$person_id,
                           observation_period_start_date = op$observation_period_start_date,
                           observation_period_end_date = op$observation_period_end_date,
                           period_type_concept_id = op$period_type_concept_id)
  return(sql)
}
createCdmDrugExposure <- function(de) {
  templateSql <- "INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT @drug_exposure_id, @person_id, @drug_concept_id, '@drug_exposure_start_date', '@drug_exposure_end_date', @quantity, @drug_type_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           drug_exposure_id = de$drug_exposure_id,
                           person_id = de$person_id,
                           drug_concept_id = de$drug_concept_id,
                           drug_exposure_start_date = de$drug_exposure_start_date,
                           drug_exposure_end_date = de$drug_exposure_end_date,
                           quantity = de$quantity,
                           drug_type_concept_id = de$drug_type_concept_id)
  return(sql)
}
createCdmConditionOccurrence <- function (co) {
  templateSql <- "INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT @condition_occurrence_id, @person_id, @condition_concept_id, '@condition_start_date', @condition_type_concept_id, @condition_status_concept_id, @condition_source_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           condition_occurrence_id = co$condition_occurrence_id,
                           person_id = co$person_id,
                           condition_concept_id = co$condition_concept_id,
                           condition_start_date = co$condition_start_date,
                           condition_type_concept_id = co$condition_type_concept_id,
                           condition_status_concept_id = co$condition_status_concept_id,
                           condition_source_concept_id = co$condition_source_concept_id)
  return(sql)
}

createCdmVisitOccurrence <- function (vo) {
  templateSql <- "INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT @visit_occurrence_id, @person_id, @visit_concept_id, '@visit_start_date', '@visit_end_date', @visit_type_concept_id, @visit_source_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           visit_occurrence_id = vo$visit_occurrence_id,
                           person_id = vo$person_id,
                           visit_concept_id = vo$visit_concept_id,
                           visit_start_date = vo$visit_start_date,
                           visit_end_date = vo$visit_end_date,
                           visit_type_concept_id = vo$visit_type_concept_id,
                           visit_source_concept_id = vo$visit_source_concept_id)
  return(sql)
}

createCdmVisitDetail <- function (vd) {
  templateSql <- "INSERT INTO @cdm_database_schema.VISIT_DETAIL (visit_detail_id, person_id, visit_detail_concept_id, visit_detail_start_date, visit_detail_end_date, visit_detail_type_concept_id, visit_detail_source_concept_id, visit_occurrence_id)
                  SELECT @visit_detail_id, @person_id, @visit_detail_concept_id, '@visit_detail_start_date', '@visit_detail_end_date', @visit_detail_type_concept_id, @visit_detail_source_concept_id, @visit_occurrence_id;"

  sql <- SqlRender::render(sql=templateSql,
                           visit_detail_id = vd$visit_detail_id,
                           person_id = vd$person_id,
                           visit_detail_concept_id = vd$visit_detail_concept_id,
                           visit_detail_start_date = vd$visit_detail_start_date,
                           visit_detail_end_date = vd$visit_detail_end_date,
                           visit_detail_type_concept_id = vd$visit_detail_type_concept_id,
                           visit_detail_source_concept_id = vd$visit_detail_source_concept_id,
                           visit_occurrence_id = vd$visit_occurrence_id)
  return(sql)
}
