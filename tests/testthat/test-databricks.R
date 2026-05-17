test_that("Patients to CDM sqlserver and check cdm reference has attributes", {
  skip_on_cran()
  skip_if(Sys.getenv("DATABRICKS_HOST") == "")
  skip_if(Sys.getenv("DATABRICKS_TOKEN") == "")
  skip_if(Sys.getenv("DATABRICKS_HTTPPATH") == "")
  cdm <- NULL
  on.exit({
    if (!is.null(cdm)) {
      TestGenerator::cleanupTestCdm(cdm)
    }
  }, add = TRUE)
  cdmVersion <- "5.4"
  filePath <- testthat::test_path("test_cdm_data_pregnancy.xlsx")
  TestGenerator::readPatients(
    filePath = filePath,
    testName = "pregnancy",
    outputPath = NULL,
    extraTable = TRUE
  )
  # Test no error in connection
  expect_no_error(
    cdm <- TestGenerator::patientsCDM(
      pathJson = NULL,
      testName = "pregnancy",
      cdmVersion = cdmVersion,
      dbms = "databricks"
    )
  )

  attr(cdm, "cdm_schema") |>
    stringr::str_detect("testgenerator") |>
    expect_true()

  expect_no_error({
    cdm$cohort <- CohortConstructor::conceptCohort(
      cdm = cdm,
      conceptSet = list(a = 44500984L),
      name = "cohort")
  })

  cdm$cohort |>
    collect() |>
    nrow() |>
    expect_equal(2)

})
