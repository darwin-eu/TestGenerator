library(utils)

# filePath <- testthat::test_path("mimic_sample")
# csv_files <- list.files(filePath, pattern = ".csv", full.names = TRUE)

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

sample_csv_files <- function(csv_files) {
  for (file_csv in csv_files) {
    new_file <- subset_csv_sample(file_csv, sample_size = 100)
    write.csv(new_file, file_csv, row.names = FALSE)
  }
}

# sample_csv_files(csv_files)
