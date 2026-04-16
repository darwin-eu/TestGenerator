# Converts a sample of patients into Unit Testing Definition JSON file.

Converts a sample of patients into Unit Testing Definition JSON file.

## Usage

``` r
readPatients(
  filePath = NULL,
  testName = "test",
  outputPath = NULL,
  cdmVersion = "5.4",
  extraTable = FALSE
)
```

## Arguments

- filePath:

  Path to the test patient data in Excel format. The Excel has sheets
  that represent tables from the OMOP-CDM, e.g. person, drug_exposure,
  condition_ocurrence, etc.

- testName:

  A name of the test population in character.

- outputPath:

  Path of the output file, if NULL, a folder will be created in the
  project folder inst/testCases.

- cdmVersion:

  cdm version, default "5.4".

- extraTable:

  Name of non-standard tables to be included in the test CDM.

## Value

A JSON file with sample patients inside the project directory.

## Examples

``` r
filePath <- system.file("extdata", "testPatientsRSV.xlsx", package = "TestGenerator")
readPatients(filePath = filePath, outputPath = tempdir())
#> ✔ All tables are valid
#> ✔ Unit Test Definition Created Successfully: 'test'
```
