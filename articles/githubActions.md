# GitHub Actions

TestGenerator can create GitHub Actions workflows for backend-specific
package tests. The goal is to make continuous integration check that
your package works against PostgreSQL, SQL Server, and Databricks/Spark,
not only against a local DuckDB test CDM.

## Create the workflow files

Create all supported workflows with:

``` r

library(TestGenerator)

useGithubAction(overwrite = TRUE)
```

Or create only the workflow you need:

``` r

useGithubAction(dbms_type = "postgresql", overwrite = TRUE)
useGithubAction(dbms_type = "sqlserver", overwrite = TRUE)
useGithubAction(dbms_type = "databricks", overwrite = TRUE)
```

The function writes workflow files to `.github/workflows`. Commit those
files to your repository so GitHub Actions can run them.

## Add the expected test files

The workflow templates run fixed test file names. Your package must
provide the file for each backend you enable:

| Backend          | Required test file                 |
|------------------|------------------------------------|
| PostgreSQL       | `tests/testthat/test-postgresql.R` |
| SQL Server       | `tests/testthat/test-sqlserver.R`  |
| Databricks/Spark | `tests/testthat/test-databricks.R` |

Each test file should call your package code, create the test CDM with
`patientsCDM(dbms = ...)`, run the study logic, and use `testthat`
expectations to check the result. If a test has an error or a failed
expectation, the action is intended to fail.

## PostgreSQL and SQL Server actions

For PostgreSQL and SQL Server, the GitHub Actions workflow creates a
Docker container inside the action run. That means users do not need to
configure database secrets for these two workflows.

The action sets the connection environment variables itself and tests
against the temporary container. This makes these two workflows useful
for routine CI, because each run starts from a fresh database service.

## Databricks action

For Databricks, the action connects to your own remote Databricks
workspace. You must configure the required repository secrets in GitHub:

| GitHub secret         | Purpose                            |
|-----------------------|------------------------------------|
| `DATABRICKS_HOST`     | URL of the Databricks workspace    |
| `DATABRICKS_TOKEN`    | Token used to connect              |
| `DATABRICKS_HTTPPATH` | SQL warehouse or cluster HTTP path |

Optional Databricks secrets are:

| GitHub secret | Default when not set |
|----|----|
| `DATABRICKS_WORKSPACE` | `hive_metastore` |
| `DATABRICKS_ODBC_DRIVER_URL` | The default Simba Spark ODBC driver URL used by the workflow |

Because Databricks uses a real remote workspace, make sure the token has
enough permission to create schemas and tables, insert the test data,
query the result, and remove the test schema afterwards.

## Suggested CI workflow

Start with PostgreSQL or SQL Server first, because those workflows
create their own database containers and do not require external
credentials. Add Databricks after you have confirmed that the remote
workspace, token, and HTTP path work from GitHub Actions.

Keep the backend-specific tests small and deterministic. A good CI test
should load a small Unit Test Definition, run one important part of your
package logic, and assert the expected counts, dates, or cohort records.

For release preparation, these backend-specific workflows can also act
as a quality gate. In `darwin-eu-dev/TestGenerator`, the
`CRAN-release-check` workflow only continues when the same `develop`
commit already has successful runs for `R-CMD-check`,
`R Package Tests (PostgreSQL)`, `R Package Tests (Spark Databricks)`,
and `R Package Tests (SQL Server)`. This means the CRAN checks are run
on a commit that has already been tested against the supported database
backends.
