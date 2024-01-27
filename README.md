
<!-- README.md is generated from README.Rmd. Please edit that file -->

# TestGenerator

<!-- badges: start -->

[![R-CMD-check](https://github.com/darwin-eu-dev/TestGenerator/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/darwin-eu-dev/TestGenerator/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/darwin-eu-dev/TestGenerator/branch/main/graph/badge.svg)](https://codecov.io/gh/darwin-eu-dev/TestGenerator)
[![CRAN
status](https://www.r-pkg.org/badges/version/TestGenerator)](https://CRAN.R-project.org/package=TestGenerator)
<!-- badges: end -->

Does my cohort picked the correct number patients? Am I calculating an
intersection in the right way? Is that the expected value for treatment
duration? It just takes one incorrect parameter to get incoherent
results in a pharmacoepidemiological study, and it is very challenging
to test calculations on huge and complex databases.

That is why TestGenerator is useful to push a micro sample of around 10
patients to unit test a study on the OMOP-CDM. It includes tools to
create a blank CDM with a complete vocabulary and check if the code is
doing what we expect.

This package is based on the unit testing written for the [Eramus MC
Ranitidine
Study](https://github.com/mi-erasmusmc/RanitidineStudy/blob/master/unitTesting_README.md).

## Installation

To install the development version of TestGenerator:

``` r
# Development version
remotes::install_github("darwin-eu-dev/TestGenerator")
```

## Example

The user should provide an Excel file [(link to
sample)](https://github.com/darwin-eu-dev/TestGenerator/raw/main/inst/extdata/testPatientsRSV.xlsx)
with a micro population of around 10 patients for testing purposes. That
can include any table from the OMOP-CDM.

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
cdm <- TestGenerator::patientsCDM(
  pathJson = "inst/testCases", 
  testName = "test")
```

Now the user has a CDM reference with a complete vocabulary and just 10
patients to unit test functions of a particular study.

    #> Unit Test Definition created successfully: test
    #> Patients pushed to blank CDM successfully
    #> # OMOP CDM reference (tbl_duckdb_connection)
    #> 
    #> Tables: person, observation_period, visit_occurrence, visit_detail, condition_occurrence, drug_exposure, procedure_occurrence, device_exposure, measurement, observation, death, note, note_nlp, specimen, fact_relationship, location, care_site, provider, payer_plan_period, cost, drug_era, dose_era, condition_era, metadata, cdm_source, concept, vocabulary, domain, concept_class, concept_relationship, relationship, concept_synonym, concept_ancestor, source_to_concept_map, drug_strength, cohort_definition, attribute_definition

    #> # Source:   table<person> [?? x 18]
    #> # Database: DuckDB v0.9.1 [cbarboza@Windows 10 x64:R 4.3.1/C:\Users\cbarboza\AppData\Local\Temp\Rtmpyk7YO6\file1b60470f3ac1.duckdb]
    #>    person_id gender_concept_id year_of_birth month_of_birth day_of_birth
    #>        <int>             <int>         <int>          <int>        <int>
    #>  1         1              8532          1980             NA           NA
    #>  2         2              8507          1980             NA           NA
    #>  3         3              8532          1965             NA           NA
    #>  4         4              8532          2010             NA           NA
    #>  5         5              8532          1936             NA           NA
    #>  6         6              8532          1970             NA           NA
    #>  7         7              8532          1988             NA           NA
    #>  8         8              8507          1998             NA           NA
    #>  9         9              8507          1990             NA           NA
    #> 10        10              8532          1945             NA           NA
    #> # ℹ more rows
    #> # ℹ 13 more variables: birth_datetime <dttm>, race_concept_id <int>,
    #> #   ethnicity_concept_id <int>, location_id <int>, provider_id <int>,
    #> #   care_site_id <int>, person_source_value <chr>, gender_source_value <chr>,
    #> #   gender_source_concept_id <int>, race_source_value <chr>,
    #> #   race_source_concept_id <int>, ethnicity_source_value <chr>,
    #> #   ethnicity_source_concept_id <int>
