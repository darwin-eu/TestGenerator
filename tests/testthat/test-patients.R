test_that("checkTablesColumns function works csv with test data", {
  filePath <- testthat::test_path("test_cdm_data.xlsx")
  checkmate::assertCharacter(filePath)
  checkmate::assertFileExists(filePath)
  cdmVersion <- "5.3"
  listPatientTables <- checkTablesColumns(cdmVersion, filePath, extraTable = FALSE)

  expect_in(names(listPatientTables), c("person", "observation_period", "condition_occurrence", "pregnancy",
                                        "measurement", "drug_exposure", "visit_detail", "visit_occurrence",
                                        "procedure_occurrence", "device_exposure", "observation", "note",
                                        "death", "note_nlp", "specimen", "fact_relationship"))
})

test_that("checkTablesColumns function works csv with table 'pregnancy'", {
  filePath <- testthat::test_path("test_cdm_data_pregnancy.xlsx")
  checkmate::assertCharacter(filePath)
  checkmate::assertFileExists(filePath)
  cdmVersion <- "5.3"
  listPatientTables <- checkTablesColumns(cdmVersion, filePath, extraTable = TRUE)

  expect_in(names(listPatientTables), c("person", "observation_period", "condition_occurrence", "pregnancy",
                                        "measurement", "drug_exposure", "visit_detail", "visit_occurrence",
                                        "procedure_occurrence", "device_exposure", "observation", "note",
                                        "death", "note_nlp", "specimen", "fact_relationship"))
})

test_that("checkTablesColumns function works csv with table 'pregnancy'", {
  filePath <- testthat::test_path("test_cdm_data_pregnancy.xlsx")
  checkmate::assertCharacter(filePath)
  checkmate::assertFileExists(filePath)
  cdmVersion <- "5.3"

  expect_error(checkTablesColumns(cdmVersion, filePath, extraTable = FALSE))
})

test_that("checkTablesColumns function works csv", {
  filePath <- testthat::test_path("test_cdm_data_pregnancy.xlsx")
  checkmate::assertCharacter(filePath)
  checkmate::assertFileExists(filePath)
  cdmVersion <- "5.3"
  expect_error(checkTablesColumns(cdmVersion, filePath, extraTable = "pregnancys"))
})

test_that("fileColumnCheck function works", {
  filePath <- testthat::test_path("mimic_sample")
  cdmVersion <- "5.3"
  listPatientTables <- fileColumnCheck(filePath, cdmVersion)
  expect_equal(names(listPatientTables), c("condition_occurrence",
                                           "drug_exposure",
                                           "measurement",
                                           "observation_period",
                                           "person",
                                           "visit_detail",
                                           "visit_occurrence"))
})

test_that("Reading patients XLSX and JSON creation for pregnancy", {
  filePath <- testthat::test_path("testPatientsRSV.xlsx")
  # outputPath <- file.path(tempdir(), "test1")
  # dir.create(outputPath)

  # outputPath explicitly NULL to create the testCases in the testthat folder
  readPatients.xl(filePath = filePath, outputPath = NULL, extraTable = FALSE)
  expect_true(file.exists(file.path(testthat::test_path("testCases"), "test.json")))
})

test_that("Reading patients XLSX and JSON creation", {
  filePath <- testthat::test_path("test_cdm_data_pregnancy.xlsx")
  # outputPath <- file.path(tempdir(), "test1")
  # dir.create(outputPath)

  # outputPath explicitly NULL to create the testCases in the testthat folder
  readPatients.xl(filePath = filePath, testName = "pregnancy", outputPath = NULL, extraTable = TRUE)
  expect_true(file.exists(file.path(testthat::test_path("testCases"), "pregnancy.json")))
})

test_that("Patients to CDM xlsx function", {
  filePath <- testthat::test_path("testPatientsRSV.xlsx")
  TestGenerator::readPatients.xl(filePath = filePath, outputPath = NULL)
  cdm <- TestGenerator::patientsCDM(pathJson = NULL, testName = "pregnancy")
  expect_equal(class(cdm), "cdm_reference")
  number_persons <- cdm[["person"]] %>% dplyr::pull(person_id)
  expect_equal(length(number_persons), 18)
  duckdb::duckdb_shutdown(duckdb::duckdb())
})

test_that("Patients to CDM xlsx function pregnancy extra table", {
  filePath <- testthat::test_path("test_cdm_data_pregnancy.xlsx")
  TestGenerator::readPatients.xl(filePath = filePath, testName = "pregnancy", outputPath = NULL, extraTable = TRUE)
  cdm <- TestGenerator::patientsCDM(pathJson = NULL, testName = "pregnancy")
  expect_equal(class(cdm), "cdm_reference")
  expect_equal(cdm$pregnancy %>% colnames(), c("pregnancy_occurrence_id", "person_id", "pregnancy_concept_id", "pregnancy_start_date"))
  number_persons <- cdm[["person"]] %>% dplyr::pull(person_id)
  expect_equal(length(number_persons), 18)
  duckdb::duckdb_shutdown(duckdb::duckdb())
})

