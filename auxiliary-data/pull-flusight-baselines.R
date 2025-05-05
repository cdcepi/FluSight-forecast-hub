
# Script that runs with the Pull baselines action to download and save the weekly baselines from the FluSight-baseline repository.
# Retrieves specifically FluSight-baseline, FluSight-base_seasonal, and FluSight-equal_cat.

# load package
library(lubridate)

# Get last Saturday
current_ref_date <- ceiling_date(Sys.Date(), "week") - days(1)
date_str <- format(current_ref_date, "%Y-%m-%d")

# Types and their source folders
baseline_types <- c("FluSight-baseline", "FluSight-base_seasonal", "FluSight-equal_cat")
baseline_folders <- c("Flusight-baseline", "Flusight-seasonal-baseline", "Flusight-equal_cat")

# Loop and download each one
for (i in seq_along(baseline_types)) {
  type <- baseline_types[i]
  folder <- baseline_folders[i]
  filename <- paste0(date_str, "-", type, ".csv")
  
  # Corrected file URL
  file_url <- paste0(
    "https://raw.githubusercontent.com/cdcepi/Flusight-baseline/main/weekly-submission/forecasts/",
    folder, "/", filename
  )
  
  # Save to model-output/<type>/<filename>
  target_dir <- file.path("model-output", type)
  dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
  destfile <- file.path(target_dir, filename)
  
  # Attempt download
  download_success <- tryCatch({
    download.file(url = file_url, destfile = destfile, method = "libcurl")
    cat("✅ Downloaded and saved:", destfile, "\n")
    TRUE
  }, error = function(e) {
    cat("❌ Failed to download", filename, "\nReason:", e$message, "\n")
    FALSE
  })
}


