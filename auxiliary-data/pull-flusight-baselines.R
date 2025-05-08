
# Script that runs with the Pull baselines action to download and save the weekly baselines from the FluSight-baseline repository.
# Retrieves specifically FluSight-baseline, FluSight-base_seasonal, and FluSight-equal_cat.
# Runs Hub Validations on the files.

# Load required libraries
library(lubridate)
library(hubValidations)
library(fs)

# Prepare output file for PR body
result_file <- "validation_result.md"

# Wrap the entire script in a top-level tryCatch
tryCatch({

  # Set up reference date and file names
  current_ref_date <- ceiling_date(Sys.Date(), "week") - days(1)
  date_str <- format(current_ref_date, "%Y-%m-%d")

  baseline_types <- c("FluSight-baseline", "FluSight-base_seasonal", "FluSight-equal_cat")
  baseline_folders <- c("Flusight-baseline", "Flusight-seasonal-baseline", "Flusight-equal_cat")

  downloaded_files <- c()
  validation_results <- list()

  for (i in seq_along(baseline_types)) {
    type <- baseline_types[i]
    folder <- baseline_folders[i]
    filename <- paste0(date_str, "-", type, ".csv")

    file_url <- paste0(
      "https://raw.githubusercontent.com/cdcepi/Flusight-baseline/main/weekly-submission/forecasts/",
      folder, "/", filename
    )

    target_dir <- file.path("model-output", type)
    dir_create(target_dir, recurse = TRUE)
    destfile <- file.path(target_dir, filename)

    # Attempt to download
    download_success <- tryCatch({
      download.file(url = file_url, destfile = destfile, method = "libcurl")
      cat("✅ Downloaded and saved:", destfile, "\n")
      downloaded_files <- c(downloaded_files, file.path(type, filename))
      TRUE
    }, error = function(e) {
      msg <- paste("❌ Failed to download", filename, "Reason:", e$message)
      cat(msg, "\n")
      validation_results[[file.path(type, filename)]] <- list(status = "error", message = msg)
      FALSE
    })

    # Only attempt validation if download succeeded
    if (download_success) {
      file_path <- file.path(type, filename)
      result <- tryCatch({
        v <- hubValidations::validate_submission(hub_path = ".", file_path = file_path)

        # Try to check for validation errors
        err_msg <- tryCatch({
          hubValidations::check_for_errors(v, verbose = TRUE)
          NULL  # Passed
        }, error = function(e) {
          e$message  # Return error message
        })

        list(status = if (is.null(err_msg)) "pass" else "fail", message = err_msg)

      }, error = function(e) {
        list(status = "error", message = e$message)
      })

      validation_results[[file_path]] <- result
    }
  }

  # Compose validation_result.md content
  messages <- c("### 🧪 Validation Results")

  for (file in names(validation_results)) {
    res <- validation_results[[file]]
    if (res$status == "pass") {
      messages <- c(messages, paste0("✅ **", file, "** passed validation."))
    } else {
      messages <- c(messages, paste0("❌ **", file, "**: ", res$message))
    }
  }

  writeLines(messages, result_file)

}, error = function(e) {
  writeLines(c("### 🧪 Validation Results", "❌ Script failed unexpectedly:", e$message), result_file)
})


