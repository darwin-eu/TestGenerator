# Generates an Excel file with sheets that correspond to an OMOP-CDM tables.

Generates an Excel file with sheets that correspond to an OMOP-CDM
tables.

## Usage

``` r
generateTestTables(
  tableNames = c("person", "observation_period", "visit_occurrence", "visit_detail",
    "condition_occurrence", "drug_exposure", "procedure_occurrence", "measurement",
    "observation", "death", "drug_era", "condition_era", "dose_era", "location",
    "care_site", "provider"),
  cdmVersion,
  outputFolder,
  filename = paste0("test_cdm_", cdmVersion)
)
```

## Arguments

- tableNames:

  A list specifying the table names to include in the Excel file.

- cdmVersion:

  The CDM version to use for creating the requested tables (either 5.3
  or 5.4).

- outputFolder:

  The folder where the Excel file will be saved.

- filename:

  The name of the Excel file. It does not include the extension .xlsx.

## Value

An Excel file with the tables requested.
