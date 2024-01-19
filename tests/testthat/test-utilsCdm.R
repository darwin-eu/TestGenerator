test_that("CDM emptied", {
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomia_dir("synthea-allergies-10k"))
  cdm <- CDMConnector::cdmFromCon(con, cdmSchema = "main", writeSchema = "main")
  cdm <- TestGenerator::emptyCDM(cdm = cdm, con = con)
  expect_equal(class(cdm), "cdm_reference")
  countPerson <- DBI::dbGetQuery(con, "SELECT COUNT(*) FROM person")
  expect_equal(countPerson[[1]], 0)
  DBI::dbDisconnect(con, shutdown = TRUE)
})
