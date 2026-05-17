# Remote databases

DuckDB is the default backend in TestGenerator, and it is usually the
fastest place to start. Remote database testing is useful when you also
want to check that your study code works on another SQL engine. This is
especially helpful for code that will run in PostgreSQL, SQL Server, or
Databricks/Spark in production.

The idea is the same as with local testing: you create a small,
controlled test population, load it into a CDM, run your study code, and
assert the expected result. The difference is that
[`patientsCDM()`](../reference/patientsCDM.md) uploads the test CDM to a
remote database and returns a CDM reference connected to that backend.

## Use `patientsCDM()` with a remote database

First create a Unit Test Definition JSON file with
[`readPatients()`](../reference/readPatients.md) or
[`readPatients.csv()`](../reference/readPatients.csv.md). Then call
[`patientsCDM()`](../reference/patientsCDM.md) with the backend you want
to test.

``` r

library(TestGenerator)

cdm <- patientsCDM(
  pathJson = "tests/testthat/testCases",
  testName = "my_test_population",
  cdmVersion = "5.4",
  dbms = "postgresql"
)
```

The supported remote values for `dbms` are:

| Backend          | `dbms` value   |
|------------------|----------------|
| PostgreSQL       | `"postgresql"` |
| SQL Server       | `"sqlserver"`  |
| Databricks/Spark | `"databricks"` |

For remote databases, [`patientsCDM()`](../reference/patientsCDM.md)
creates the CDM locally first, trims the vocabulary to what the test
population needs, uploads the result to the remote database, and returns
the remote CDM reference. By default, TestGenerator creates a temporary
test schema for the upload. You can also provide `writeSchema` if you
want to choose the schema name yourself.

``` r

cdm <- patientsCDM(
  pathJson = "tests/testthat/testCases",
  testName = "my_test_population",
  cdmVersion = "5.4",
  dbms = "sqlserver",
  writeSchema = "testgenerator_my_case"
)
```

When the test has finished, clean up the remote schema and close the
connection:

``` r

cleanupTestCdm(cdm)
```

This is important for shared remote databases. The test schemas are
small, but cleaning them up keeps the database tidy and avoids name
conflicts in later runs.

## Environment variables for direct use

When you call [`patientsCDM()`](../reference/patientsCDM.md) directly
against a remote database, TestGenerator reads the connection details
from environment variables.

| Backend | Required environment variables |
|----|----|
| PostgreSQL | `POSTGRESQL_SERVER`, `POSTGRESQL_DBNAME`, `POSTGRESQL_PORT`, `POSTGRESQL_USER`, `POSTGRESQL_PASSWORD` |
| SQL Server | `SQLSERVER_SERVER`, `SQLSERVER_DBNAME`, `SQLSERVER_PORT`, `SQLSERVER_USER`, `SQLSERVER_PASSWORD` |
| Databricks/Spark | `DATABRICKS_HOST`, `DATABRICKS_TOKEN`, `DATABRICKS_HTTPPATH` |

For Databricks, TestGenerator also reads `DATABRICKS_USER` and
`DATABRICKS_WORKSPACE` when they are set. If they are not set, it uses
`token` as the user and `hive_metastore` as the workspace/catalog.

For SQL Server, TestGenerator reads `SQL_SERVER_DRIVER` when it is set.
If it is not set, it uses `ODBC Driver 18 for SQL Server`.

A typical local `.Renviron` setup could look like this:

``` bash
POSTGRESQL_SERVER=localhost
POSTGRESQL_DBNAME=cdm
POSTGRESQL_PORT=5432
POSTGRESQL_USER=postgres
POSTGRESQL_PASSWORD=your-password

SQLSERVER_SERVER=localhost
SQLSERVER_DBNAME=cdm
SQLSERVER_PORT=1433
SQLSERVER_USER=sa
SQLSERVER_PASSWORD=your-password

DATABRICKS_HOST=https://your-workspace.cloud.databricks.com
DATABRICKS_TOKEN=your-token
DATABRICKS_HTTPPATH=/sql/1.0/warehouses/your-warehouse
```

Use values that match your own database or Databricks workspace. The
database user needs permission to create schemas, create tables, insert
data, read data, and drop the test schema during cleanup.

## A minimal backend test pattern

A backend-specific test usually follows this shape:

``` r

testthat::test_that("study logic works on PostgreSQL", {
  cdm <- NULL
  on.exit({
    if (!is.null(cdm)) {
      TestGenerator::cleanupTestCdm(cdm)
    }
  }, add = TRUE)

  cdm <- TestGenerator::patientsCDM(
    pathJson = "tests/testthat/testCases",
    testName = "my_test_population",
    cdmVersion = "5.4",
    dbms = "postgresql"
  )

  result <- myPackage::runMyStudy(cdm)

  testthat::expect_equal(result$n_subjects, 3)
})
```

The exact expectations should be specific to your micro population. Good
tests usually check counts, dates, cohort entry and exit, exclusions, or
any other result that should be predictable from the small input
dataset.
