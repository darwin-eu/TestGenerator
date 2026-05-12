# Release v0.8.0

## Description
This Pull Request merges the changes from `develop` to `main` for the release of version `0.8.0`. This release focuses on improving compatibility with remote databases like SQL Server and preventing database collisions through dynamic schema naming.

## Changes
Based on the `NEWS.md` updates:

### Bug Fixes
* Fixed missing `cdm_schema` attribute in `cdm_reference` when using remote databases (e_g., SQL Server).
* Fixed `patientsCDM()` to ensure the correct remote CDM reference is returned during the injection process.

### New Features
* Implemented dynamic, unique schema names (prefixed with `cdm_testgenerator_`) to prevent database collisions.

### Improvements & Testing
* Added regression tests to verify `cdm_schema` attribute presence and `CohortConstructor` compatibility on SQL Server.
* Removed `DARWIN_` prefix from environment variables to run tests on SQL Server and Postgres.

## Verification
* All tests in `tests/` passed.
* Verified compatibility with SQL Server and PostgreSQL environments.
