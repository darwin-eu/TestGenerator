#' Read a parquet file using DuckDB.
#' @param file Path to the parquet file.
#' @return A data frame.
#' @noRd
read_parquet_file <- function(file) {
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  path_sql <- gsub("'", "''", path.expand(file))
  DBI::dbGetQuery(con, paste0("SELECT * FROM read_parquet('", path_sql, "')"))
}

#' Generates an Excel file with sheets that correspond to an OMOP-CDM tables.
#'
#' @param tableNames A list specifying the table names to include in the Excel file.
#' @param cdmVersion The CDM version to use for creating the requested tables (either 5.3 or 5.4).
#' @param outputFolder The folder where the Excel file will be saved.
#' @param filename The name of the Excel file. It does not include the extension .xlsx.
#'
#' @return An Excel file with the tables requested.
#' @export
#' @importFrom openxlsx createWorkbook addWorksheet writeData saveWorkbook
generateTestTables <- function(
    tableNames = c("person", "observation_period", "visit_occurrence",
                   "visit_detail", "condition_occurrence", "drug_exposure",
                   "procedure_occurrence", "measurement", "observation", "death",
                   "drug_era", "condition_era", "dose_era", "location", "care_site",
                   "provider"),
    cdmVersion,
    outputFolder,
    filename = paste0(
      "test_cdm_",
      cdmVersion
      )
    ) {

  if(!(cdmVersion %in% c("5.3", "5.4"))){
    stop("Invalid cdm version should be 5.3 or 5.4")
  }

  tableNames <- tolower(tableNames)

  cdmSpecificationPath <- system.file("cdmTableSpecifications", paste0("emptycdm_", cdmVersion), package = "TestGenerator")
  # check table names
  fileNames <- tolower(tools::file_path_sans_ext(basename(list.files(path = cdmSpecificationPath, full.names = TRUE))))


  toExclude <- c("concept",
                 "concept_ancestor",
                 "concept_class",
                 "concept_cpt4",
                 "concept_relationship",
                 "concept_synonym",
                 "domain",
                 "drug_strength",
                 "relationship",
                 "vocabulary")

  fileNames <- setdiff(fileNames, toExclude)

  invalidTableNames <-setdiff(tableNames, fileNames)

  if (length(invalidTableNames) > 0) {
    stop(paste("The following filenames are invalid:", paste0(invalidTableNames, collapse = ", ")))
  }

  if (!dir.exists(outputFolder)) {
    dir.create(outputFolder, recursive = TRUE)
  }

  # output path for excel file
  excelFileOutPath <- file.path(outputFolder, paste0(filename, ".xlsx"))

  wb <- openxlsx::createWorkbook()

  for(tableName in tableNames){

    # path to parquet file
    file <- file.path(cdmSpecificationPath, paste0(tableName, ".parquet"))

    parquetFile <- read_parquet_file(file)

    openxlsx::addWorksheet(wb,  tableName)
    openxlsx::writeData(wb, sheet = tableName, parquetFile)
  }

  # save the workbook
  openxlsx::saveWorkbook(wb, excelFileOutPath, overwrite = TRUE)
}
