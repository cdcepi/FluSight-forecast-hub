# FluSight 2025-2026
This repository is designed to collect forecast data for the 2025-2026 FluSight collaborative exercise run by the US CDC. This project collects forecasts for weekly new hospital admissions and proportion of emergency department visits due to confirmed influenza. Anyone interested in using these data for additional research or publications is requested to contact flusight@cdc.gov for information regarding attribution of the source forecasts.'

## Nowcasts and Forecasts of Confirmed Influenza Hospital Admissions During the 2025-2026 Influenza Season


Influenza-related hospital admissions are a major contributor to the overall burden of influenza in the United States. Accurate predictions of influenza hospital admissions will help support public health planning and interventions during the 2025-2026 season as COVID-19, RSV, and other respiratory pathogens continue to circulate. CDC's Influenza Division will coordinate a collaborative nowcasting and forecasting challenge for weekly laboratory confirmed influenza hospital admissions during the 2025-2026 influenza season, currently planned to begin November 19, 2025. Each week during the challenge (November through May), participating teams will be asked to provide national and jurisdiction-specific (all 50 states, Washington DC, and Puerto Rico) probabilistic nowcasts and forecasts of the weekly number of confirmed influenza hospital admissions and weekly proportion of emergency department visits due to influenza (for locations with sufficient data) during the preceding week, the current week, and the following three weeks. This predicted timespan is planned to include the four weeks after the most recent hospital admissions data are officially released by CDC (details [here](https://github.com/cdcepi/FluSight-forecast-hub/tree/main/target-data)). The beginning and end of prediction activities may be adjusted depending on reported influenza activity and availability of data. Teams can but are not required to submit predictions for all week horizons or for all locations. Predictions will be compared with the number of confirmed influenza admissions from the [NHSN Weekly Hospital Respiratory Dataset](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/ua7e-t2fy/about_data). Previously collected influenza data from the 2020-2021 through 2024-2025 influenza seasons and the number of hospitals reporting these data each week are included in the NHSN Weekly Hospital Respiratory Dataset as well.


**Dates:** The Challenge Period will begin November 19, 2025, and will run until May 20, 2026. Participants are asked to submit weekly nowcasts and forecasts by 11PM Eastern Time each Wednesday (herein referred to as the Forecast Due Date). The Forecast Due Date has been designated based on the release of hospital admission data on Wednesdays. Weekly submissions (including file names) will be specified in terms of the reference date, which is the Saturday following the Forecast Due Date. The reference date is the last day of the epidemiological week (EW) (Sunday to Saturday) containing the Forecast Due Date.


## Prediction Targets

Participating teams are asked to provide national and jurisdiction-specific (all 50 states, Washington DC, and Puerto Rico) predictions for one primary target, quantile predictions for weekly laboratory confirmed influenza hospital admissions, and four other potential targets (listed in descending order of priority to CDC): 1) quantile predictions for weekly proportion of emergency department visits attributable to influenza, 2) category probability predictions for the direction and magnitude of changes in hospital admission rates per 100k population, 3) probability predictions of peak week of laboratory confirmed influenza hospital admissions, and 4) quantile predictions for peak incidence of laboratory confirmed influenza hospital admissions. All targets are optional. Additionally, teams may submit sample trajectories for the primary target of weekly laboratory confirmed influenza hospital admissions in addition to quantile format predictions. 

