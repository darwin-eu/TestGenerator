# Converts a sample of patients in XLSX format into Unit Testing Definition JSON file.

Converts a sample of patients in XLSX format into Unit Testing
Definition JSON file.

## Usage

``` r
readPatients.xl(
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

  Path to write the test JSON files. If NULL, the files will be written
  at the project's testthat folder, i.e. tests/testthat/testCases.

- cdmVersion:

  cdm version, default "5.4".

- extraTable:

  TRUE or FALSE. If TRUE, non-standard tables will be included in the
  test CDM.

## Value

A directory with the test JSON files with sample patients inside the
project directory.

## Examples

``` r
filePath <- system.file("extdata", "testPatientsRSV.xlsx", package = "TestGenerator")
readPatients.xl(filePath = filePath, outputPath = tempdir())
#> ✔ All tables are valid
#> ✔ Unit Test Definition Created Successfully: 'test'
```
