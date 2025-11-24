#' Generate the All Forecasts file containing all FluSight hub model submissions. This script fetches all forecast submissions 
#' from the `flusight-forecast-hub` based on the `reference_date`. The forecast data is then pivoted to create a wide format with 
#' quantile levels as columns. 
#'
#' The resulting csv file contains the following columns:
#' - `location_name`: full state name 
#' (including "US" for the US state)
#' - `abbreviation`: state abbreviation
#' - `horizon`: forecast horizon
#' - `forecast_date`: date the forecast was generated
#' - `target_end_date`: target date for the forecast
#' - `model`: model name
#' - `quantile_*`: forecast values for various 
#' quantiles (e.g., 0.025, 0.5, 0.975)
#' - `forecast_teams`: name of the team that generated the model
#' - `forecast_fullnames`: full model name
#' 
#' To run:
#' Rscript gen_forecast_data.R --reference_date 2024-11-23 --base_hub_path ../../

ref_date <- as.Date("2025-11-22")#lubridate::ceiling_date(Sys.Date(), "week") - days(1)
reference_date <- ref_date
current_ref_date <- ref_date
base_hub_path <- paste0("C:/Users/", Sys.info()["user"], "/Desktop/GitHub/FluSight-forecast-hub")
eligible_models = read.csv(paste0("C:/Users/",Sys.info()["user"],"/Desktop/GitHub/Flusight-ensemble/Model Inclusion/models-to-include-in-ensemble-", ref_date, ".csv"), header = TRUE)
eligible_models = as.character(eligible_models$Model)

# create model metadata path
model_metadata <- hubData::load_model_metadata(
  base_hub_path, model_ids = NULL)

# get `flusight-forecast-hub` content
hub_content <- hubData::connect_hub(base_hub_path)
current_forecasts <- hub_content |>
  dplyr::filter(
    reference_date == current_ref_date
  ) |> 
  dplyr::filter(target=="wk inc flu hosp")|>
  dplyr::collect() |>
  as_model_out_tbl() 

# get data for All Forecasts file
all_forecasts_data <- forecasttools::pivot_hubverse_quantiles_wider(
  hubverse_table = current_forecasts,
  pivot_quantiles = c(
    "quantile_0.025" = 0.025, 
    "quantile_0.25" = 0.25, 
    "quantile_0.5" = 0.5, 
    "quantile_0.75" = 0.75, 
    "quantile_0.975" = 0.975)  
) |>
  # convert location codes to full location 
  # names and to abbreviations
  dplyr::mutate(
    location_name = forecasttools::location_lookup(
      location, 
      location_input_format = "hub", 
      location_output_format = "long_name"
    ),
    abbreviation = forecasttools::us_loc_code_to_abbr(location),
    # round the quantiles to nearest integer 
    # for rounded versions
    dplyr::across(dplyr::starts_with("quantile_"), round, .names = "{.col}_rounded")
  ) |>
  dplyr::left_join(
    dplyr::distinct(model_metadata, model_id, .keep_all = TRUE), # duplicate model_ids
    model_metadata, by = "model_id") |>
  dplyr::  mutate(
    forecast_due_date = reference_date - days(3),  # Wednesday is 3 days before Saturday
    forecast_due_date_formatted = format(forecast_due_date, "%B %d, %Y"),  # Format as "Month DD, YYYY"
    forecast_due_date = format(forecast_due_date, "%Y-%m-%d")  # Format as "YYYY-MM-DD"
  ) |>
  dplyr::filter(horizon !=3, horizon != -1)|>
  mutate(location_name = recode(location_name, "United States" = "US")) %>% 
  mutate(location_name = factor(location_name, levels = c("US", sort(setdiff(unique(location_name), "US"))))) %>%
  arrange(location_name) %>% 
  dplyr::select(
    location_name,
    abbreviation,
    horizon,
    reference_date = reference_date,
    target_end_date,
    model = model_id,
    quantile_0.025,
    quantile_0.25,
    quantile_0.5,
    quantile_0.75,
    quantile_0.975,
    quantile_0.025_rounded,
    quantile_0.25_rounded,
    quantile_0.5_rounded,
    quantile_0.75_rounded,
    quantile_0.975_rounded,
    forecast_team = team_name,
    model_full_name = model_name,
    forecast_due_date,
    forecast_due_date_formatted
  )