For the primary target, teams will submit quantile nowcasts and forecasts of the weekly number of confirmed influenza hospital admissions for the epidemiological week (EW) ending on the reference date as well as the three following weeks. Hindcasts may also be submitted for the preceding week (see Note below). Please note that  integer submissions are required for confirmed influenza hospital admission forecasts. Teams can but are not required to submit forecasts for all weekly horizons or for all locations. The evaluation data for forecasts will be the weekly number of confirmed influenza admissions data from the [NHSN Weekly Hospital Respiratory Dataset](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/ua7e-t2fy/about_data). We will use the specification of EWs defined by the [CDC](https://ndc.services.cdc.gov/wp-content/uploads/MMWR_Week_overview.pdf), which run Sunday through Saturday. The target end date for a prediction is the Saturday that ends an EW of interest, and can be calculated using the expression: 
**target end date = reference date + horizon * (7 days)**.

There are standard software packages to convert from dates to epidemic weeks and vice versa (e.g. [MMWRweek](https://cran.r-project.org/web/packages/MMWRweek/) and [lubridate](https://lubridate.tidyverse.org/reference/week.html) for R and [pymmwr](https://pypi.org/project/pymmwr/) and [epiweeks](https://pypi.org/project/epiweeks/) for Python). 

Note: Since hospital admission data for the preceding week will be provided on the Wednesday deadline, weekly hospital admission targets with a horizon of -1 will not be scored in summary evaluations nor included in visualizations. However, teams are  encouraged to submit targets with a horizon of -1 to aid in detecting potential calibration issues. 

**Emergency Department Visits**

Beginning October 2025, the FluSight Forecast Hub will also accept quantile nowcasts and forecasts of the proportion of emergency department visits attributed to influenza. This new target, ‘wk inc flu prop ed visits’, represents influenza as a proportion of emergency department (ED) visits, aggregated by epiweek (Sunday-Saturday) and jurisdiction (states, DC, United States). The numerator is the number of visits with a discharge diagnosis of influenza, and the denominator is total visits. Quantile prediction values submitted for this target should be between 0 and 1.  As with other targets, this target is optional for any submitted location and forecast horizon, including those that may not have sufficient historic or current data to produce forecasts. Initially, influenza forecast communications will focus on hospital admissions. However, we are also soliciting proportion ED visit forecasts so that we are able to shift our communication target in the event of changes in data availability or forecast performance. 

The weekly percent of ED visits due to influenza can be found in the percent_visits_influenza column of the [National Syndromic Surveillance Program](https://www.cdc.gov/nssp/index.html) (NSSP) [Emergency Department Visits - COVID-19, Flu, RSV, Sub-state dataset](https://data.cdc.gov/Public-Health-Surveillance/NSSP-Emergency-Department-Visit-Trajectories-by-St/rdmq-nq56/about_data). Although these numbers are reported as percentages, we provide the target data as decimal proportions (i.e., percent_visits_influenza/ 100) in target-ed-visits-prop.csv and require forecast submissions to also be decimal proportions (minimum = 0 and maximum = 1). To obtain state-level data, we filter the dataset to include only the rows where the county column is equal to All. 

The target dataset will be updated with this data every Wednesday by midday (pending data availability) in the [target-data](https://github.com/cdcepi/FluSight-forecast-hub/tree/main/target-data) directoryof the FluSight GitHub repository as a file named [target-ed-visits-prop.csv](https://github.com/cdcepi/FluSight-forecast-hub/blob/main/target-data/target-ed-visits-prop.csv). These Wednesday data updates contain the same data that are published on Fridays at [NSSP Emergency Department Visit trajectories](https://data.cdc.gov/Public-Health-Surveillance/NSSP-Emergency-Department-Visit-Trajectories-by-St/rdmq-nq56/about_data) and underlie the percentage ED visit reported on the PRISM Data Channel's Respiratory Activity Levels page, which is also refreshed every Friday. The data represent the information available as of Wednesday morning through the previous Saturday. 

**Sample trajectories:**

In addition to the quantile forecasts for incident hospital admissions, this season teams may submit samples for 0- to 3- week ahead forecasts. We use the term “model task” below to refer to a prediction for a specific horizon, location, and reference date. For teams submitting samples, the FluSight hub will require exactly 100 samples for each model task. We request that samples only be submitted when they are structured into temporally connected samples across horizons (i.e., samples should not be submitted that are solely drawn from the distribution of quantile forecasts). In particular, a common sample ID (specified in the ‘output_type_id’ field) will be used in multiple rows of the submission file with values of target date.  

Details on formatting and the submission procedure are provided in the model-output subfolder README file and include details on specification of ‘output_type_id’. 

Teams submitting sample trajectories corresponding to the primary forecast target will be requested to include information on how the trajectories were constructed in their metadata file (e.g., the primary output of forecasts which are then aggregated into quantile distributions). Teams should note that for this pilot submission target samples should retain an element of the temporal structure of 0 to 3-week ahead forecasts, rather than just submitting posthoc samples generated from their quantile forecasts. 

**Rate-trend categories:**

The objective of the optional rate trend target is to characterize the trajectory of confirmed influenza hospital admissions as "large increase", "increase", "stable", "decrease" or "large decrease" over the 1- to 4 -week forecast period following the most recent official hospital admissions data. Predictions for these targets will be in the form of probabilities for each rate trend category, and will be submitted in the same file as a team's weekly hospital admissions forecasts using a target name of "wk flu hosp rate change".

Rate-trend categories are defined by binning state-level changes in weekly hospital admission incidence on a rate scale (counts per 100k people). A change is defined as the difference between the finalized reported weekly hospital admissions rates in the EW ending on the target end date and the baseline EW ending **one week** prior to the reference date. At the time that nowcasts and forecasts are generated, this baseline week will be the most recent week for which the official data released on [data.cdc.gov](data.cdc.gov) include reported hospital admission values for at least some days (see Figures 1 and 2). Let $t$ denote the reference date and $y_s$ denote the finalized hospitalization rate in units of counts/100k population on the week ending on date $s$. The change in hospitalization rates at a weekly horizon $h$ is rate_change = $y_{t+h*7} - y_{t}$ . 

The date ranges used in these calculations are illustrated in an example in [Table 2](https://github.com/cdcepi/FluSight-forecast-hub/tree/main/model-output). Corresponding count changes are based on state-level population sizes (i.e., count_change = rate_change*state_population / 100,000). See the locations.csv file in [auxiliary-data/](https://github.com/cdcepi/FluSight-forecast-hub/tree/main/auxiliary-data) for the population sizes that will be used to calculate rates. Population counts have been updated with the latest U.S. census data for the 2025-2026 season.

Rate thresholds separating categories of change (e.g., separating "stable" trends from "increase" trends) will be the same across states, but are translatable into counts using the state's population size (see locations.csv, in the auxiliary-data subfolder of this repository). Any week pairs with a difference of fewer than 10 hospital admissions will be classified as having a "stable" trend.  Specific rate-difference thresholds for changes have been developed for each prediction horizon, based on past distributions observed in FluSurv-NET and HHS-Protect/NHSN. These are provided in the model-outputs directory README file.

**Seasonal Forecast Targets:**

Teams may also submit probability forecasts for peak week. Peak week will be defined as the epidemiologic week with the highest count of confirmed influenza hospital admissions during the 2024-2025 season. In the case multiple weeks observe the same highest count of confirmed influenza hospital admissions for a particular location, peak week forecasts for that location will not be scored. Based on analysis of previously observed influenza hospital admission data, we do not anticipate that this will happen frequently if at all. Separately, teams may submit quantile forecasts predicting peak incidence of influenza hospitalizations. Peak Incidence is defined as the highest count of confirmed influenza hospital admissions reach during any epidemiological week of the 2025-2026 season. NOTE:  For the seasonal targets, please submit forecasts throughout the entire seasons, even if you expect the peak has passed (e.g., assign a probability of 1 to the epiweek with the highest count of confirmed influenza hospital admissions observed). 

The objective of these seasonal targets is to provide actionable and intuitive forecasts for public health decision makers. These targets will characterize the season as a whole and predict the intensity and timing of the highest severity segment of the season to expand public health utility. 

All forecast targets will be evaluated based on reported values for weekly influenza admissions in the [NHSN Hospital Respiratory Dataset](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/mpgq-jmmr/about_data) provided on data.cdc.gov. As such, forecasting teams are encouraged to consider uncertainty in values as they are reported in real time. We emphasize that predictions of the rate trend targets will be evaluated based on changes in reported hospitalization rates based on finalized data at the end of the season.

If you have questions about this season’s FluSight Collaboration, please reach out to Rebecca Borchering, Sarabeth Mathis, Annabella Hines, and the CDC FluSight team (flusight@cdc.gov).  

## Accessing FluSight data on the cloud

To ensure greater access to the data created by and submitted to this hub, real-time copies of files in the following
directories are hosted on the Hubverse's Amazon Web Services (AWS) infrastructure, in a public S3 bucket:
`cdcepi-flusight-forecast-hub`.

- auxiliary-data
- hub-config
- model-metadata
- model-output
- target-data

GitHub remains the primary interface for operating the hub and collecting forecasts from modelers.
However, the mirrors of hub files on S3 are the most convenient way to access hub data without using git/GitHub or
cloning the entire hub to your local machine.

The sections below provide examples for accessing hub data on the cloud, depending on your goals and
preferred tools. The options include:

| Access Method              | Description                                                                           |
| -------------------------- | ------------------------------------------------------------------------------------- |
| hubData (R)                | Hubverse R client and R code for accessing hub data                                   |
| Pyarrow (Python)           | Python open-source library for data manipulation                                      |
| AWS command line interface | Download data and use hubData, Pyarrow, or another tool for fast local access         |

In general, accessing the data directly from S3 (instead of downloading it first) is more convenient. However, if
performance is critical (for example, you're building an interactive visualization), or if you need to work offline,
we recommend downloading the data first.

<!-------------------------------------------------- hubData ------------------------------------------------------->

<details>

<summary>hubData (R)</summary>

[hubData](https://hubverse-org.github.io/hubData), the Hubverse R client, can create an interactive session
for accessing, filtering, and transforming hub model output data stored in S3.

hubData is a good choice if you:

- already use R for data analysis
- want to interactively explore hub data from the cloud without downloading it
- want to save a subset of the hub's data (*e.g.*, forecasts for a specific date or target) to your local machine
- want to save hub data in a different file format (*e.g.*, parquet to .csv)

### Installing hubData

To install hubData and its dependencies (including the dplyr and arrow packages), follow the
[instructions in the hubData documentation](https://hubverse-org.github.io/hubData/#installation).

### Using hubData

hubData's [`connect_hub()` function](https://hubverse-org.github.io/hubData/reference/connect_hub.html) returns an [Arrow
multi-file dataset](https://arrow.apache.org/docs/r/reference/Dataset.html) that represents a hub's model output data.
The dataset can be filtered and transformed using dplyr and then materialized into a local data frame
using the [`collect_hub()` function](https://hubverse-org.github.io/hubData/reference/collect_hub.html).

#### Accessing target data

*Coming soon: directions for accessing Hubverse-formatted target data.*

#### Accessing model output data

Use hubData to connect to a hub on S3 and retrieve all model-output files into a local dataframe.
(note: depending on the size of the hub, this operation will take a few minutes):

```r
library(dplyr)
library(hubData)

bucket_name <- "cdcepi-flusight-forecast-hub"
hub_bucket <- s3_bucket(bucket_name)
hub_con <- hubData::connect_hub(hub_bucket, file_format = "parquet", skip_checks = TRUE)
model_output <- hub_con %>%
  hubData::collect_hub()

model_output
# > model_output
# # A tibble: 10,196,416 × 9
#    model_id        reference_date target horizon location target_end_date output_type
#  * <chr>           <date>         <chr>    <int> <chr>    <date>          <chr>      
#  1 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
#  2 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
#  3 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
#  4 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
#  5 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
#  6 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
#  7 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
#  8 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
#  9 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
# 10 CADPH-FluCAT_E… 2023-10-14     wk in…      -1 06       2023-10-07      quantile   
# # ℹ 10,196,406 more rows
```

Use hubData to connect to a hub on S3 and filter model output data before "collecting" it into a local dataframe:

```r
library(dplyr)
library(hubData)

bucket_name <- "cdcepi-flusight-forecast-hub"
hub_bucket <- s3_bucket(bucket_name)
hub_con <- hubData::connect_hub(hub_bucket, file_format = "parquet", skip_checks = TRUE)
hub_con %>%
  dplyr::filter(target == "wk inc flu hosp", location == "25", output_type == "quantile") %>%
  hubData::collect_hub() %>%
  dplyr::select(reference_date, model_id, target_end_date, location, output_type_id, value)


# A tibble: 153,065 × 6
#    reference_date model_id         target_end_date location output_type_id value
#    <date>         <chr>            <date>          <chr>    <chr>          <dbl>
#  1 2023-10-28     CEPH-Rtrend_fluH 2023-10-21      25       0.01               0
#  2 2023-10-28     CEPH-Rtrend_fluH 2023-10-28      25       0.01               2
#  3 2023-10-28     CEPH-Rtrend_fluH 2023-11-04      25       0.01               0
#  4 2023-10-28     CEPH-Rtrend_fluH 2023-11-11      25       0.01               0
#  5 2023-10-28     CEPH-Rtrend_fluH 2023-11-18      25       0.01               0
#  6 2023-10-28     CEPH-Rtrend_fluH 2023-10-21      25       0.025              0
#  7 2023-10-28     CEPH-Rtrend_fluH 2023-10-28      25       0.025              3
#  8 2023-10-28     CEPH-Rtrend_fluH 2023-11-04      25       0.025              0
#  9 2023-10-28     CEPH-Rtrend_fluH 2023-11-11      25       0.025              0
# 10 2023-10-28     CEPH-Rtrend_fluH 2023-11-18      25       0.025              0
# ℹ 153,055 more rows
```

- [full hubData documentation](https://hubverse-org.github.io/hubData/)

</details>

<!--------------------------------------------------- Pyarrow ------------------------------------------------------->

<details>

<summary>Pyarrow (Python)</summary>

Python users can use [Pyarrow](https://arrow.apache.org/docs/python/index.html) to work with hub data in S3.

Pandas users can access hub data as described below and then use the `to_pandas()` method to get a Pandas dataframe.

Pyarrow is a good choice if you:

- already use Python for data analysis
- want to interactively explore hub data from the cloud without downloading it
- want to save a subset of the hub's data (*e.g.*, forecasts for a specific date or target) to your local machine
- want to save hub data in a different file format (*e.g.*, parquet to .csv)

### Installing pyarrow

Use pip to install Pyarrow:

```sh
python -m pip install pyarrow
```

### Using Pyarrow

The examples below start by creating a Pyarrow dataset that references the hub files on S3.

#### Accessing target data

*Coming soon: directions for accessing Hubverse-formatted target data.*

#### Accessing model output data

Get all model-output files.
This example creates an in-memory [Pyarrow table](https://arrow.apache.org/docs/python/generated/pyarrow.Table.html)
with all model-output files from the hub (it will take a few minutes to run).

```python
import pyarrow.dataset as ds
import pyarrow.fs as fs

# define an S3 filesystem with anonymous access (no credentials required)
s3 = fs.S3FileSystem(access_key=None, secret_key=None, anonymous=True)

# create a Pyarrow dataset that references the hub's model-output files
# and convert it to an in-memory Pyarrow table
mo = ds.dataset("cdcepi-flusight-forecast-hub/model-output/", filesystem=s3, format="parquet").to_table()

# to convert the Pyarrow table to a Pandas dataframe:
df = mo.to_pandas()
```

Get the model-output files for a specific team (all rounds).

```python
import pandas as pd
import pyarrow.dataset as ds
import pyarrow.fs as fs

# define an S3 filesystem with anonymous access (no credentials required)
s3 = fs.S3FileSystem(access_key=None, secret_key=None, anonymous=True)

# create a Pyarrow dataset that references a team's model-output files
# and convert it to an in-memory Pyarrow table
mo = ds.dataset("cdcepi-flusight-forecast-hub/model-output/UMass-flusion/", filesystem=s3, format="parquet").to_table()

# to convert the Pyarrow table to a Pandas dataframe:
df = mo.to_pandas()
df.head()

#   reference_date location  horizon           target target_end_date output_type output_type_id      value    round_id       model_id
# 0     2023-10-14       01        0  wk inc flu hosp      2023-10-14    quantile           0.01   0.000000  2023-10-14  UMass-flusion
# 1     2023-10-14       01        0  wk inc flu hosp      2023-10-14    quantile          0.025   1.581068  2023-10-14  UMass-flusion
# 2     2023-10-14       01        0  wk inc flu hosp      2023-10-14    quantile           0.05   5.639076  2023-10-14  UMass-flusion
# 3     2023-10-14       01        0  wk inc flu hosp      2023-10-14    quantile            0.1  10.141995  2023-10-14  UMass-flusion
# 4     2023-10-14       01        0  wk inc flu hosp      2023-10-14    quantile           0.15  13.233311  2023-10-14  UMass-flusion
```

- [Full documentation of Pyarrow table API](https://arrow.apache.org/docs/python/generated/pyarrow.Table.html)

Add a filter to model output data before converting it to a Pyarrow table. Filters are expressed as a
[Pyarrow dataset Expression](https://arrow.apache.org/docs/python/generated/pyarrow.dataset.Expression.html#pyarrow.dataset.Expression).

```python
from datetime import datetime
import pandas as pd
import pyarrow as pa
import pyarrow.compute as pc
import pyarrow.dataset as ds
import pyarrow.fs as fs

# define an S3 filesystem with anonymous access (no credentials required)
s3 = fs.S3FileSystem(access_key=None, secret_key=None, anonymous=True)

# create a Pyarrow dataset that references a team's model-output files, apply filters,
# and convert it to an in-memory Pyarrow table
mo = ds.dataset("cdcepi-flusight-forecast-hub/model-output/", filesystem=s3, format="parquet").to_table(
  filter=(
    pc.field("target") == "wk inc flu hosp") &
    pc.equal(pc.field("reference_date"), pa.scalar(datetime(2023, 10, 14), type=pa.date32())))

# to convert the Pyarrow table to a Pandas dataframe:
df = mo.to_pandas()
df.head()

#   reference_date           target  horizon target_end_date location output_type output_type_id      value    round_id               model_id
# 0     2023-10-14  wk inc flu hosp       -1      2023-10-07       06    quantile           0.01  39.951516  2023-10-14  CADPH-FluCAT_Ensemble
# 1     2023-10-14  wk inc flu hosp       -1      2023-10-07       06    quantile          0.025  40.886151  2023-10-14  CADPH-FluCAT_Ensemble
# 2     2023-10-14  wk inc flu hosp       -1      2023-10-07       06    quantile           0.05  41.698118  2023-10-14  CADPH-FluCAT_Ensemble
# 3     2023-10-14  wk inc flu hosp       -1      2023-10-07       06    quantile            0.1  42.634162  2023-10-14  CADPH-FluCAT_Ensemble
# 4     2023-10-14  wk inc flu hosp       -1      2023-10-07       06    quantile           0.15  43.257751  2023-10-14  CADPH-FluCAT_Ensemble
```

</details>

<!--------------------------------------------------- AWS CLI ------------------------------------------------------->

<details>

<summary>AWS CLI</summary>

AWS provides a terminal-based command line interface (CLI) for exploring and downloading S3 files.
This option is ideal if you:

- plan to work with hub data offline but don't want to use git or GitHub
- want to download a subset of the data (instead of the entire hub)
- are using the data for an application that requires local storage or fast response times

### Installing the AWS CLI

- Install the AWS CLI using the
[instructions here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- You can skip the instructions for setting up security credentials, since Hubverse data is public

### Using the AWS CLI

When using the AWS CLI, the `--no-sign-request` option is required, since it tells AWS to bypass a credential check
(*i.e.*, `--no-sign-request` allows anonymous access to public S3 data).

> [!NOTE]
> Files in the bucket's `raw` directory should not be used for analysis (they're for internal use only).

List all directories in the hub's S3 bucket:

```sh
aws s3 ls cdcepi-flusight-forecast-hub --no-sign-request
```

List all files in the hub's bucket:

```sh
aws s3 ls cdcepi-flusight-forecast-hub --recursive --no-sign-request
```

Download all of target-data contents to your current working directory:

```sh
aws s3 cp s3://cdcepi-flusight-forecast-hub/target-data/ . --recursive --no-sign-request
```

Download the model-output files for a specific team:

```sh
aws s3 cp s3://cdcepi-flusight-forecast-hub/model-output/UMass-flusion/ . --recursive --no-sign-request
```

- [Full documentation for `aws s3 ls`](https://docs.aws.amazon.com/cli/latest/reference/s3/ls.html)
- [Full documentation for `aws s3 cp`](https://docs.aws.amazon.com/cli/latest/reference/s3/cp.html)

</details>

## Acknowledgments
This repository follows the guidelines and standards outlined by the [hubverse]([url](https://hubdocs.readthedocs.io/en/latest/)), which provides a set of data formats and open source tools for modeling hubs.
