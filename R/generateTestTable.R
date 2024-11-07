#' Generates an Excel file with sheets that correspond to an OMOP-CDM tables.
#'
#' @return An Excel file
#' @export
#'
#' @examples
generateTestTable <- function(outputPath) {

}


getEmptyCDM <- function() {

  vocabPath <- file.path(Sys.getenv("EUNOMIA_DATA_FOLDER"),
                         glue::glue("empty_cdm_{cdmVersion}.zip"))

  if (!file.exists(vocabPath)) {
    CDMConnector::downloadEunomiaData(datasetName = "empty_cdm",
                                      cdmVersion = cdmVersion,
                                      pathToData = Sys.getenv("EUNOMIA_DATA_FOLDER"),
                                      overwrite = TRUE)
  }

  conn <- DBI::dbConnect(duckdb::duckdb(CDMConnector::eunomia_dir("empty_cdm")))
  cdm <- CDMConnector::cdmFromCon(con = conn,
                                  cdmSchema = "main",
                                  writeSchema = "main",
                                  cdmName = cdmName)

  return(cdm)

}
