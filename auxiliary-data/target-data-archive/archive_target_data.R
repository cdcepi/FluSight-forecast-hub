#' Archive FluSight target Data 
#' Read recent FluSight Target data and write to archive
#'


#setwd("C:/Users/nqr2/Desktop/Github/FluSight-forecast-hub")


target_data <- read.csv(file = "https://raw.githubusercontent.com/cdcepi/FluSight-forecast-hub/main/target-data/target-hospital-admissions.csv")

ed_target_data <- read.csv(file = "https://raw.githubusercontent.com/cdcepi/FluSight-forecast-hub/main/target-data/target-ed-visits-prop.csv")

archive_data <- sprintf("./auxiliary-data/target-data-archive/target-hospital-admissions_%s.csv", max(target_data$date))

ed_archive_data <- sprintf("./auxiliary-data/target-data-archive/target-ed-visits-prop_%s.csv", max(target_data$date))

write.csv(target_data, file = archive_data, row.names = FALSE)

write.csv(ed_target_data, file = ed_archive_data, row.names = FALSE)


