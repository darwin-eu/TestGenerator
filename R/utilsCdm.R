#' `emptyCDM()` truncates all the tables except those from the vocabulary for testing purposes
#'
#' @param conn A DBI connection
#' @param cdm A CDM reference object
#' @param cdmSchema CDM schema.
#'
#' @return A blank CDM with vocabulary
#' @import dplyr
#' @importFrom DBI dbConnect dbExecute
#' @importFrom CDMConnector downloadEunomiaData cdmFromCon
#' @export
emptyCDM <- function(conn, cdm, cdmSchema) {

  for (table_name in names(cdm)) {
    if (table_name %in% c("person",
                          "observation_period",
                          "visit_occurrence",
                          "visit_detail",
                          "condition_occurrence",
                          "drug_exposure",
                          "procedure_occurrence",
                          "device_exposure",
                          "measurement",
                          "observation",
                          "death",
                          "note",
                          "note_nlp",
                          "specimen",
                          "fact_relationship",
                          "location",
                          "care_site",
                          "provider",
                          "payer_plan_period",
                          "cost",
                          "drug_era",
                          "dose_era",
                          "condition_era",
                          "metadata",
                          "cdm_source")) {
      DBI::dbExecute(conn, glue::glue("TRUNCATE TABLE {table_name}"))
    }
  }
  return(cdm)
}

