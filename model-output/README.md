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



### Forecasts

Each forecast file should have the following
format

    YYYY-MM-DD-team-model.csv

where

-   `YYYY` is the 4 digit year,
-   `MM` is the 2 digit month,
-   `DD` is the 2 digit day,
-   `team` is the team name, and
-   `model` is the name of your model.

The date YYYY-MM-DD is the [`reference_date`](#reference_date). This should be the Saturday following the submission date.

The `team` and `model` in this file must match the `team` and `model` in
the directory this file is in. Both `team` and `model` should be less
than 15 characters, alpha-numeric and underscores only, with no spaces
or hyphens. **Note:** Any categorical rate-trend forecasts should be submitted in the same weekly csv submission file as the hospital admission forecasts.

## Forecast file format 

The file must be a comma-separated value (csv) file with the following
columns (in any order):

-   `reference_date`
-   `target`
-   `horizon`
-   `target_end_date`
-   `location`
-   `output_type`
-   `output_type_id`
-   `value`

No additional columns are allowed.

The value in each row of the file is either a quantile or rate-trend prediction for a particular combination of location, date, and horizon.

### `reference_date` 

Values in the `reference_date` column must be a date in the ISO format

    YYYY-MM-DD

This is the date from which all forecasts should be considered. This date is the Saturday following the submission Due Date, corresponding to the last day of the epiweek when submissions are made. The `reference_date` should be the same as the date in the filename but is included here to facilitate validation and analysis.

### `target`

Values in the `target` column must be a character (string) and be one of
the following specific targets:

-   `wk inc flu hosp` 
-   `wk flu hosp rate change`


### `horizon`
Values in the `horizon` column indicate the number of weeks between the `reference_date` and the `target_end_date`.  For both influenza hospital admission forecasts and rate change predictions this should be a number between -1 and 3, where for example a `horizon` of 0 indicates that the prediction is a nowcast for the week of submission and a `horizon` of 1 indicates that the prediction is a forecast for the week after submission. 

### `target_end_date`

Values in the `target_end_date` column must be a date in the format

    YYYY-MM-DD
    
This is the last date of the forecast target's week. This will be the date of the Saturday at the end of the forecasted week. As a reminder, the `target_end_date` is the end date of the week during which the admissions occur, not the date the admission is reported (see the data processing section for more details). Within each row of the submission file, the `target_end_date` should be equal to the `reference_date` + `horizon`*(7 days).


### `location`

Values in the `location` column must be one of the "locations" in
this [location information file](../auxiliary-data/locations.csv) which
includes numeric FIPS codes for U.S. states,  territories, and districts, as well as "US" for national forecasts, included in the FluSight forecasting collaboration.

Please note that when writing FIPS codes, they should be written in as a character string to preserve any leading zeroes.

### `output_type`

Values in the `output_type` column are either

-   "quantile" or
-   "pmf".

This value indicates whether that row corresponds to a quantile forecast for incident hospital admissions or the probability mass function (pmf) of a categorical forecast for rate-trend. Quantile forecasts are used in visualizations and to construct the primary FluSight ensemble.

### `output_type_id`
Values in the `output_type_id` column specify identifying information for the output type.

#### quantile output

When the predictions are quantiles, values in the `output_type_id` column are a quantile probability level in the format

    0.###

 This value indicates the quantile probability level for for the
`value` in this row.

Teams must provide the following 23 quantiles:

0.010, 0.025, 0.050, 0.100, 0.150, 0.200, 0.250, 0.300, 0.350, 0.400,
0.450, 0.500, 0.550, 0.600, 0.650, 0.700, 0.750, 0.800, 0.850, 0.900,
0.950, 0.975, and 0.990

R: c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99) 
Python: quantiles =
np.append(np.append([0.01,0.025],np.arange(0.05,0.95+0.05,0.050)),
[0.975,0.99])

#### pmf output

For rate change forecasts, the output_type_id indicates the category that the predicted probability of occurrence should be associated with. Teams should provide the following categories:
"large_increase", "increase", "stable", "decrease" and "large_decrease". Please see Appendix 1: rate-trend forecast specifications for details on how each category is defined. Note that thresholds between categories differ from those used in the 2022-2023 season and that new threshold values have been added for the one-week ahead rate-trend targets.


### `value`

