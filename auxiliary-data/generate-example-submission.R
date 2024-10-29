library(arrow)
library(dplyr)
library(tidyr)

reference_date <- "2024-11-16"

set.seed(42)

# categorical rate change target: pmf predictions
categorical_submission <- tidyr::expand_grid(
        reference_date = as.Date(reference_date),
        target = "wk flu hosp rate change",
        horizon = as.integer(c(0, 1, 2, 3)),
        location = c("US", "01"),
        output_type = "pmf",
        output_type_id = c("large_decrease", "decrease", "stable", "increase",
                            "large_increase")
    ) |>
    dplyr::mutate(
        target_end_date = reference_date + horizon * 7,
        value = rnorm(n())
    ) |>
    dplyr::group_by(location, target_end_date) |>
    dplyr::mutate(
        value = exp(value) / sum(exp(value))
    ) |>
    dplyr::select(reference_date, horizon, target_end_date, location, target,
                  output_type, output_type_id, value)

# weekly admissions target: sample predictions
admissions_sample_submission <- tidyr::expand_grid(
        reference_date = as.Date(reference_date),
        target = "wk inc flu hosp",
        horizon = as.integer(c(-1, 0, 1, 2, 3)),
        location = c("US", "01"),
        output_type = "sample",
        sample_idx_within_location = seq_len(100) - 1
    ) |>
    dplyr::mutate(
        output_type_id = paste0(location, sprintf("%02d", sample_idx_within_location)),
        target_end_date = reference_date + horizon * 7,
        value = rnbinom(n(), size = 100, mu = 1000)
    ) |>
    dplyr::select(reference_date, horizon, target_end_date, location, target,
                  output_type, output_type_id, value)

# weekly admissions target: quantile predictions
quantile_levels <- c(0.01, 0.025,
                     seq(from = 0.05, to = 0.95, by = 0.05),
                     0.975, 0.99)
admissions_quantile_submission <- admissions_sample_submission |>
    dplyr::group_by(reference_date, target_end_date, target, horizon, location) |>
    dplyr::summarize(
        output_type = "quantile",
        output_type_id = list(as.character(quantile_levels)),
        value = list(as.integer(quantile(value, probs = quantile_levels)))
    ) |>
    tidyr::unnest(cols = c("output_type_id", "value")) |>
    dplyr::ungroup()


# peak incidence target: quantile predictions
peak_inc_quantile_submission <- tidyr::expand_grid(
        reference_date = as.Date(reference_date),
        target = "peak inc flu hosp",
        horizon = NA_integer_,
        target_end_date = as.Date(NA_character_),
        location = c("US", "01"),
        output_type = "quantile"
    ) |>
    dplyr::mutate(
        output_type_id = list(as.character(quantile_levels)),
        value = c(
            list(qnbinom(quantile_levels, size = 100, mu = 1000)),
            list(qnbinom(quantile_levels, size = 10, mu = 100))
        )
    ) |>
    tidyr::unnest(cols = c("output_type_id", "value")) |>
    dplyr::select(reference_date, horizon, target_end_date, location, target,
                  output_type, output_type_id, value)


# peak timing target: pmf predictions
season_wk_dates <- c("2024-11-09", "2024-11-16", "2024-11-23",
                     "2024-11-30", "2024-12-07", "2024-12-14",
                     "2024-12-21", "2024-12-28", "2025-01-04",
                     "2025-01-11", "2025-01-18", "2025-01-25",
                     "2025-02-01", "2025-02-08", "2025-02-15",
                     "2025-02-22", "2025-03-01", "2025-03-08",
                     "2025-03-15", "2025-03-22", "2025-03-29",
                     "2025-04-05", "2025-04-12", "2025-04-19",
                     "2025-04-26", "2025-05-03", "2025-05-10",
                     "2025-05-17", "2025-05-24", "2025-05-31")
peak_wk_pmf_submission <- tidyr::expand_grid(
        reference_date = as.Date(reference_date),
        target = "peak week inc flu hosp",
        horizon = NA_integer_,
        target_end_date = as.Date(NA_character_),
        location = c("US", "01"),
        output_type = "pmf"
    ) |>
    dplyr::mutate(
        output_type_id = list(season_wk_dates),
        value = c(
            list(dnorm(as.integer(as.Date(season_wk_dates) - as.Date("2025-01-11")) / 21)),
            list(dnorm(as.integer(as.Date(season_wk_dates) - as.Date("2024-12-28")) / 28))
        )
    ) |>
    tidyr::unnest(cols = c("output_type_id", "value")) |>
    dplyr::group_by(location) |>
    dplyr::mutate(value = value / sum(value)) |>
    dplyr::ungroup() |>
    dplyr::select(reference_date, horizon, target_end_date, location, target,
                  output_type, output_type_id, value)


# combine and save
submission <- bind_rows(
    categorical_submission,
    admissions_sample_submission,
    admissions_quantile_submission,
    peak_inc_quantile_submission,
    peak_wk_pmf_submission
)

readr::write_csv(
    submission,
    paste0("auxiliary-data/", reference_date, "-example-submission.csv")
)

arrow::write_parquet(
    submission,
    paste0("auxiliary-data/", reference_date, "-example-submission.parquet")
)

# verify passing validation
library(hubValidations)
target_dir <- "model-output/example-submission"
dir.create(target_dir)
file.copy("model-metadata/cfa-flumech.yml", "model-metadata/example-submission.yml")
file.copy(
    paste0("auxiliary-data/", reference_date, "-example-submission.csv"),
    target_dir,
    overwrite = TRUE
)
hubValidations::validate_submission(
    hub_path = ".",
    file_path = file.path("example-submission", paste0(reference_date, "-example-submission.csv")),
    skip_submit_window_check = TRUE
)

file.copy(
    paste0("auxiliary-data/", reference_date, "-example-submission.parquet"),
    target_dir,
    overwrite = TRUE
)
hubValidations::validate_submission(
    hub_path = ".",
    file_path = file.path("example-submission", paste0(reference_date, "-example-submission.parquet")),
    skip_submit_window_check = TRUE
)

# clean up
unlink("model-metadata/example-submission.yml")
unlink(target_dir, recursive = TRUE)
