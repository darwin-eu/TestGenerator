test_that("Patients to CDM sqlserver and check cdm reference has attributes", {
  skip_on_cran()
  skip_if(Sys.getenv("POSTGRESQL_SERVER") == "")
  skip_if(Sys.getenv("POSTGRESQL_DBNAME") == "")
  skip_if(Sys.getenv("POSTGRESQL_USER") == "")
  skip_if(Sys.getenv("POSTGRESQL_PASSWORD") == "")
  skip_if(Sys.getenv("POSTGRESQL_PORT") == "")
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
      dbms = "postgresql"
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