Values in the `value` column are non-negative numbers indicating the "quantile" or "pmf" prediction for this row. For a "quantile" prediction, `value` is the inverse of the cumulative distribution function (CDF) for the target, location, and quantile associated with that row. For example, the 2.5 and 97.5 quantiles for a given target and location should capture 95% of the predicted values and correspond to the central 95% Prediction Interval. For rate change forecasts, values are required to sum to 1 across all `output_type_ids` for each target and location (as specified in the FILL LINK hubverse documentation).

## Forecast validation 

To ensure proper data formatting, pull requests for new data in
`model-output/` will be automatically run.

### Pull request forecast validation

When a pull request is submitted, the data are validated through [Github
Actions](https://docs.github.com/en/actions) which runs the tests
present in [the validations
repository](https://github.com/UPDATE). The
intent for these tests are to validate the requirements above. Please
[let us know](https://github.com/cdcepi/FluSight-forecast-hub/issues) if you are facing issues while running the tests.


## Weekly ensemble build 

Every Thursday morning, we will generate a FluSight ensemble influenza hospital admission forecast using valid forecast submissions in the current week by the Wednesday 11PM ET deadline. Some or all participant forecasts may be combined into an ensemble forecast to be published in real-time along with the participant forecasts. In addition, some or all forecasts may be displayed alongside the output of a baseline model for comparison.


## Policy on late or updated submissions 

In order to ensure that forecasting is done in real-time, all forecasts are required to be submitted to this repository by 11PM ET on Wednesdays each week. We do not accept late forecasts.

## Evaluation criteria
Forecasts will be evaluated using a variety of metrics, including weighted interval score (WIS) and its components and prediction interval coverage. The CMU [Delphi group's Forecast Evaluation Dashboard](https://delphi.cmu.edu/forecast-eval/) and the COVID-19 Forecast Hub periodic [Forecast Evaluation Reports](https://covid19forecasthub.org/eval-reports/) provide examples of evaluations using these criteria.

Evaluation will use official data reported from healthdata.gov as reported at the end or following the final forecast date (depending on data availability).

# Rate-trend forecast specifications
In order to mitigate the impact of reporting revisions and noise inherent in small counts, all week pairs with a difference of fewer than 10 hospital admissions will be classified as having a "stable" trend. 


**For one-week ahead rate trends (horizon = -1):**

*Stable:* forecasted changes in hospitalizations qualify as stable if either the magnitude of the rate change is less than 1/100k OR the corresponding magnitude of the count change is less than 10.

*Increase:* positive forecasted changes that do not qualify as stable and for which the forecasted rate change is less than 2/100k.

*Large increase:* positive forecasted rate changes that do not qualify as stable and for which the forecasted rate change is larger than or equal to 2/100k.

*Decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is less than 2/100k.

*Large decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is larger than or equal to 2/100k.

**For two-week ahead rate trends (horizon = 0):**

*Stable:* forecasted changes in hospitalizations qualify as stable if either the magnitude of the rate change is less than 1/100k OR the corresponding magnitude of the count change is less than 10.

*Increase:* positive forecasted changes that do not qualify as stable and for which the forecasted rate change is less than 3/100k.

*Large increase:* positive forecasted rate changes that do not qualify as stable and for which the forecasted rate change is larger than or equal to 3/100k.

*Decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is less than 3/100k.

*Large decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is larger than or equal to 3/100k.

**For three-week ahead rate trends (horizon = 1):**

*Stable:* forecasted changes in hospitalizations qualify as stable if either the magnitude of the rate change is less than 2/100k OR the corresponding magnitude of the count change is less than 10.

*Increase:* positive forecasted changes that do not qualify as stable and for which the forecasted rate change is less than 4/100k.

*Large increase:* positive forecasted rate changes that do not qualify as stable and for which the forecasted rate change is larger than or equal to 4/100k.

*Decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is less than 4/100k.

*Large decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is larger than or equal to 4/100k.

**For four-week and five-week ahead rate trends (horizon = 2 or 3, respectively):**

*Stable:* forecasted changes in hospitalizations qualify as stable if either the magnitude of the rate change is less than 2.5/100k OR the corresponding magnitude of the count change is less than 10.

*Increase:* positive forecasted changes that do not qualify as stable and for which the forecasted rate change is less than 5/100k.

*Large increase:* positive forecasted rate changes that do not qualify as stable and for which the forecasted rate change is larger than or equal to 5/100k.

*Decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is less than 5/100k.

*Large decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is larger than or equal to 5/100k.

