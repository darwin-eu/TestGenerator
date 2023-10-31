#' `readPatients()` converts a test patients in XLSX format into a JSON for testing, and creates a JSON in the a inst/testCases folder.
#'
#' @param dataPath Path to the test patient data in Excel format.
#' @param testName Name of the test in character.
#' @param sheets The sheets to be converted
#'
#' @return A SQL file for testing inside the package directory of a DARWIN EU study.
#'
#' @importFrom readxl read_excel excel_sheets
#' @importFrom jsonlite toJSON
#' @importFrom usethis use_directory
#' @importFrom fs path
#' @importFrom ParallelLogger logInfo
#' @importFrom usethis proj_path
#'
#' @export
readPatients <- function(path = NULL,
                         testName = "test",
                         sheets = c("person", "observation_period", "drug_exposure",
                                    "condition_occurrence", "visit_occurrence", "visit_context")) {

  checkmate::assert_character(path)
  checkmate::checkFile(path)
  checkmate::assert_character(outputPath)

  patientTables <- readxl::excel_sheets(path)
  checkmate::assert(all(patientTables %in% sheets))

  listPatientTables <- lapply(patientTables, readxl::read_excel, path = path)
  names(listPatientTables) <- tolower(paste0("cdm.", patientTables))

  testCaseFile <- jsonlite::toJSON(listPatientTables,
                                   dataframe = "rows",
                                   pretty = TRUE)

  usethis::use_directory(fs::path("inst", "testCases"))
  write(testCaseFile, file = paste0(proj_path(), "/",
                                    "inst", "/", "testCases",
                                    "/", testName, ".json"))
  TestGenerator::patientSQL()
}

#' `testPatients()` takes a file with patients in JSON format, pushes them into the blank CDM and performs the test.
#'
#' @param testCaseFile Path to JSON test files. Those should contain patients, observation period, drug exposure, condition and visit occurrence.
#'
#' @return Study results in the specified folder
#' @importFrom usethis proj_path
#' @export
patientSQL <- function() {

  pathToTestCases <- proj_path("inst", "testCases")
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
    sqlFilePath <- file.path(pathToTestCases, "sql", paste0(tools::file_path_sans_ext(testCaseFile), ".sql"))
    SqlRender::writeSql(sql, targetFile = sqlFilePath)
    if (file.exists(sqlFilePath)) {
      ParallelLogger::logInfo(testCaseFile, " successfully created")
    }
  }
}

# Helper Functions ------------
initTestCase <- function() {
  tableList <- list("PERSON", "DRUG_EXPOSURE", "OBSERVATION_PERIOD", "CONDITION_OCCURRENCE", "VISIT_OCCURRENCE")
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

