test_that("Excel to JSON file exists proj", {
  filePath <- testthat::test_path("TestPatientsTemplateComorbidities.xlsx")
  outputPath <- paste0(proj_path(), "/", fs::path("inst", "testCases"), "/", "test", ".json")
  testDir <- paste0(proj_path(), "/", fs::path("inst", "testCases"))
  readPatients(filePath = filePath, outputPath = NULL)
  expect_true(file.exists(outputPath))
  unlink(outputPath, recursive = TRUE)
  unlink(testDir, recursive = TRUE)
})

test_that("SQL exists proj", {
  filePath <- testthat::test_path("TestPatientsTemplateComorbidities.xlsx")
  outputPath <- paste0(proj_path(), "/", fs::path("inst", "testCases"), "/", "test", ".json")
  testDir <- paste0(proj_path(), "/", fs::path("inst", "testCases"))
  readPatients(filePath = filePath, outputPath = NULL)
  patientSQL(pathToTestCases = NULL)
  expect_true(dir.exists(paste0(testDir, "/", "sql")))
  expect_true(file.exists(outputPath))
  unlink(outputPath, recursive = TRUE)
  unlink(testDir, recursive = TRUE)
})

test_that("Excel to JSON file exists temp", {
  filePath <- testthat::test_path("TestPatientsTemplateComorbidities.xlsx")
  outputPath <- tempfile(fileext = ".json")
  readPatients(filePath = filePath, outputPath = outputPath)
  expect_true(file.exists(outputPath))
  unlink(outputPath, recursive = TRUE)
  })

test_that("SQL exists temp", {
  filePath <- testthat::test_path("TestPatientsTemplateComorbidities.xlsx")
  outputPath <- tempfile(fileext = ".json")
  pathToTestCases <- tempdir()
  readPatients(filePath = filePath, outputPath = outputPath)
  patientSQL(pathToTestCases = pathToTestCases)
  expect_true(dir.exists(paste0(pathToTestCases, "/", "sql")))
  unlink(outputPath, recursive = TRUE)
})
