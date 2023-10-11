setwd("~/Desktop/FluSight-forecast-hub/")
library(hubValidations)
hubValidations::validate_submission(
  hub_path=".",
  file_path="UM-DeepOutbreak/2023-10-14-UM-DeepOutbreak.csv")

