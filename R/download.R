downloadTestData <- function(datasetName = "mimicIV",
                             cdmVersion = "5.3",
                             pathToData = Sys.getenv("STUDY_DATASETS"),
                             overwrite = FALSE) {
  checkmate::assertChoice(datasetName, choices = studyDatasets())
  if (cdmVersion != "5.3") {
    rlang::abort("Only CDM v5.3 is supported currently!")
  }
  if (is.null(pathToData) || is.na(pathToData) || pathToData == "") {
    stop("The pathToData argument must be specified. Consider setting the TEST_DATASETS environment variable, for example in the .Renviron file.")
  }
  if (!dir.exists(pathToData)) {
    dir.create(pathToData, recursive = TRUE)
  }
  zipName <- glue::glue("{datasetName}.zip")
  if (file.exists(file.path(pathToData, zipName)) && !overwrite) {
    rlang::inform(glue::glue("Dataset already exists ({file.path(pathToData, zipName)})\n      Specify `overwrite = TRUE` to overwrite existing zip archive"))
    return(invisible(pathToData))
  }
  pb <- cli::cli_progress_bar(format = "[:bar] :percent :elapsed",
                              type = "download")
  withr::with_options(list(timeout = 5000), {
    utils::download.file(url = "https://physionet.org/static/published-projects/mimic-iv-demo-omop/mimic-iv-demo-data-in-the-omop-common-data-model-0.9.zip",
                         destfile = file.path(pathToData, zipName), mode = "wb",
                         method = "auto", quiet = FALSE, extra = list(progressfunction = function(downloaded, total) {
                           progress <- min(1, downloaded/total)
                           cli::cli_progress_update(id = pb, set = progress)
                         }))
  })
  cli::cli_progress_done(id = pb)
  cat("\nDownload completed!\n")
  pathToFile <- file.path(pathToData, zipName)
  return(pathToFile)
}

studyDatasets <- function() {
  c("mimicIV")
}