#all_forecasts_data <- all_forecasts_data[all_forecasts_data$model %in% eligible_models | grepl("FluSight", all_forecasts_data$model),]

all_forecasts_data <- all_forecasts_data[
  all_forecasts_data$model %in% eligible_models | 
    all_forecasts_data$model %in% c("FluSight-baseline", "FluSight-ensemble", "FluSight-lop_norm"), 
]

# output folder and file paths for All Forecasts
output_folder_path <- fs::path(base_hub_path, "weekly-summaries", ref_date)
output_filename <- paste0(ref_date, "_flu_forecasts_data.csv")
output_filepath <- fs::path(output_folder_path, output_filename)

# determine if the output folder exists, 
# create it if not
fs::dir_create(output_folder_path)
message("Directory is ready: ", output_folder_path)

# check if the file exists, and if not, 
# save to csv, else throw an error
if (!fs::file_exists(output_filepath)) {
  readr::write_csv(all_forecasts_data, output_filepath)
  message("File saved as: ", output_filepath)
} else {
  stop("File already exists: ", output_filepath)
}

#file.remove("//cdc.gov/project/OADC_WCMS_VIZ_DATA/preview/CFA/Forecasts/flu/flu_forecasts_data.csv")
#write_csv(all_forecasts_data, "//cdc.gov/project/OADC_WCMS_VIZ_DATA/preview/CFA/Forecasts/flu/flu_forecasts_data.csv")



#' Generate the Map file containing ensemble forecast data.
#'
#' This script loads the latest ensemble forecast data from the `FluSight-ensemble` folder and processes it into the required 
#' format. The resulting CSV file contains forecast values for all regions (including US, DC, and Puerto Rico), for various forecast 
#' horizons, and quantiles (0.025, 0.5, and 0.975).
#' 
#' The ensemble data is expected to contain the following columns:
#' - `reference_date`: the date of the forecast
#' - `location`: state abbreviation
#' - `horizon`: forecast horizon
#' - `target`: forecast target (e.g., "wk inc 
#' flu hosp")
#' - `target_end_date`: the forecast target date
#' - `output_type`: type of output (e.g., "quantile")
#' - `output_type_id`: quantile value (e.g., 
#' 0.025, 0.5, 0.975)
#' - `value`: forecast value
#'
#' The resulting `map.csv` file will have the following columns:
#' - `location_name`: full state name (
#' including "US" for the US state)
#' - `quantile_*`: the quantile forecast values 
#' (rounded to two decimal places)
#' - `horizon`: forecast horizon
#' - `target`: forecast target (e.g., "7 day 
#' ahead inc hosp")
#' - `target_end_date`: target date for the 
#' forecast (Ex: 2024-11-30)
#' - `reference_date`: date that the forecast 
#' was generated (Ex: 2024-11-23)
#' - `target_end_date_formatted`: target date 
#' for the forecast, prettily re-formatted as
#' a string (Ex: "November 30, 2024")
#' - `reference_date_formatted`: date that the 
#' forecast was generated, prettily re-formatted 
#' as a string (Ex: "November 23, 2024")
#' 
#' To run:
#' Rscript gen_map_data.R --reference_date 2024-11-23 --base_hub_path ../../


# load the latest ensemble data from the 
# model-output folder
ensemble_folder <- file.path(base_hub_path, "model-output", "FluSight-ensemble")
ensemble_file_current <- file.path(ensemble_folder, paste0(ref_date, "-FluSight-ensemble.csv"))
if (file.exists(ensemble_file_current)) {
  ensemble_file <- ensemble_file_current
} else {
  stop("Ensemble file for reference date ", ref_date, " not found in the directory: ", ensemble_folder)
}
ensemble_data <- readr::read_csv(ensemble_file) %>% filter(target=="wk inc flu hosp")
required_columns <- c("reference_date", "target_end_date", "value", "location", "target")
missing_columns <- setdiff(required_columns, colnames(ensemble_data))
if (length(missing_columns) > 0) {
  stop(paste("Missing columns in ensemble data:", paste(missing_columns, collapse = ", ")))
}

