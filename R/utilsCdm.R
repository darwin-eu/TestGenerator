emptyCDM <- function(conn, cdm) {

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

sample_csv_files <- function(csv_files) {
  for (file_csv in csv_files) {
    new_file <- subset_csv_sample(file_csv, sample_size = 100)
    write.csv(new_file, file_csv, row.names = FALSE)
  }
}

subset_csv_sample <- function(file_csv, sample_size = 100) {
  # Read the full CSV file
  full_data <- read.csv(file_csv)
  # Check if the data has enough rows
  if(nrow(full_data) <= sample_size) {
    warning("The dataset contains equal to or less than the sample size. Returning full dataset.")
    return(full_data)
  }
  # Sample row indices
  sample_indices <- sample(nrow(full_data), size = sample_size)
  # Subset the data using sampled indices
  sampled_data <- full_data[sample_indices, ]
  return(sampled_data)
}