test_that("Read patients empty tables xl", {
  filePath <- testthat::test_path("test_cdm_data.xlsx")
  TestGenerator::readPatients.xl(filePath = filePath, outputPath = NULL)
  cdm <- TestGenerator::patientsCDM(pathJson = NULL, testName = "test")
  expect_equal(class(cdm), "cdm_reference")
  number_persons <- cdm[["person"]] %>% dplyr::pull(person_id)
  expect_equal(length(number_persons), 18)
  duckdb::duckdb_shutdown(duckdb::duckdb())
})

test_that("Read patients empty xl", {
  filePath <- testthat::test_path("test_cdm_data.xlsx")
  TestGenerator::readPatients.xl(filePath = filePath, outputPath = NULL)
  cdm <- TestGenerator::patientsCDM(pathJson = NULL, testName = "test")
  expect_equal(class(cdm), "cdm_reference")
  number_persons <- cdm[["person"]] %>% dplyr::pull(person_id)
  expect_equal(length(number_persons), 18)
  duckdb::duckdb_shutdown(duckdb::duckdb())
})

test_that("Reading sample MIMIC patients CSV files and JSON creation", {
  filePath <- testthat::test_path("mimic_sample")
  outputPath <- testthat::test_path("testCases")
  # outputPath <- file.path(tempdir(), "test1")
  # dir.create(outputPath)
  readPatients.csv(filePath = filePath, testName = "mimic_sample", outputPath = NULL)
  expect_true(file.exists(file.path(outputPath, "mimic_sample.json")))
  # unlink(outputPath, recursive = TRUE)
})

test_that("Reading MIMIC patients CSV files and JSON creation", {
  pathToData <- tempdir()
  pathToZipFile <- downloadTestData(datasetName = "mimicIV",
                                    cdmVersion = "5.3",
                                    pathToData = pathToData,
                                    overwrite = TRUE)
  unzip(pathToZipFile, exdir = pathToData)
  filePath <- file.path(pathToData,
                        "mimic-iv-demo-data-in-the-omop-common-data-model-0.9",
                        "1_omop_data_csv")
  outputPath <- file.path(tempdir(), "test1")
  dir.create(outputPath)
  testName <- "test"
  cdmVersion <- "5.3"
  readPatients.csv(filePath = filePath,
                   testName = testName,
                   outputPath = outputPath,
                   cdmVersion = cdmVersion)
  expect_true(file.exists(file.path(outputPath, "test.json")))
  unlink(outputPath, recursive = TRUE)
})

test_that("Mimic data Patients to CDM function", {
  pathToData <- tempdir()
  cdmVersion <- "5.3"
  pathToZipFile <- downloadTestData(datasetName = "mimicIV",
                                    cdmVersion = cdmVersion,
                                    pathToData = pathToData,
                                    overwrite = TRUE)
  unzip(pathToZipFile, exdir = pathToData)
  filePath <- file.path(pathToData,
                        "mimic-iv-demo-data-in-the-omop-common-data-model-0.9",
                        "1_omop_data_csv")
  outputPath <- file.path(tempdir(), "test1")
  dir.create(outputPath)
  testName <- "test"
  readPatients.csv(filePath = filePath,
                   testName = testName,
                   outputPath = outputPath,
                   cdmVersion = cdmVersion,
                   reduceLargeIds = TRUE)
  cdmName <- "myCDM"
  cdm <- TestGenerator::patientsCDM(pathJson = outputPath, testName = "test", cdmName = cdmName)
  expect_equal(class(cdm), "cdm_reference")
  number_persons <- cdm[["person"]] %>% dplyr::pull(person_id) %>% length()
  expect_equal(number_persons, 100)
  expect_equal(CDMConnector::cdmName(cdm), cdmName)
  unlink(outputPath, recursive = TRUE)
  duckdb::duckdb_shutdown(duckdb::duckdb())
})

test_that("convert ids function", {
  pathToData <- tempdir()
  cdmVersion <- "5.3"
  pathToZipFile <- downloadTestData(datasetName = "mimicIV",
                                    cdmVersion = cdmVersion,
                                    pathToData = pathToData,
                                    overwrite = TRUE)
  unzip(pathToZipFile, exdir = pathToData)
  filePath <- file.path(pathToData,
                        "mimic-iv-demo-data-in-the-omop-common-data-model-0.9",
                        "1_omop_data_csv")
  cdmTables <- fileColumnCheck(filePath, cdmVersion)
  cdmTables <- convertIds(cdmTables)
  measurement_ids <- cdmTables$measurement %>% pull(measurement_id)
  expect_equal(measurement_ids, seq(1, length(measurement_ids)))
  unlink(pathToData, recursive = TRUE)
  unlink(filePath, recursive = TRUE)
  duckdb::duckdb_shutdown(duckdb::duckdb())
})
