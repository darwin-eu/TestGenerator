# TestGenerator 0.7.1

* Fixed missing `cdm_schema` attribute in `cdm_reference` when using remote databases (e.g., SQL Server).
* Implemented dynamic, unique schema names (prefixed with `cdm_testgenerator_`) to prevent database collisions.
* Fixed `patientsCDM()` to ensure the correct remote CDM reference is returned during the injection process.
* Added regression tests to verify `cdm_schema` attribute presence and `CohortConstructor` compatibility on SQL Server.
* Removed `DARWIN_` prefix from environment variables to run tests on SQL Server and Postgres.

# TestGenerator 0.7.0


* Support for PostgreSQL as a DBMS in `patientsCDM()`

* Added `RPostgres` to `Imports`

* Added `skip_on_cran()` to several tests to avoid network dependencies during `R CMD check`

* Updated `.gitignore` and `.Rbuildignore`

# TestGenerator 0.6.0

* Support other database types next to duckdb: sqlserver and databricks

* Remove dependency on arrow

* `generateTestTables()` creates the most common used tables in the Excel sheet by default

# TestGenerator 0.5.0

* Support cdm version 5.4, this requires the latest version of CDMConnector

# TestGenerator 0.4.0

* Extra tables can be added through `readPatients.xl()`, that table then is pushed to "other tables" in the CDM reference using `patientsCDM()`.

# TestGenerator 0.3.3

* `generateTestTable()` creates an Excel file with sheets that correspond to OMOP-CDM tables.

* `patientsCDM()` now accepts `cdmName` as argument to allow for custom cdm name.

* `getEmptyCDM()` returns an empty cdm object.

# TestGenerator 0.3.2

* Fixed bug related to empty tables pushed to the duckdb CDM.

# TestGenerator 0.3.1

* `readPatients()` now has a parameter to select either Excel or CSV files as an input. 

* `readPatients.xl()` and `readPatients.csv` are also exported functions for convenience.

* `graphCohort()` provides a visualisation of cohort timelines.

* JSONS are saved in the testthat/testCases folder as default for better test self-containment.

* Tested with MIMIC database.

# TestGenerator 0.2.5

* Using omopgenerics for checking Excel data.

# TestGenerator 0.2.4

* Updated DESCRIPTION.

# TestGenerator 0.2.3

* Updated examples.

# TestGenerator 0.2.2

* Updated messages in functions.

# TestGenerator 0.2.1

* Updated documentation and vignette explaining sample data.

# TestGenerator 0.2.0

* Initial CRAN submission.

# TestGenerator 0.1.0

* Tests passed and finishes documentation.
