
<!-- README.md is generated from README.Rmd. Please edit that file -->

# TestGenerator

<!-- badges: start -->

[![R-CMD-check](https://github.com/darwin-eu-dev/TestGenerator/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/darwin-eu-dev/TestGenerator/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/github/darwin-eu-dev/TestGenerator/branch/main/graph/badge.svg)](https://app.codecov.io/github/darwin-eu-dev/TestGenerator?branch=main)
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
patients.

    #> Unit Test Definition created successfully: test
    #> ! cdm name not specified and could not be inferred from the cdm source table
    #> Patients pushed to blank CDM successfully
    #> 
    #> ── # OMOP CDM reference (duckdb) of An OMOP CDM database ───────────────────────
    #> • omop tables: person, observation_period, visit_occurrence, visit_detail,
    #> condition_occurrence, drug_exposure, procedure_occurrence, device_exposure,
    #> measurement, observation, death, note, note_nlp, specimen, fact_relationship,
    #> location, care_site, provider, payer_plan_period, cost, drug_era, dose_era,
    #> condition_era, metadata, cdm_source, concept, vocabulary, domain,
    #> concept_class, concept_relationship, relationship, concept_synonym,
    #> concept_ancestor, source_to_concept_map, drug_strength, cohort_definition,
    #> attribute_definition
    #> • cohort tables: -
    #> • achilles tables: -
    #> • other tables: -

The user can test a study using the cdm object and the related schemas
like this:

``` r
runStudy(conn = attr(cdm, "dbcon"),
         cdmDatabaseSchema = "main",
         resultsDatabaseSchema = "main",
         dbName = "myTestDB",
         minCellCount = 5)
```
