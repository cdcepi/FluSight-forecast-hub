#' Fetch FluSight target Data
#' Obtain influenza signal at daily or weekly scale
#'
#' @param temporal_resolution "daily" or "weekly"
#' @param na.rm boolean indicating whether NA values should be dropped when
#'   aggregating state-level values and calculating weekly totals. Defaults to
#'   `TRUE`
#'
#' @return data frame of flu incidence with columns date, location,
#'   location_name, value, weekly_rate

fetch_flu <- function(temporal_resolution = "weekly", na.rm = TRUE){
  require(dplyr)
  require(lubridate)
  require(RSocrata)

  #read data from healthdata.gov, filtering for when flu reporting became mandatory
  health_data = RSocrata::read.socrata(url = "https://healthdata.gov/resource/g62h-syeh.json") %>%
    dplyr::filter(date >= as.Date("2022-02-02"))

  #remove  VI and AS as they are not included for FluSight, keep only necessary vars and add epiweek and epiyear
  recent_data = health_data %>%
    dplyr::filter(!state %in% c("VI", "AS")) %>%
    dplyr::select(state, date, previous_day_admission_influenza_confirmed) %>%
    dplyr::rename("value" = "previous_day_admission_influenza_confirmed") %>%
    dplyr::mutate(date = as.Date(date),
                  value = as.numeric(value),
                  epiweek = lubridate::epiweek(date),
                  epiyear = lubridate::epiyear(date))

  #summarize US Flu
  us_data = recent_data %>% dplyr::group_by(date, epiweek, epiyear) %>%
    dplyr::summarise(value = sum(value, na.rm = na.rm)) %>%
    dplyr::mutate(state = "US") %>%
    dplyr::ungroup()

  #bind state and US data
  full_data = rbind(recent_data, us_data) %>%
    dplyr::left_join(., locations, by = join_by("state" == "abbreviation"))

  #convert counts to weekly and calculates weekly rate
  weeklydat = full_data %>%
    dplyr::group_by(state,epiweek,epiyear, location, location_name, population) %>%
    dplyr::summarise(value = sum(value, na.rm = na.rm), date = max(date), num_days = n()) %>%
    dplyr::ungroup() %>%
    dplyr::filter(num_days == 7L) %>%
    dplyr::select(-num_days, -epiweek, -epiyear) %>%
    dplyr::mutate(weekly_rate = (value*100000)/population )

  #if daily data is ever wanted, this returns correct final data
  if(temporal_resolution == "weekly"){
    final_dat = weeklydat %>%
      dplyr::select(date, location, location_name, value, weekly_rate) %>%
      dplyr::arrange(desc(date))
  } else{
    final_dat = full_data
  }
  return(final_dat)

}
library(dplyr)
library(lubridate)
library(RSocrata)

locations <- read.csv(file = "https://raw.githubusercontent.com/cdcepi/FluSight-forecast-hub/main/auxiliary-data/locations.csv") %>% dplyr::select(1:4)

#setwd("C:/Users/nqr2/Desktop/Github/FluSight-forecast-hub")

target_data <- fetch_flu(temporal_resolution = "weekly")

#archive_data <- sprintf("./auxiliary-data/target-data-archive/target-hospital-admissions_%s.csv", max(target_data$date))

write.csv(target_data, file = "./target-data/target-hospital-admissions.csv")
#write.csv(target_data, file = archive_data, row.names = FALSE)


