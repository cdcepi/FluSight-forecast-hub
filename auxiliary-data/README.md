Example submission
============================
This folder contains a comma-separated text file and a parquet file to serve as sample submission files. These were generated with `generate-example-submission.R`. Please see these files for an example of how submissions should be formatted, particularly for new targets such as the optional sample trajectories. 

Data locations
============================

This folder contains a comma-separated text file `locations.csv` that 
contains the location name, FIPS code, and population for each valid forecast location. The file `locations_202324.csv` contains the same information for the previous 2023-2024 season.

Note that national, state, and Puerto Rico population sizes are taken from the [U.S. Census Bureau 2023 Vintage population totals](https://www.census.gov/data/tables/time-series/demo/popest/2020s-state-total.html). Population information provided for other territories is taken from the [JHU CSSE GitHub repository](https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data).

Additional columns e.g., `count_rate0p3` and `count_rate0p5` have been updated for the 2024-2025 experimental target count thresholds based on the rate boundaries specified for the categorical rate trend target. Please note however that the difference in weekly rates will not be evaluated for the following territories due to small population sizes: American Samoa, Guam, Northern Mariana Islands, and Virgin Islands. 