# population data, add later to forecasttools
pop_data_path <- file.path(base_hub_path, "auxiliary-data", "locations.csv")
pop_data <- readr::read_csv(pop_data_path)
pop_required_columns <- c("abbreviation", "population")
missing_pop_columns <- setdiff(pop_required_columns, colnames(pop_data))
if (length(missing_pop_columns) > 0) {
  stop(paste("Missing columns in population data:", paste(missing_pop_columns, collapse = ", ")))
}

# process ensemble data into the required 
# format for Map file
map_data <-forecasttools::pivot_hubverse_quantiles_wider(
    hubverse_table = ensemble_data,
    pivot_quantiles = c(
      "quantile_0.025_count" = 0.025,
      "quantile_0.5_count" = 0.5, 
      "quantile_0.975_count" = 0.975)  
  ) |>
  dplyr::mutate(
    reference_date = as.Date(reference_date),
    target_end_date = as.Date(target_end_date),
    model = "FluSight-ensemble"
  ) |>
  dplyr::filter(target != "peak inc flu hosp", horizon != -1, horizon !=3) |>
  # convert location column codes to full 
  # location names
  dplyr::mutate(
    location = forecasttools::location_lookup(
      location, 
      location_input_format = "hub", 
      location_output_format = "long_name"
    )
  ) |>
  # long name "United States" to "US"
  dplyr::mutate(
    location = dplyr::if_else(
      location == "United States", 
      "US", 
      location)
  ) |> 
  # add population data for later calculations
  dplyr::left_join(
    pop_data, 
    by = c("location" = "location_name")
  ) |> 
  # add quantile columns for per-100k rates 
  # and rounded values
  # add quantile columns for per-100k rates 
  # and rounded values
  dplyr::mutate(
    quantile_0.025_per100k = quantile_0.025_count/as.numeric(population) * 100000,
    quantile_0.5_per100k = quantile_0.5_count / as.numeric(population) * 100000,
    quantile_0.975_per100k = quantile_0.975_count / as.numeric(population) * 100000,
    quantile_0.025_per100k_rounded = round(quantile_0.025_per100k, 2),
    quantile_0.5_per100k_rounded = round(quantile_0.5_per100k, 2),
    quantile_0.975_per100k_rounded = round(quantile_0.975_per100k, 2),
    quantile_0.025_count_rounded = round(quantile_0.025_count),
    quantile_0.5_count_rounded = round(quantile_0.5_count),
    quantile_0.975_count_rounded = round(quantile_0.975_count),
    target_end_date_formatted = format(target_end_date, "%B %d, %Y"),
    reference_date_formatted = format(reference_date, "%B %d, %Y"),
    forecast_due_date = reference_date - days(3),  # Wednesday is 3 days before Saturday
    forecast_due_date_formatted = format(forecast_due_date, "%B %d, %Y"),  # Format as "Month DD, YYYY"
    forecast_due_date = format(forecast_due_date, "%Y-%m-%d")  # Format as "YYYY-MM-DD"
  ) |> 
  dplyr::mutate(location = factor(location, levels = c("US", sort(setdiff(unique(location), "US"))))) %>%
  arrange(location) %>% 
  dplyr::select(
    location_name = location, # rename location col
    horizon,
    quantile_0.025_per100k, 
    quantile_0.5_per100k, 
    quantile_0.975_per100k,
    quantile_0.025_count, 
    quantile_0.5_count, 
    quantile_0.975_count,
    quantile_0.025_per100k_rounded, 
    quantile_0.5_per100k_rounded, 
    quantile_0.975_per100k_rounded,
    quantile_0.025_count_rounded, 
    quantile_0.5_count_rounded, 
    quantile_0.975_count_rounded,
    target_end_date, 
    reference_date, 
    target_end_date_formatted, 
    reference_date_formatted,
    forecast_due_date,
    forecast_due_date_formatted,
    model
  )|>
  dplyr::distinct()

# output folder and file paths for Map Data
output_folder_path <- fs::path(base_hub_path, "weekly-summaries", ref_date)
output_filename <- paste0(ref_date, "_flu_map_data.csv")
output_filepath <- fs::path(output_folder_path, output_filename)

