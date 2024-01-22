
<!-- README.md is generated from README.Rmd. Please edit that file -->

# TestGenerator

<!-- badges: start -->

[![R-CMD-check](https://github.com/darwin-eu-dev/TestGenerator/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/darwin-eu-dev/TestGenerator/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/github/darwin-eu-dev/TestGenerator/branch/main/graph/badge.svg)](https://app.codecov.io/github/darwin-eu-dev/TestGenerator?branch=main)
<!-- badges: end -->

Does my cohort picked the correct number patients? Am I calculating an
intersection in the right way? Is that the expected value for treatment
duration? It just takes one incorrect parameter to get incoherent
results in a pharmacoepidemiological study, and it is challenging to
test calculations on huge and complex databases.

That is why TestGenerator is useful to push a micro sample of around 10
patients to unit test a study on the OMOP-CDM. It includes tools to
create a blank CDM with a complete vocabulary and check if the code is
doing what we expect.

This package is based on the unit testing written for the [Eramus MC
Ranitidine
Study](https://github.com/mi-erasmusmc/RanitidineStudy/blob/master/unitTesting_README.md).

## Installation

You can install the development version of TestGenerator from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("darwin-eu-dev/TestGenerator")
```

## Example

The user should provide an Excel file with a micro population of around
10 patients for testing purposes. That can include any table from the
OMOP-CDM.

`readPatients()` will read the Excel file, and saves the data in a JSON
file. This is useful if the user wants to create more than one Unit Test
Definitions.

``` r
TestGenerator::readPatients(
  filePath = "~/pathto/testPatients.xlsx",
  testName = "test",
  outputPath = "inst/testCases"
)
```

`patientCDM()` pushes one of those Unit Test Definitions into a blank
CDM reference with a complete version of the vocabulary.

``` r
cdm <- TestGenerator::patientCDM(
  pathJson = "inst/testCases", 
  testName = "test")
```

Now the user has a CDM reference with a complete vocabulary and a
universe of just 10 patients to unit test functions of a particular
study.
