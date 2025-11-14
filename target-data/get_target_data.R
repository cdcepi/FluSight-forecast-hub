#' Fetch FluSight target Data 
#' Obtain influenza signal
#'
#' @return data frame of flu incidence with columns date, location,
#'   location_name, value, weekly_rate

fetch_flu <- function(){
  require(dplyr)
  require(lubridate)
  require(jsonlite)
  require(purrr)
  require(stringr)
  #require(RSocrata)
  
  #read data from data.cdc.gov, filtering for when flu reporting became mandatory
  # health_data = RSocrata::read.socrata(url = "https://data.cdc.gov/resource/mpgq-jmmr.json") %>% 
  #   dplyr::filter(weekendingdate >= as.Date("2022-02-01"))
  
  # Function to fetch paginated data
  # fetch_socrata_data <- function(base_url, limit = 1000, max_rows = 30000) {
  #   offsets <- seq(0, max_rows, by = limit)
  #   
  #   all_data <- map_dfr(offsets, function(offset) {
  #     paged_url <- paste0(base_url, "?$limit=", limit, "&$offset=", offset)
  #     message("Fetching offset: ", offset)
  #     tryCatch(
  #       fromJSON(paged_url),
  #       error = function(e) {
  #         message("Error at offset ", offset, ": ", e$message)
  #         NULL
  #       }
  #     )
  #   })
  #   
  #   return(all_data)
  # }
  fetch_socrata_data <- function(base_url, limit = 1000, max_rows = 30000, filter_query = NULL) {
    offsets <- seq(0, max_rows, by = limit)
    
    all_data <- map_dfr(offsets, function(offset) {
      # Construct the paged URL with optional filtering
      paged_url <- paste0(base_url, "?$limit=", limit, "&$offset=", offset)
      
      # Add filter query if provided
      if (!is.null(filter_query)) {
        paged_url <- paste0(paged_url, "&", filter_query)
      }
      
      message("Fetching offset: ", offset)
      tryCatch(
        fromJSON(paged_url),
        error = function(e) {
          message("Error at offset ", offset, ": ", e$message)
          NULL
        }
      )
    })
    
    return(all_data)
  }
  
  # CDC Socrata endpoint
  base_url <- "https://data.cdc.gov/resource/mpgq-jmmr.json"
  base_url <- "https://data.cdc.gov/resource/ua7e-t2fy.json" #Friday data
  ed_url <- "https://data.cdc.gov/resource/rdmq-nq56.json"
  
  # Define the filter query for the ED data
  filter_query <- "$where=county='All'"
  
  # Download all data (adjust `max_rows` if needed, as of 7/15 about 9,500 rows used)
  health_data_raw <- fetch_socrata_data(base_url, limit = 1000, max_rows = 30000)
  ed_data_raw <- fetch_socrata_data(ed_url, limit = 1000, max_rows = 80000, filter_query = filter_query)
  
  # Now filter it
  health_data <- health_data_raw %>%
    mutate(weekendingdate = as.Date(weekendingdate)) %>%
    filter(weekendingdate >= as.Date("2022-02-01"))
  
  
  #remove  VI, AS, and regions as they are not included for FluSight, keep only necessary vars and add epiweek and epiyear 
  recent_data = health_data %>% 
    dplyr::filter(!jurisdiction %in% c("VI", "AS", "GU", "MP")) %>%
    filter(!str_detect(jurisdiction, "Region")) %>%
    dplyr::select(jurisdiction, weekendingdate, totalconfflunewadm) %>% 
    dplyr::rename("value" = "totalconfflunewadm", "date"="weekendingdate", "state"="jurisdiction") %>% 
    dplyr::mutate(date = as.Date(date), 
                  value = as.numeric(value),
                  state = gsub("USA", "US", state))
                  #target="wk inc flu hosp")
  
  #filter
  ed_data <- ed_data_raw %>% 
    dplyr::select(week_end, geography, percent_visits_influenza) %>% 
    dplyr::rename("date" = "week_end", "state" = "geography", "value" = "percent_visits_influenza") %>% 
    dplyr::mutate(date = as.Date(date), 
                  value = as.numeric(value)/100,
                  state = gsub("United States", "US", state))
                  #target="wk inc flu prop ed visits")
    
  
  ed_full_data = dplyr::left_join(ed_data, locations, by = join_by("state" == "location_name")) %>% 
    rename(location_name = state, state = abbreviation) %>% select(-state, -population)
  
  #bind state population data
  full_data = dplyr::left_join(recent_data, locations, by = join_by("state" == "abbreviation"))
  
  
  #calculates weekly rate 
  final_dat = full_data %>% 
    dplyr::mutate(weekly_rate = (value*100000)/population) %>% 
    select(date, location, location_name, value, weekly_rate)
  
  #return(final_dat, ed_full_data)
    ed_full_data = dplyr::left_join(ed_data, locations, by = join_by("state" == "location_name")) %>% 
    rename(location_name = state, state = abbreviation) %>% select(-state, -population)
  
  #bind state population data
  full_data = dplyr::left_join(recent_data, locations, by = join_by("state" == "abbreviation"))
  
  
  #calculates weekly rate 
  final_dat = full_data %>% 
    dplyr::mutate(weekly_rate = (value*100000)/population) %>% 
    select(date, location, location_name, value, weekly_rate)
  
  #return(final_dat, ed_full_data)
  return(list(final_dat = final_dat, ed_full_data = ed_full_data))
  
}

library(dplyr)
library(lubridate)
library(jsonlite)
library(purrr)
library(stringr)

locations <- read.csv(file = "https://raw.githubusercontent.com/cdcepi/FluSight-forecast-hub/main/auxiliary-data/locations.csv") %>% dplyr::select(1:4)

#setwd(paste0("C:/Users/",Sys.info()["user"],"/Desktop/Github/FluSight-forecast-hub"))
  
#target_data <- fetch_flu()

result <- fetch_flu()
final_data <- result$final_dat  %>% arrange(desc(date))
ed_full_data <- result$ed_full_data %>% arrange(desc(date))

options(scipen=999)

write.csv(final_data, file = "./target-data/target-hospital-admissions.csv", row.names = FALSE)

#write.csv(ed_full_data, file = "./target-data/target-ed-visits-prop.csv", row.names = FALSE)
