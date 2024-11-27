#' Fetch FluSight target Data 
#' Obtain influenza signal
#'
#' @return data frame of flu incidence with columns date, location,
#'   location_name, value, weekly_rate

fetch_flu <- function(){
  require(dplyr)
  require(lubridate)
  require(RSocrata)
  
  #read data from data.cdc.gov, filtering for when flu reporting became mandatory
  health_data = RSocrata::read.socrata(url = "https://data.cdc.gov/resource/mpgq-jmmr.json") %>% 
    dplyr::filter(weekendingdate >= as.Date("2022-02-01"))
  
  #remove  VI and AS as they are not included for FluSight, keep only necessary vars and add epiweek and epiyear 
  recent_data = health_data %>% 
    dplyr::filter(!jurisdiction %in% c("VI", "AS", "GU", "MP")) %>% 
    dplyr::select(jurisdiction, weekendingdate, totalconfflunewadm) %>% 
    dplyr::rename("value" = "totalconfflunewadm", "date"="weekendingdate", "state"="jurisdiction") %>% 
    dplyr::mutate(date = as.Date(date), 
                  value = as.numeric(value),
                  state = gsub("USA", "US", state))
  
  #bind state population data
  full_data = dplyr::left_join(recent_data, locations, by = join_by("state" == "abbreviation"))
  
  #calculates weekly rate 
  final_dat = full_data %>% 
    dplyr::mutate(weekly_rate = (value*100000)/population ) %>% 
    select(date, location, location_name, value, weekly_rate)
  
  return(final_dat)
  
}

library(dplyr)
library(lubridate)
library(RSocrata)

locations <- read.csv(file = "https://raw.githubusercontent.com/cdcepi/FluSight-forecast-hub/main/auxiliary-data/locations.csv") %>% dplyr::select(1:4)

#setwd(paste0("C:/Users/",Sys.info()["user"],"/Desktop/Github/FluSight-forecast-hub"))
  
target_data <- fetch_flu()

write.csv(target_data, file = "./target-data/target-hospital-admissions.csv", row.names = FALSE)



