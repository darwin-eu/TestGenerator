test_that("Patients to CDM version 5.4", {
  skip_on_cran()
  cdmVersion <- "5.4"
  filePath <- testthat::test_path("test_cdm_data_pregnancy.xlsx")
  TestGenerator::readPatients(filePath = filePath, testName = "pregnancy", outputPath = NULL, extraTable = TRUE)
  cdm <- TestGenerator::patientsCDM(pathJson = NULL, testName = "pregnancy", cdmVersion = cdmVersion)
  expect_equal(class(cdm), "cdm_reference")
  expect_equal(CDMConnector::snapshot(cdm) %>% dplyr::pull("cdm_version"), cdmVersion)
  duckdb::duckdb_shutdown(duckdb::duckdb())
})

