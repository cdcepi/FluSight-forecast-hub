# Model outputs folder

This folder contains a set of subdirectories, one for each model, that contains submitted model output files for that model. The structure of these directories and their contents follows [the model output guidelines in our documentation](https://hubdocs.readthedocs.io/en/latest/format/model-output.html). Documentation for FluSight-forecast-hub submissions specifically is provided below. 

# Data submission instructions

All forecasts should be submitted directly to the [target-data/](./)
folder. Data in this directory should be added to the repository through
a pull request so that automatic data validation checks are run.

These instructions provide detail about the [data
format](#Data-formatting) as well as [validation](#Data-validation) that
you can do prior to this pull request. In addition, we describe
[metadata](https://github.com/cdcepi/FluSight-forecast-hub/blob/master/model-metadata/README.md)
that each model should provide in the model-metadata folder.

*Table of Contents*

-   [What is a forecast](#What-is-a-forecast)
-   [Target data](#Target-data)
-   [Data formatting](#Data-formatting)
-   [Forecast file format](#Forecast-file-format)
-   [Forecast data validation](#Forecast-validation)
-   [Weekly ensemble build](#Weekly-ensemble-build)
-   [Policy on late submissions](#policy-on-late-or-updated-submissions)

## What is a forecast 

Models are asked to make specific quantitative forecasts about data that
will be observed in the future. These forecasts are interpreted as
"unconditional" predictions about the future. That is, they are not
predictions only for a limited set of possible future scenarios in which
a certain set of conditions (e.g. vaccination uptake is strong, or new
social-distancing mandates are put in place) hold about the future --
rather, they should characterize uncertainty across all reasonable
future scenarios. In practice, all forecasting models make some
assumptions about how current trends in data may change and impact the
forecasted outcome; some teams select a "most likely" scenario or
combine predictions across multiple scenarios that may occur. Forecasts
submitted to this repository will be evaluated against observed data.

We note that other modeling efforts, such as the [Influenza Scenario
Modeling Hub](https://fluscenariomodelinghub.org/), have been
launched to collect and aggregate model outputs from "scenario
projection" models. These models create longer-term projections under a
specific set of assumptions about how the main drivers of the pandemic
(such as non-pharmaceutical intervention compliance, or vaccination
uptake) may change over time.

## Target Data 

This project treats laboratory confirmed influenza virus infection hospitalization admissions data reported through CDC's NHSN (National Health Safety Network) system, [Field 34](https://www.hhs.gov/sites/default/files/covid-19-faqs-hospitals-hospital-laboratory-acute-care-facility-data-reporting.pdf) in [HealthData.gov](https://healthdata.gov/dataset/covid-19-reported-patient-impact-and-hospital-capacity-state-timeseries) as the target ("gold standard") data for hospital admission forecasts. The format of this dataset, previously known as HHS Protect, remains unchanged from the 2022-2023 influenza season. We create processed
versions of these data that are stored in this repository.

Details on how data target data are defined can be found in the
[target-data folder README file](../target-data/README.md).

## Data formatting 

The automatic checks in place for forecast files submitted to this
repository validates both the filename and file contents to ensure the
file can be used in the visualization and ensemble forecasting.

### Subdirectory

Each model that submits forecasts for this project will have a unique subdirectory within the [model-output/](model-output/) directory in this GitHub repository where forecasts will be submitted. Each subdirectory must be named

    team-model

where

-   `team` is the team name and
-   `model` is the name of your model.

Both team and model should be less than 15 characters and not include
hyphens or other special characters, with the exception of "\_".

The `model` should be unique from any other model in the project.

Note that this repository has been created to facilitate the transition to using Hubverse formatting. If similar methods are being used for forecasting models that were submitted for the 2021-2022 or 2022-2023 seasons in the [Flusight-forecast-data](https://github.com/cdcepi/Flusight-forecast-data), please feel free to use the same naming convention for your team.  


### Metadata

The metadata file will be saved within the model-metdata directory in the Hub's GitHub repository, and should have the following naming convention:

  team-model.yml 

Details on the content and formatting of metadata files are provdided in the [model-metadata README](https://github.com/cdcepi/FluSight-forecast-hub/blob/master/model-metadata/README.md).
Note that returning teams should update the metadata file provided during the 2022-2023- season to document any changes that have been made to their model as well as to match updated content requirements.  

### License (optional)

By default, forecasts are released under a CC-BY 4.0 license. If you
would like to release your forecasts under a different license, please
specify a [standard license](../accepted-licenses.csv) in the `license`
field of your metadata file. Alternatively, if you wish to use a license
that is not in the list of [standard
licenses](../accepted-licenses.csv), you may include a

    LICENSE.txt

file in your model directory.

### Forecasts

Each forecast file within the subdirectory should have the following
format

    YYYY-MM-DD-team-model.csv

where

-   `YYYY` is the 4 digit year,
-   `MM` is the 2 digit month,
-   `DD` is the 2 digit day,
-   `team` is the teamname, and
-   `model` is the name of your model.

The date YYYY-MM-DD is the [`forecast_date`](#forecast_date). For this
project, the `forecast_date` should always be the Monday of the week the
submission is due.

The `team` and `model` in this file must match the `team` and `model` in
the directory this file is in. Both `team` and `model` should be less
than 15 characters, alpha-numeric and underscores only, with no spaces
or hyphens.

## Forecast file format 

The file must be a comma-separated value (csv) file with the following
columns (in any order):

-   `forecast_date`
-   `target`
-   `target_end_date`
-   `location`
-   `type`
-   `quantile`
-   `value`

No additional columns are allowed.

Each row in the file is either a point or quantile forecast for a
location on a particular date for a particular target.

### `forecast_date` 

Values in the `forecast_date` column must be a date in the format

    YYYY-MM-DD

This is the Forecast Date for the submission and will always be a
Monday (previously also the forecast due date until 1/6/2023). `forecast_date` should correspond and be redundant with the date
in the filename, and is included here by request from some analysts.

### `target`

Values in the `target` column must be a character (string) and be one of
the following specific targets:

-   “N wk ahead inc flu hosp” where N is a number between 1 and 4

For week-ahead forecasts, we will use the specification of
epidemiological weeks (EWs) [defined by the US
CDC](https://wwwn.cdc.gov/nndss/document/MMWR_Week_overview.pdf) which
run Sunday through Saturday. There are standard software packages to
convert from dates to epidemic weeks and vice versa. E.g.
[MMWRweek](https://cran.r-project.org/web/packages/MMWRweek/) for R and
[pymmwr](https://pypi.org/project/pymmwr/) and
[epiweeks](https://pypi.org/project/epiweeks/) for python.

For week-ahead forecasts with `forecast_date` of Monday of EW12, a 1
week ahead forecast corresponds to EW12 and should have
`target_end_date` of the Saturday of EW12.

#### N week ahead inc flu hosp

This target is the number of new weekly hospitalizations predicted by
the model during the week that is N weeks after `forecast_date`.

### `target_end_date`

Values in the `target_end_date` column must be a date in the format

    YYYY-MM-DD

This is the date for the forecast `target`. For “# wk” targets,
`target_end_date` will be the Saturday at the end of the forecasted
week. As a reminder, the `target_end_date` is the end date of the week
during which the admissions occur, not the date the admission is
reported (see the data processing section for more details).

### `location`

Values in the `location` column must be one of the “locations” in
this [FIPS numeric code file](../data-locations/locations.csv) which
includes numeric FIPS codes for U.S. states and selected jurisdictions
(Washington DC, Puerto Rico, and the US Virgin Islands) as well as
“US” for national forecasts.

Please note that when writing FIPS codes, they should be written in as a
character string to preserve any leading zeroes.

### `type`

Values in the `type` column are either

-   “point” or
-   “quantile”.

This value indicates whether that row corresponds to a point forecast or
a quantile forecast. Point forecasts may be used in visualization while
quantile forecasts are used in visualization and in ensemble
construction.

**When point forecasts are not included, the median for every
location-target pair will be interpreted as the point forecast.**

### `quantile`

Values in the `quantile` column are either “NA” (if `type` is
“point”) or a quantile in the format

    0.###

For quantile forecasts, this value indicates the quantile for the
`value` in this row.

Teams must provide the following 23 quantiles:

0.010, 0.025, 0.050, 0.100, 0.150, 0.200, 0.250, 0.300, 0.350, 0.400,
0.450, 0.500, 0.550, 0.600, 0.650, 0.700, 0.750, 0.800, 0.850, 0.900,
0.950, 0.975, and 0.990

R: c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99) Python:
quantiles =
np.append(np.append([0.01,0.025],np.arange(0.05,0.95+0.05,0.050)),
[0.975,0.99])

### `value`

Values in the `value` column are non-negative numbers indicating the
“point” or “quantile” prediction for this row. For a “point”
prediction, `value` is simply the value of that point prediction for the
`target` and `location` associated with that row. For a “quantile”
prediction, `value` is the inverse of the cumulative distribution
function for the `target`, `location`, and `quantile` associated with
that row. For example, the 2.5 and 97.5 quantiles for a given target and
location should capture 95% of the forecasted values and correspond to
the 95% Prediction Intervals.

## Forecast validation 

To ensure proper data formatting, pull requests for new data in
`data-forecasts/` will be automatically run.

### Pull request forecast validation

When a pull request is submitted, the data are validated through [Github
Actions](https://docs.github.com/en/actions) which runs the tests
present in [the validations
repository](https://github.com/cdcepi/Flusight-forecast-validation). The
intent for these tests are to validate the requirements above. Please
[let us know](https://github.com/cdcepi/Flusight-forecast-data/issues)
if you are facing issues while running the tests.


## Weekly ensemble build 

Every Wednesday morning, we will generate the ensemble forecast using a
single valid forecast from each team that submitted in the current week by the Tuesday 11PM ET deadline.


## Policy on late or updated submissions 

In order to ensure that forecasting is done in real-time, all forecasts
are required to be submitted to this repository by 11pm ET on Tuesdays
each week. We do not accept late forecasts.
