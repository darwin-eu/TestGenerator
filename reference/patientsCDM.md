# Pushes test population into a blank CDM.

Pushes test population into a blank CDM.

## Usage

``` r
patientsCDM(
  pathJson = NULL,
  testName = NULL,
  cdmVersion = "5.4",
  cdmName = NULL,
  dbms = "duckdb",
  writeSchema = NULL
)
```

## Arguments

- pathJson:

  Directory where the sample populations in json are located. If NULL,
  gets the default inst/testCases directory.

- testName:

  Name of the sample population JSON file. If NULL it will push the
  first sample population in the testCases directory.

- cdmVersion:

  cdm version, default "5.4".

- cdmName:

  Name of the cdm, default NULL.

- dbms:

  Database management system to use. One of "duckdb", "spark", or
  "sqlserver". Default is "duckdb" which creates a local DuckDB CDM. For
  remote databases the function creates the CDM locally, trims the
  vocabulary, uploads to a new schema on the remote database, and
  returns the remote CDM reference. Remote databases require environment
  variables to be set. Call
  [`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html)
  to set them.

- writeSchema:

  Optional schema name to use on the remote database. If NULL (default),
  a unique schema is created automatically. Only used when `dbms` is not
  "duckdb".

## Value

A CDM reference object with a sample population.

## Examples

``` r
# \donttest{
filePath <- system.file("extdata", "testPatientsRSV.xlsx", package = "TestGenerator")
TestGenerator::readPatients(filePath = filePath, outputPath = tempdir())
#> ✔ All tables are valid
#> ✔ Unit Test Definition Created Successfully: 'test'
cdm <- TestGenerator::patientsCDM(pathJson = tempdir(), testName = "test")
#> 
#> Download completed!
#> Creating CDM database /tmp/RtmpXMngaM/empty_cdm_5.4.zip
#> ■■■■■■■■■■■■■■■■■■■■■             65% | ETA:  2s
#> ■■■■■■■■■■■■■■■■■■■■■■■■          77% | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■         81% | ETA:  3s
#> ! cdm name not specified and could not be inferred from the cdm source table
#> ✔ Standard table(s) in test data: person, observation_period, condition_occurrence, visit_occurrence, visit_detail and death
#> ✔ Patients pushed to blank CDM successfully
duckdb::duckdb_shutdown(duckdb::duckdb())
# }
```
