# Changelog

## TestGenerator 0.6.0

- Support other database types next to duckdb: sqlserver and databricks

- Remove dependency on arrow

- [`generateTestTables()`](../reference/generateTestTables.md) creates
  the most common used tables in the Excel sheet by default

## TestGenerator 0.5.0

CRAN release: 2026-01-14

- Support cdm version 5.4, this requires the latest version of
  CDMConnector

## TestGenerator 0.4.0

CRAN release: 2025-05-27

- Extra tables can be added through
  [`readPatients.xl()`](../reference/readPatients.xl.md), that table
  then is pushed to “other tables” in the CDM reference using
  [`patientsCDM()`](../reference/patientsCDM.md).

## TestGenerator 0.3.3

CRAN release: 2024-11-08

- `generateTestTable()` creates an Excel file with sheets that
  correspond to OMOP-CDM tables.

- [`patientsCDM()`](../reference/patientsCDM.md) now accepts `cdmName`
  as argument to allow for custom cdm name.

- `getEmptyCDM()` returns an empty cdm object.

## TestGenerator 0.3.2

- Fixed bug related to empty tables pushed to the duckdb CDM.

## TestGenerator 0.3.1

CRAN release: 2024-05-28

- [`readPatients()`](../reference/readPatients.md) now has a parameter
  to select either Excel or CSV files as an input.

- [`readPatients.xl()`](../reference/readPatients.xl.md) and
  `readPatients.csv` are also exported functions for convenience.

- [`graphCohort()`](../reference/graphCohort.md) provides a
  visualisation of cohort timelines.

- JSONS are saved in the testthat/testCases folder as default for better
  test self-containment.

- Tested with MIMIC database.

## TestGenerator 0.2.5

CRAN release: 2024-02-01

- Using omopgenerics for checking Excel data.

## TestGenerator 0.2.4

- Updated DESCRIPTION.

## TestGenerator 0.2.3

- Updated examples.

## TestGenerator 0.2.2

- Updated messages in functions.

## TestGenerator 0.2.1

- Updated documentation and vignette explaining sample data.

## TestGenerator 0.2.0

- Initial CRAN submission.

## TestGenerator 0.1.0

- Tests passed and finishes documentation.
