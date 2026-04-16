# Clean up a test CDM on a remote database

Drops the schema containing the test CDM and disconnects from the
database.

## Usage

``` r
cleanupTestCdm(cdm)
```

## Arguments

- cdm:

  A CDM reference object created by [`patientsCDM()`](patientsCDM.md)
  with a remote database backend.

## Value

Invisibly returns NULL.
