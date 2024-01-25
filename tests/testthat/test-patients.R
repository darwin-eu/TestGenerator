
test_that("Reading patients and JSON created successfully", {
  filePath <- testthat::test_path("testPatientsRSV.xlsx")
  outputPath <- tempdir()
  readPatients(filePath = filePath, outputPath = outputPath)
  expect_true(file.exists(file.path(outputPath, "test.json")))
  unlink(outputPath, recursive = TRUE)
})

# test_that("Reading patients NULL outputpath", {
#   filePath <- testthat::test_path("testPatientsRSV.xlsx")
#   readPatients(filePath = filePath, outputPath = NULL)
#   usethis::use_directory(fs::path("inst", "testCases"))
#   outputPath <- fs::path("inst", "testCases")
#   expect_true(file.exists(file.path(outputPath, "test.json")))
#   unlink(outputPath, recursive = TRUE)
# })

test_that("Patients to CDM", {
  filePath <- test_path("testPatientsRSV.xlsx")
  outputPath <- tempdir()
  dir.create(outputPath)
  TestGenerator::readPatients(filePath = filePath, outputPath = outputPath)
  cdm <- TestGenerator::cdmPatients(pathJson = outputPath, testName = "test")
  expect_equal(class(cdm), "cdm_reference")
  number_persons <- cdm[["person"]] %>% dplyr::pull(person_id)
  expect_equal(length(number_persons), 20)
  unlink(outputPath, recursive = TRUE)
})

test_that("Pushing patients PostgreSQL", {

  user <- Sys.getenv("UT_DB_USER")
  password <- Sys.getenv("UT_DB_PASSWORD")
  cdmSchema <- Sys.getenv("UT_CDM_SCHEMA")
  writeSchema <- Sys.getenv("UT_COHORT_SCHEMA")
  dbms <- Sys.getenv("UT_DBMS")
  dbname <- Sys.getenv("UT_DB_NAME")
  server <- Sys.getenv("UT_DB_SERVER")
  port <- Sys.getenv("UT_DB_PORT")

  conn <- DBI::dbConnect(RPostgres::Postgres(),
                         dbname = dbname,
                         port = port,
                         host = server,
                         user = user,
                         password = password)

  DBI::dbExecute(conn, "SELECT * FROM cdm.person;")

  cdm <- pushPatients(connection = conn,
                      cdmSchema,
                      writeSchema,
                      pathJson = NULL,
                      testName = NULL)

  class(cdm)

  expect_class(cdm, "cdm reference")



})