# determine if the output folder exists, 
# create it if not
fs::dir_create(output_folder_path)
message("Directory is ready: ", output_folder_path)

# check if the file exists, and if not, 
# save to csv, else throw an error
if (!fs::file_exists(output_filepath)) {
  readr::write_csv(map_data, output_filepath)
  message("File saved as: ", output_filepath)
} else {
  stop("File already exists: ", output_filepath)
}

#file.remove("//cdc.gov/project/OADC_WCMS_VIZ_DATA/preview/CFA/Forecasts/flu/flu_map_data.csv")
#write_csv(map_data, "//cdc.gov/project/OADC_WCMS_VIZ_DATA/preview/CFA/Forecasts/flu/flu_map_data.csv")

#' Generate the Truth Data file containing the most recent observed NHSN hospital admissions data.
#' This script fetches the most recent observed influenza hospital admissions data for all regions 
#' (including US, DC, and Puerto Rico) and processes it into the required format. The data is sourced from the NHSN hospital respiratory
#' data: (https://www.cdc.gov/nhsn/psc/hospital-respiratory-reporting.html).
#'
#' The resulting csv file contains the following columns:
#' - `week_ending_date`: week ending date of 
#' observed data per row (Ex: 2024-11-16) 
#' - `location`: two-digit FIPS code 
#' associated with each state (Ex: 06) 
#' - `location_name`: full state name 
#' (including "US" for the US state)
#' - `value`: the number of hospital 
#' admissions (integer)
#' 
#' To run:
#' Rscript gen_truth_data.R --reference_date 2024-11-23 --base_hub_path ../../


# fetch all NHSN influenza hospital admissions
flu_data <- forecasttools::pull_nhsn(
  api_endpoint = "https://data.cdc.gov/resource/mpgq-jmmr.json",
  columns = c("totalconfflunewadm"),
) |>
  dplyr::rename(
    value = totalconfflunewadm,
    date = weekendingdate,
    state = jurisdiction
  ) |>
  dplyr::mutate(
    date = as.Date(date),
    value = as.numeric(value),
    state = stringr::str_replace(
      state, 
      "USA", 
      "US"
    )
  )|>
  dplyr::filter(!str_detect(state, "Region"))

# convert state abbreviation to location code 
# and to long name
flu_data <- flu_data |>
  dplyr::mutate(
    location = forecasttools::us_loc_abbr_to_code(state), 
    location_name = forecasttools::location_lookup(
      location, 
      location_input_format = "hub", 
      location_output_format = "long_name")
  ) |>
  # long name "United States" to "US"
  dplyr::mutate(
    location_name = dplyr::if_else(
      location_name == "United States", 
      "US", 
      location_name)
  )

# filter and format the data
truth_data <- flu_data |>
  dplyr::select(
    week_ending_date = date, 
    location, 
    location_name, 
    value
  ) |>
  dplyr::filter(!(week_ending_date >= as.Date("2024-04-27") & week_ending_date <= as.Date("2024-10-31"))
  )
# output folder and file paths for Truth Data
output_folder_path <- fs::path(base_hub_path, "weekly-summaries", reference_date)
output_filename <- paste0(reference_date, "_flu_target_hospital_admissions_data.csv")
output_filepath <- fs::path(output_folder_path, output_filename)

# determine if the output folder exists, 
# create it if not
fs::dir_create(output_folder_path)
message("Directory is ready: ", output_folder_path)

# check if the file exists, and if not, 
# save to csv, else throw an error
if (!fs::file_exists(output_filepath)) {
  readr::write_csv(truth_data, output_filepath)
  message("File saved as: ", output_filepath)
} else {
  stop("File already exists: ", output_filepath)
}

#file.remove("//cdc.gov/project/OADC_WCMS_VIZ_DATA/preview/CFA/Forecasts/flu/flu_target_hospital_admissions_data.csv")
#write_csv(truth_data, "//cdc.gov/project/OADC_WCMS_VIZ_DATA/preview/CFA/Forecasts/flu/flu_target_hospital_admissions_data.csv")

