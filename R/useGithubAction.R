#' Create GitHub Action workflows for specific DBMS
#'
#' Copies GitHub Action workflow templates from the package's
#' \code{inst/workflows} directory to the \code{.github/workflows} directory of
#' the current project. The copied workflows can be used to run backend-specific
#' tests for PostgreSQL, SQL Server, and Databricks.
#'
#' @param dbms_type A character vector of supported DBMS types to process.
#'   Supported values are \code{"postgresql"}, \code{"sqlserver"}, and
#'   \code{"databricks"}.
#' @param overwrite A logical value indicating whether to overwrite existing
#'   workflow files in the \code{.github/workflows} directory. Defaults to
#'   \code{FALSE}.
#'
#' @return Invisibly returns \code{TRUE} when the selected workflow files are
#'   copied successfully.
#'
#' @importFrom checkmate assertCharacter assertDirectoryExists
#' @importFrom fs path_file
#' @importFrom stringr str_subset
#' @importFrom usethis proj_path
#'
#' @examples
#' \dontrun{
#' useGithubAction(dbms_type = "postgresql")
#' useGithubAction(
#'   dbms_type = c("postgresql", "sqlserver", "databricks"),
#'   overwrite = TRUE
#' )
#' }
#'
#' @export
useGithubAction <- function(
  dbms_type = c(
    "postgresql",
    "sqlserver",
    "databricks"
  ),
  overwrite = FALSE
) {

  check_supported_dbms(dbms_type)
  origin_workflows_folder <- system.file(
    "workflows",
    package = "TestGenerator"
  )
  checkmate::assertDirectoryExists(
    origin_workflows_folder
    )
  origin_file_names <- list.files(
    origin_workflows_folder,
    full.names = TRUE
  )
  destination_workflows_dir <- usethis::proj_path(
    ".github",
    "workflows"
  )
  create_dir(destination_workflows_dir)

  for (i in seq_along(dbms_type)) {
    origin_path <- stringr::str_subset(
      origin_file_names,
      dbms_type[i]
    )
    destination_path <- file.path(
      destination_workflows_dir,
      fs::path_file(origin_path)
      )
    checkmate::assertDirectoryExists(destination_workflows_dir)
    copy_status <- file.copy(
      origin_path,
      destination_path,
      overwrite = overwrite
    )
    if (isTRUE(copy_status) & isTRUE(file.exists(destination_path))) {
      cli::cli_alert_success(
        glue::glue(
          "{fs::path_file(origin_path)} inserted to {destination_workflows_dir}"
        )
      )
      } else if (isFALSE(copy_status) & isTRUE(file.exists(destination_path))) {
        stop(
          cli::cli_alert_danger(
            glue::glue(
              "{fs::path_file(origin_path)} workflow already exists in {destination_workflows_dir}"
              )
            )
        )
      } else if (isTRUE(copy_status) & isFALSE(file.exists(destination_path))) {
        stop(
          cli::cli_alert_danger(
            glue::glue(
              "{fs::path_file(origin_path)} was copied but not to {destination_workflows_dir}"
            )
          )
        )
      }
  }
  invisible(TRUE)
}

create_dir <- function(path) {
  if (dir.exists(path)) {
    return(invisible(FALSE))
  }
  else if (file_exists(path)) {
    stop(
      glue::glue(
        "{path} exists but is not a directory"
        )
      )
  }
  dir.create(
    path,
    recursive = TRUE
    )
  cli::cli_alert_success(
    glue::glue(
      "Creating {path}"
      )
  )
  invisible(TRUE)
}

check_supported_dbms <- function(dbms_type) {
  checkmate::assertCharacter(dbms_type)
  for (i in 1:length(dbms_type)) {
    if (!dbms_type[i] %in% c("postgresql", "sqlserver", "databricks")) {
      stop(
        cli::cli_alert_danger(
          glue::glue(
            "{dbms_type[i]} is not a supported DBMS"
            )
        )
      )
    }
    }
  invisible(TRUE)
}
