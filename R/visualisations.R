#' Deprecated cohort timeline visualisation
#'
#' @description
#' `graphCohort()` is deprecated and will be removed in a future release.
#'
#' @param subject_id Deprecated.
#' @param cohorts Deprecated.
#'
#' @return Invisibly returns `NULL`.
#' @export
graphCohort <- function(subject_id, cohorts = list()) {
  .Deprecated(
    msg = "`graphCohort()` is deprecated and will be removed in a future release."
  )
  invisible(NULL)
}
