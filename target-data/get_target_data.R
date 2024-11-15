#' Fetch FluSight target Data 
#' Obtain influenza signal
#'
#' @return data frame of flu incidence with columns date, location,
#'   location_name, value, weekly_rate

fetch_flu <- function(){
  require(dplyr)
  require(lubridate)
  require(RSocrata)
  require(stringr)
  
  #read data from data.cdc.gov, filtering for when flu reporting became mandatory
  health_data = RSocrata::read.socrata(url = "https://data.cdc.gov/resource/ua7e-t2fy.json") %>% 
    dplyr::filter(weekendingdate >= as.Date("2024-11-02"))
  
  #remove  VI and AS as they are not included for FluSight, keep only necessary vars and add epiweek and epiyear 
  recent_data = health_data %>% 
    dplyr::filter(!jurisdiction %in% c("VI", "AS", "GU", "MP")) %>% 
    dplyr::select(jurisdiction, weekendingdate, totalconfflunewadm) %>% 
    dplyr::rename("value" = "totalconfflunewadm", "date"="weekendingdate", "state"="jurisdiction") %>% 
    dplyr::mutate(date = as.Date(date), 
                  value = as.numeric(value),
                  epiweek = lubridate::epiweek(date), 
                  epiyear = lubridate::epiyear(date),
                  state = str_replace(state, "USA", "US"))
  
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

userid <- Sys.info()["user"]
setwd(paste0("C:/Users/",userid,"/Desktop/Github/FluSight-forecast-hub"))
  
target_data <- fetch_flu()

#archive_data <- sprintf("./auxiliary-data/target-data-archive/target-hospital-admissions_%s.csv", max(target_data$date))

write.csv(target_data, file = "./target-data/target-hospital-admissions.csv")
#write.csv(target_data, file = archive_data, row.names = FALSE)





