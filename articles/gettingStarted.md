# Getting started with TestGenerator

TestGenerator helps you test pharmacoepidemiological study code against
a small, explicit OMOP CDM test population. The typical workflow is:

1.  Create a small patient dataset in Excel or CSV files.
2.  Convert that dataset to a Unit Test Definition JSON file.
3.  Load the JSON into a blank CDM.
4.  Run your study code and assert the expected results.

This vignette uses the ICU sample population included with the package.

## Create a Unit Test Definition

An Excel input file should contain one sheet per OMOP CDM table. For
example, the sheet names can include `person`, `observation_period`,
`visit_occurrence`, `condition_occurrence`, `drug_exposure`, and
`measurement`.

``` r

library(TestGenerator)

file_path <- system.file(
  "extdata",
  "icu_sample_population.xlsx",
  package = "TestGenerator"
)

output_path <- file.path(tempdir(), "testgenerator-example")
dir.create(output_path, showWarnings = FALSE, recursive = TRUE)

readPatients(
  filePath = file_path,
  testName = "icu_sample",
  outputPath = output_path,
  cdmVersion = "5.4"
)
```

This writes `icu_sample.json` to `output_path`. Keeping these JSON files
in `tests/testthat/testCases` makes them easy to reuse from package
tests. When `outputPath = NULL`, TestGenerator writes to that default
test case folder.

## Load the Test Population into a CDM

Use [`patientsCDM()`](../reference/patientsCDM.md) to create a CDM
reference containing the small patient population and a complete
vocabulary. By default, the CDM is created in DuckDB.

``` r

cdm <- patientsCDM(
  pathJson = output_path,
  testName = "icu_sample",
  cdmVersion = "5.4"
)

cdm[["person"]]
```

If `pathJson = NULL`, TestGenerator looks for JSON files in
`tests/testthat/testCases`.

``` r

cdm <- patientsCDM(
  pathJson = NULL,
  testName = "icu_sample",
  cdmVersion = "5.4"
)
```

## Use the CDM in Unit Tests

Once the test CDM is available, run the same study code you use on a
real CDM. The package includes example cohort definitions under
`inst/extdata/test_cohorts`.

``` r

library(CDMConnector)
library(dplyr)
library(testthat)

test_cohorts <- system.file(
  "extdata",
  "test_cohorts",
  package = "TestGenerator"
)

cohort_set <- readCohortSet(test_cohorts)

cdm <- generateCohortSet(
  cdm = cdm,
  cohortSet = cohort_set,
  name = "test_cohorts"
)

cohort_attrition <- attrition(cdm[["test_cohorts"]])

excluded_records <- cohort_attrition |>
  pull(excluded_records) |>
  sum()

expect_equal(excluded_records, 0)
```

In a package test, place this code in `tests/testthat/test-*.R` and
assert the specific counts, dates, durations, or intersections that your
study should produce for the micro population.

## Visualise Cohort Timelines

[`graphCohort()`](../reference/graphCohort.md) can help inspect whether
cohort intersections and timing look as expected for a single subject.

``` r

diazepam <- cdm[["test_cohorts"]] |>
  filter(cohort_definition_id == 1) |>
  collect()

hospitalisation <- cdm[["test_cohorts"]] |>
  filter(cohort_definition_id == 2) |>
  collect()

icu_visit <- cdm[["test_cohorts"]] |>
  filter(cohort_definition_id == 3) |>
  collect()

graphCohort(
  subject_id = 4,
  cohorts = list(
    diazepam = diazepam,
    hospitalisation = hospitalisation,
    icu_visit = icu_visit
  )
)
```

## Start from a Blank Excel Template

If you want to design a new test population from scratch, create an
Excel workbook with the required CDM table columns.

``` r

generateTestTables(
  tableNames = c(
    "person",
    "observation_period",
    "visit_occurrence",
    "condition_occurrence",
    "drug_exposure",
    "measurement"
  ),
  cdmVersion = "5.4",
  outputFolder = output_path,
  filename = "my_test_population"
)
```

Fill in the workbook rows for the small set of patients needed by your
test, then pass the completed workbook to
[`readPatients()`](../reference/readPatients.md).

## CSV Inputs

For CSV inputs, place one file per CDM table in a folder. File names
should match the table names, for example `person.csv` and
`observation_period.csv`.

``` r

csv_path <- system.file(
  "extdata",
  "mimic_sample",
  package = "TestGenerator"
)

readPatients.csv(
  filePath = csv_path,
  testName = "mimic_sample",
  outputPath = output_path,
  cdmVersion = "5.4"
)
```

For source datasets with very large integer identifiers, set
`reduceLargeIds = TRUE`.

## Remote Databases

DuckDB is the default and is usually enough for unit tests. When you
need to test SQL translation on another backend,
[`patientsCDM()`](../reference/patientsCDM.md) can also create a test
CDM in Spark, SQL Server, or PostgreSQL.

``` r

cdm <- patientsCDM(
  pathJson = output_path,
  testName = "icu_sample",
  cdmVersion = "5.4",
  dbms = "postgresql"
)

# Drop the remote test schema and disconnect when finished.
cleanupTestCdm(cdm)
```

Remote database connections require the relevant environment variables
to be configured before calling
[`patientsCDM()`](../reference/patientsCDM.md).

| Backend | Required environment variables |
|----|----|
| Spark | `DATABRICKS_HOST`, `DATABRICKS_TOKEN`, `DATABRICKS_HTTPPATH` |
| SQL Server | `DARWIN_SQLSERVER_SERVER`, `DARWIN_SQLSERVER_DBNAME`, `DARWIN_SQLSERVER_PORT`, `DARWIN_SQLSERVER_USER`, `DARWIN_SQLSERVER_PASSWORD` |
| PostgreSQL | `DARWIN_POSTGRESQL_SERVER`, `DARWIN_POSTGRESQL_DBNAME`, `DARWIN_POSTGRESQL_PORT`, `DARWIN_POSTGRESQL_USER`, `DARWIN_POSTGRESQL_PASSWORD` |

Spark also reads `DATABRICKS_USER` and `DATABRICKS_WORKSPACE` when they
are set. If they are not set, TestGenerator uses `token` as the
Databricks user and `hive_metastore` as the workspace/catalog. SQL
Server reads `SQL_SERVER_DRIVER` when it is set; otherwise it uses
`ODBC Driver 18 for SQL Server`.

## Clean Up

For local DuckDB examples, disconnect when the test has finished.

``` r

DBI::dbDisconnect(CDMConnector::cdmCon(cdm), shutdown = TRUE)
unlink(output_path, recursive = TRUE)
```
