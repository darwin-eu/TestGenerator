# Create GitHub Action workflows for specific DBMS

Copies GitHub Action workflow templates from the package's
`inst/workflows` directory to the `.github/workflows` directory of the
current project. The copied workflows can be used to run
backend-specific tests for PostgreSQL, SQL Server, and Databricks.

## Usage

``` r
useGithubAction(
  dbms_type = c("postgresql", "sqlserver", "databricks"),
  overwrite = FALSE
)
```

## Arguments

- dbms_type:

  A character vector of supported DBMS types to process. Supported
  values are `"postgresql"`, `"sqlserver"`, and `"databricks"`.

- overwrite:

  A logical value indicating whether to overwrite existing workflow
  files in the `.github/workflows` directory. Defaults to `FALSE`.

## Value

Invisibly returns `TRUE` when the selected workflow files are copied
successfully.

## Examples

``` r
if (FALSE) { # \dontrun{
useGithubAction(dbms_type = "postgresql")
useGithubAction(
  dbms_type = c("postgresql", "sqlserver", "databricks"),
  overwrite = TRUE
)
} # }
```
