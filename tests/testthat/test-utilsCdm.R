test_that("CDM emptied", {
  conn <- DBI::dbConnect(duckdb::duckdb(CDMConnector::eunomia_dir("synthea-allergies-10k")))
  cdm <- CDMConnector::cdmFromCon(conn, cdmSchema = "main", writeSchema = "main")
  cdm <- TestGenerator::emptyCDM(cdm = cdm, con = conn)
  expect_equal(class(cdm), "cdm_reference")
  countPerson <- DBI::dbGetQuery(conn, "SELECT COUNT(*) FROM person")
  expect_equal(countPerson[[1]], 0)
  DBI::dbDisconnect(conn, shutdown = TRUE)
})
