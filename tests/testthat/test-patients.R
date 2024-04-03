test_that("checkColumns function works", {
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

test_that("Reading patients XLSX and JSON creation", {
  filePath <- testthat::test_path("testPatientsRSV.xlsx")
  outputPath <- file.path(tempdir(), "test1")
  dir.create(outputPath)
  readPatients.xl(filePath = filePath, outputPath = outputPath)
  expect_true(file.exists(file.path(outputPath, "test.json")))
  unlink(outputPath, recursive = TRUE)
})

test_that("Patients to CDM xlsx function", {
  filePath <- test_path("testPatientsRSV.xlsx")
  outputPath <- file.path(tempdir(), "test2")
  dir.create(outputPath)
  TestGenerator::readPatients.xl(filePath = filePath, outputPath = outputPath)
  cdm <- TestGenerator::patientsCDM(pathJson = outputPath, testName = "test")
  expect_equal(class(cdm), "cdm_reference")
  number_persons <- cdm[["person"]] %>% dplyr::pull(person_id)
  expect_equal(length(number_persons), 20)
  unlink(outputPath, recursive = TRUE)
  duckdb::duckdb_shutdown(duckdb::duckdb())
})

test_that("Reading sample MIMIC patients CSV files and JSON creation", {
  filePath <- testthat::test_path("mimic_sample")
  outputPath <- file.path(tempdir(), "test1")
  dir.create(outputPath)
  readPatients.csv(filePath = filePath, outputPath = outputPath)
  expect_true(file.exists(file.path(outputPath, "test.json")))
  unlink(outputPath, recursive = TRUE)
})

test_that("Reading MIMIC patients CSV files and JSON creation", {
  filePath <- "C:/Users/cbarboza/OneDrive - Darwin EU Coordination Centre/TestGenerator_docs/MIMIC_5.3"
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
  filePath <- "C:/Users/cbarboza/OneDrive - Darwin EU Coordination Centre/TestGenerator_docs/MIMIC_5.3"
  outputPath <- file.path(tempdir(), "test1")
  dir.create(outputPath)
  testName <- "test"
  cdmVersion <- "5.3"
  readPatients.csv(filePath = filePath,
                   testName = testName,
                   outputPath = outputPath,
                   cdmVersion = cdmVersion,
                   reduceLargeIds = TRUE)
  cdm <- TestGenerator::patientsCDM(pathJson = outputPath, testName = "test")
  expect_equal(class(cdm), "cdm_reference")
  number_persons <- cdm[["person"]] %>% dplyr::pull(person_id) %>% length()
  expect_equal(number_persons, 100)
  unlink(outputPath, recursive = TRUE)
  duckdb::duckdb_shutdown(duckdb::duckdb())
})

test_that("conver ids function", {
  filePath <- "C:/Users/cbarboza/OneDrive - Darwin EU Coordination Centre/TestGenerator_docs/MIMIC_5.3"
  cdmVersion <- "5.3"
  cdmTables <- fileColumnCheck(filePath, cdmVersion)
  cdmTables <- convertIds(cdmTables)
  measurement_ids <- cdmTables$measurement %>% pull(measurement_id)
  expect_equal(measurement_ids, seq(1, length(measurement_ids)))
})


