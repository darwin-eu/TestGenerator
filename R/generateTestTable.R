#' Generates an Excel file with sheets that correspond to an OMOP-CDM tables.
#'
#' @return An Excel file
#' @export
#'
#' @examples
generateTestTables <- function(tableNames, cdmVersion, outputFolder) {

  if(!(cdmVersion %in% c("5.3", "5.4"))){
    stop("Invalid cdm version should be 5.3 or 5.4")
  }

  tableNames <- tolower(tableNames)

  cdmSpecificationPath <- system.file("cdmTableSpecifications", paste0("emptycdm_", cdmVersion), package = "TestGenerator")
  # check table names
  fileNames <- tolower(tools::file_path_sans_ext(basename(list.files(path = cdmSpecificationPath, full.names = TRUE))))


  toExclude <- c("concept", "concept_ancestor", "concept_class", "concept_cpt4", "concept_relationship", "concept_synonym", "domain", "drug_strength", "relationship", "vocabulary")

  fileNames <- setdiff(fileNames, toExclude)

  invalidTableNames <-setdiff(tableNames, fileNames)

  if (length(invalidTableNames) > 0) {
    stop(paste("The following filenames are invalid:", paste0(invalidTableNames, collapse = ", ")))
  }

  if (!dir.exists(outputFolder)) {
    dir.create(outputFolder, recursive = TRUE)
  }

  # output path for excel file
  excelFileOutPath <- file.path(outputFolder, paste0("test_cdm_", cdmVersion, ".xlsx"))

  wb <- openxlsx::createWorkbook()

  for(tableName in tableNames){

    # path to parquet file
    file <- file.path(cdmSpecificationPath, paste0(tableName, ".parquet"))

    parquetFile <- arrow::read_parquet(file)

    openxlsx::addWorksheet(wb,  tableName)
    openxlsx::writeData(wb, sheet = tableName, parquetFile)
  }

  # save the workbook
  openxlsx::saveWorkbook(wb, excelFileOutPath, overwrite = TRUE)
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
