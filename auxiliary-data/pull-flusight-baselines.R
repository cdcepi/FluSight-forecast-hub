
#name
#pull_flusight_baselines

library(lubridate)

# Get last Saturday
current_ref_date <- ceiling_date(Sys.Date(), "week") - days(1)
date_str <- format(current_ref_date, "%Y-%m-%d")

# Define baseline types (same for folder name and file type)
baseline_types <- c("FluSight-baseline", "FluSight-base_seasonal", "FluSight-equal_cat")
baseline_folders <- c("Flusight-baseline", "Flusight-seasonal-baseline", "Flusight-equal_cat")

# Loop through each type
for (type in baseline_types) {
  filename <- paste0(date_str, "-", type, ".csv")
  
  # Construct file URL - now using type in the GitHub path
  file_url <- paste0(
    "https://raw.githubusercontent.com/cdcepi/Flusight-baseline/main/weekly-submission/forecasts/",
    type, "/", filename
  )
  
  # Construct local path - also saving to folder by type
  target_dir <- file.path("model-output", type)
  dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
  destfile <- file.path(target_dir, filename)
  
  # Attempt download
  download_success <- tryCatch({
    download.file(url = file_url, destfile = destfile, method = "libcurl")
    cat("✅ Saved:", destfile, "\n")
    TRUE
  }, error = function(e) {
    cat("❌ Failed to download", filename, "\nReason:", e$message, "\n")
    FALSE
  })
}



# 
# library(lubridate)
# 
# # Get last Saturday
# current_ref_date <- ceiling_date(Sys.Date(), "week") - days(1)
# date_str <- format(current_ref_date, "%Y-%m-%d")
# 
# # Build the path
# file_path <- paste0("https://raw.githubusercontent.com/cdcepi/Flusight-baseline/main/weekly-submission/forecasts/", date_str, "-FluSight-baseline.csv")
# 
# # Read the file
# df <- read.csv(file_path)

