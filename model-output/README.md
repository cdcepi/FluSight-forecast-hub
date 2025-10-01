# Model outputs folder

This folder contains a set of subdirectories, one for each model, that contains submitted model output files for that model. The structure of these directories and their contents follows [the model output guidelines in our documentation](https://hubverse.io/en/latest/user-guide/model-output.html). Documentation for FluSight-forecast-hub submissions specifically is provided below. 

# Data submission instructions

All forecasts should be submitted directly to the [model-output/](./)
folder. Data in this directory should be added to the repository through
a pull request so that automatic data validation checks are run.

These instructions provide detail about the [data
format](#Data-formatting) as well as [validation](#Forecast-validation) that
you can do prior to this pull request. In addition, we describe
[metadata](https://github.com/cdcepi/FluSight-forecast-hub/blob/master/model-metadata/README.md)
that each model should provide in the model-metadata folder. Sample submission files with the correct formatting conventions are provided in the [auxiliary-data folder](https://github.com/cdcepi/FluSight-forecast-hub/tree/main/auxiliary-data).

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

This project treats laboratory confirmed influenza virus infection hospital admissions data reported through CDC's NHSN (National Health Safety Network) system in the [Hospital Respitatory Dataset](https://www.cdc.gov/nhsn/psc/hospital-respiratory-reporting.html) as the target ("gold standard") data for hospital admission forecasts.

Details on how data target data are defined can be found in the
[target-data folder README file](../target-data/README.md).

## Data formatting 

The automatic checks in place for forecast files submitted to this repository validates both the filename and file contents to ensure the file can be used in the visualization and ensemble forecasting. For the 2025-2026 FluSight Collaboration, minor modifications to previous file formatting procedures will be made to align submissions with Hubverse protocols being developed by the Consortium of Infectious Disease Modeling Hubs version 3.0.1 (see https://github.com/hubverse-org and https://hubverse.io/en/latest/ for additional information). The required formatting is described in detail below.

### Subdirectory

Each model that submits forecasts for this project will have a unique subdirectory within the [model-output/](model-output/) directory in this GitHub repository where forecasts will be submitted. Each subdirectory must be named

    team-model

where

-   `team` is the team name and
-   `model` is the name of your model.

Both team and model should be less than 15 characters and not include
hyphens or other special characters, with the exception of "\_".

The combination of `team` and `model` should be unique from any other model in the project.

Note that this repository has been created to facilitate the transition to using Hubverse formatting. If similar methods are being used for forecasting models that were submitted for the 2021-2022, 2022-2023, or 2023-2024 seasons in the [Flusight-forecast-data](https://github.com/cdcepi/Flusight-forecast-data), please feel free to use the same naming convention for your team.  


### Metadata

The metadata file will be saved within the model-metdata directory in the Hub's GitHub repository, and should have the following naming convention:


      team-model.yml

Details on the content and formatting of metadata files are provdided in the [model-metadata README](https://github.com/cdcepi/FluSight-forecast-hub/blob/master/model-metadata/README.md).
Note that returning teams should update the metadata file provided during the 2024-2025 season to document any changes that have been made to their model as well as to match updated content requirements. In general, teams may designate up to two models for inclusion in the ensemble provided that they differ substantially in methodology and do not differ in parameter values alone. Please send an email to flusight@cdc.gov if you would like to submit more than two methodologically distinct models for inclusion in the ensemble. This email should provide evidence of out of sample performance assessment and/or a statement of differences between the proposed forecast models to justify inclusion in the ensemble.

Updates to the metadata files for the 2025-2026 season include the addition  of an optional “backfill adjustment” field. Teams should include this field if their model has a specific method to account for subsequent updates to the observed data. 

### Forecasts

Each forecast file should have either of the following
format

    YYYY-MM-DD-team-model.csv
    
    YYYY-MM-DD-team-model.parquet

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
or hyphens. **Note:** All forecast targets (e.g., incident hospital admission quantiles, categorical rate trend probabilities) should be submitted in the same weekly csv or parquet submission file as the hospital admission forecasts.

## Forecast file format 

The file must be a comma-separated value (csv) or parquet file with the following
columns (in any order):

-   `reference_date`
-   `target`
-   `horizon`
-   `target_end_date`
-   `location`
-   `output_type`
-   `output_type_id`
-   `value`

No additional columns are allowed. **Note:** for some targets not all column values will apply, e.g., seasonal peak targets do not have an associated `horizon`. In this case, cells should be left blank or “NA” (without quotes) should be entered for the non-applicable column in corresponding rows. 

The majority of values in each row of the file will be either a quantile, sample, or rate-trend prediction for a particular combination of location, date, and horizon. Please see Tables 1 and 2 for examples based on example dates. See details below for exceptions related to new optional peak targets.  

### `reference_date` 

Values in the `reference_date` column must be a date in the ISO format

    YYYY-MM-DD

This is the date from which all forecasts should be considered. This date is the Saturday following the submission Due Date, corresponding to the last day of the epiweek when submissions are made. The `reference_date` should be the same as the date in the filename but is included here to facilitate validation and analysis. 

### `target`

Values in the `target` column must be a character (string) and be one of
the following specific targets:

-   `wk inc flu hosp` 
-   `wk flu hosp rate change`
-   `wk inc flu prop ed visits`
-   `peak week inc flu hosp`
-   `peak inc flu hosp`
  
For samples, this should be `wk inc flu hosp`. 


### `horizon`
Values in the horizon column indicate the number of weeks between the reference_date and the target_end_date.  For influenza hospital admission forecasts and influenza proportion of emergency department visits this should be a number between -1 and 3 and rate change predictions should be a number between 0 and 3, where for example a horizon of 0 indicates that the prediction is a nowcast for the week of submission and a horizon of 1 indicates that the prediction is a forecast for the week after submission. See Tables 1 and 2 for examples. For the peak incidence and peak week targets, this columns hould be left blank/will not be used. 

### `target_end_date`

Values in the `target_end_date` column must be a date in the format

    YYYY-MM-DD
    
This is the last date of the forecast target's week. This will be the date of the Saturday at the end of the forecasted week. As a reminder, the `target_end_date` is the end date of the week during which the admissions are reported (see the data processing section for more details). Within each row of the submission file, the `target_end_date` should be equal to the `reference_date` + `horizon`*(7 days). For the peak incidence and peak week targets, this column should be left blank/will not be used.


### `location`

Values in the `location` column must be one of the "locations" in
this [location information file](../auxiliary-data/locations.csv) which
includes numeric FIPS codes for U.S. states,  territories, and districts, as well as "US" for national forecasts, included in the FluSight forecasting collaboration.

Please note that when writing FIPS codes, they should be written in as a character string to preserve any leading zeroes.

### `output_type`

Values in the `output_type` column are either

-   `quantile`
-   `pmf`
-   `sample`

This value indicates whether that row corresponds to a quantile forecast for incident hospital admissions, proportion of emergency department visits, or peak hospital admissions, a probability mass function (pmf) for categorical rate-trend forecasts or peak week, or a sample for incident hospital admission trajectories. Quantile forecasts are used in visualizations and to construct the primary FluSight ensemble. 

### `output_type_id`
Values in the `output_type_id` column specify identifying information for the output type.

#### quantile output

When the predictions are quantiles, values in the `output_type_id` column are a quantile probability level in the format

    0.###

 This value indicates the quantile probability level for for the
`value` in this row.

Teams must provide the following 23 quantiles:

0.01, 0.025, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4,
0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9,
0.95, 0.975, and 0.99

R: c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99) 
Python: quantiles =
np.append(np.append([0.01,0.025],np.arange(0.05,0.95+0.05,0.05)),
[0.975,0.99])

#### pmf output

For rate change forecasts, the output_type_id indicates the category that the predicted probability of occurrence should be associated with. Teams should provide the following categories:
"large_increase", "increase", "stable", "decrease" and "large_decrease". Please see Appendix 1: rate-trend forecast specifications for details on how each category is defined. Note that thresholds between categories differ from those used in the 2023-2024 season and that new threshold values have been added.

For the peak week target, the `output_type_id` should specify the last Saturday of each epidemic week in the season (2024-11-23 to 2025-05-31) in ISO format: YYYY-MM-DD.

#### sample output

For sample forecasts (trajectories), the output_type_id indicates which sample a set of predictions should be considered a part of. Please see related [Hubverse documentation](https://hubverse.io/en/latest/user-guide/sample-output-type.html) for examples. Here, a sample is a draw from a joint distribution for flu hospital admissions across multiple prediction horizons, showing the possible value of hospital admissions on each target date. The values for a single sample will be included in different rows of a submission file, corresponding to the different prediction horizons and target dates; the shared output_type_id across those rows allows us to link those values into a single sample trajectory.

For sample trajectories that are generated separately for each location, one valid way to set up output_type_id values would be to concatenate the two letter code for the location of the sample (e.g., MA) ad a two digit number identifying the sample index within that location. Since 100 samples are being collected for each trajectory, these numeric indices will be “00”, “01, … “99”, resulting in output_type_ids of MA00, MA01, …, MA 99. Each of those output_type_id values would appear across a set of rows in the submission file corresponding to different prediction horizons for MA. Similarly, for Florida forecasts, `output_type_id` values could be specified as FL00, … FL99. 

As indicated in the [FluSight-forecast-hub/hub-config/tasks.json](https://github.com/cdcepi/FluSight-forecast-hub/blob/main/hub-config/tasks.json) file, the components defining a sample are the “reference_date”, “location”, and “target”. Within each sample, these row elements will be repeated and then there will be a value associated with each horizon (-1, 0, 1, 2, 3) corresponding to a single run/connected trajectory.  We will only collect samples for the `wk inc flu hosp` target.

National forecasts can be provided as samples with the output_type_id values of US00, US01, … US99. National-level samples should only be provided if these forecasts are either jointly determined across all states, capturing dependence across locations, or if the national target is modeled directly, i.e., is not the sum of separately generated state-level forecasts.  

### `value`

Values in the value column are non-negative numbers indicating the `quantile` or `pmf` prediction for this row. For a `quantile` prediction, value is the inverse of the cumulative distribution function (CDF) for the target, location, and quantile associated with that row. For example, the 2.5 and 97.5 quantiles for a given target and location should capture 95% of the predicted values and correspond to the central 95% Prediction Interval. For the 2025-2026 season, we are requiring that teams submit integer values for the weekly incidence (`wk inc flu hosp`) and peak week intensity (`peak inc flu hosp`) targets.  For rate change forecasts(`wk flu hosp rate change`) and peak week forecasts (`peak week inc flu hosp`), values are required to sum to 1 across all output_type_ids for each target and location (as specified in the [hubverse documentation](https://hubverse.io/en/latest/user-guide/model-output.html)). For the emergency department visit proportion target (`wk inc flu prop ed visits`), values should be between 0 and 1 (inclusive). For samples, this will be an integer value corresponding to a particular sample for a hospital admission forecast. Each `reference_date`, `location`, and `target` grouping should have 100 sets of paired values, where each set consists of a value for each `horizon`. Values for samples should be integers greater than equal to 0.

### Example tables

**Table 1:** the reference date, target end dates, and the dates
included in the predicted EW for an example of the weekly hospital
admissions target with a reference date of Saturday, October 18, 2025.

| reference_date | horizon | target_end_date | target EW | target EW dates covered  |
|:---------------|:--------|:----------------|:----------|:-------------------------|
| 2025-10-18     | -1      | 2025-10-11      | 41        | 2025-10-05 to 2025-10-11 |
| 2025-10-18     | 0       | 2025-10-18      | 42        | 2025-10-12 to 2025-10-18 |
| 2025-10-18     | 1       | 2025-10-25      | 43        | 2025-10-19 to 2025-10-25 |
| 2025-10-18     | 2       | 2025-11-01      | 44        | 2025-10-26 to 2025-11-01 |
| 2025-10-18     | 3       | 2025-11-08      | 45        | 2025-11-02 to 2025-11-08 |


**Table 2:** the reference date, target end dates, and the dates
included in the predicted EW for an example of the rate trend target
with a reference date of Saturday, October 18, 2025. The rate trend
target describes differences in the hospital admission rate between the
baseline EW (one week prior to the EW of the reference date) and the
target EW.

| reference_date | horizon | target_end_date | target EW | target EW dates covered  | baseline EW | baseline EW dates covered |
|:---------------|:--------|:----------------|:----------|:-------------------------|:------------|:--------------------------|
| 2025-10-18     | 0       | 2025-10-18      | 42        | 2025-10-12 to 2025-10-18 | 41          | 2025-10-05 to 2025-10-11  |
| 2025-10-18     | 1       | 2025-10-25      | 43        | 2025-10-19 to 2025-10-25 | 41          | 2025-10-05 to 2025-10-11  |
| 2025-10-18     | 2       | 2025-11-01      | 44        | 2025-10-26 to 2025-11-01 | 41          | 2025-10-05 to 2025-10-11  |
| 2025-10-18     | 3       | 2025-11-08      | 45        | 2025-11-02 to 2025-11-08 | 41          | 2025-10-05 to 2025-10-11  |


## Forecast validation 

To ensure proper data formatting, pull requests for new data in
`model-output/` will be automatically run. Optionally, you may also run these validations locally.

### Pull request forecast validation

When a pull request is submitted, the data are validated through [Github
Actions](https://docs.github.com/en/actions) which runs the tests
present in [the hubValidations
package](https://github.com/Infectious-Disease-Modeling-Hubs/hubValidations). The
intent for these tests are to validate the requirements above. Please
[let us know](https://github.com/cdcepi/FluSight-forecast-hub/issues) if you are facing issues while running the tests.

### Local forecast validation

Optionally, you may validate a forecast file locally before submitting it to the hub in a pull request. Note that this is not required, since the validations will also run on the pull request. To run the validations locally, follow these steps:

1. Create a fork of the `FluSight-forecast-hub` repository and then clone the fork to your computer.
2. Create a draft of the model submission file for your model and place it in the `model-output/<your model id>` folder of this clone.
3. Install the hubValidations package for R by running the following command from within an R session:
``` r
remotes::install_github("Infectious-Disease-Modeling-Hubs/hubValidations")
```
4. Validate your draft forecast submission file by running the following command in an R session:
``` r
library(hubValidations)
hubValidations::validate_submission(
    hub_path="<path to your clone of the hub repository>",
    file_path="<path to your file, relative to the model-output folder>")
```

For example, if your working directory is the root of the hub repository, you can use a command similar to the following:
``` r
library(hubValidations)
hubValidations::validate_submission(
    hub_path=".",
    file_path="UMass-trends_ensemble/2023-10-07-UMass-trends_ensemble.csv")
```
The function returns the output of each validation check.

If all is well, all checks should either be prefixed with a `✓` indicating success or `ℹ` indicating a check was skipped, e.g.:
```
✓ FluSight-forecast-hub: All hub config files are valid.
✓ 2023-10-07-UMass-trends_ensemble.csv: File exists at path model-output/UMass-trends_ensemble/2023-10-07-UMass-trends_ensemble.csv.
✓ 2023-10-07-UMass-trends_ensemble.csv: File name "2022-10-22-team1-goodmodel.csv" is valid.
✓ 2023-10-07-UMass-trends_ensemble.csv: File directory name matches `model_id` metadata in file name.
✓ 2023-10-07-UMass-trends_ensemble.csv: `round_id` is valid.
✓ 2023-10-07-UMass-trends_ensemble.csv: File is accepted hub format.
...
```

If there are any failed checks or execution errors, the check's output will be prefixed with a `✖` or `!` and include a message describing the problem.

To get an overall assessment of whether the file has passed validation checks, you can pass the output of `validate_submission()` to `check_for_errors()`
```r
library(hubValidations)

validations <- validate_submission(
    hub_path = ".",
    file_path = "UMass-trends_ensemble/2023-10-07-UMass-trends_ensemble.csv")

check_for_errors(validations)
```
If the file passes all validation checks, the function will return the following output:

```r
✓ All validation checks have been successful.
```
If test failures or execution errors are detected, the function throws an error and prints the messages of checks affected. For example, the following output is returned when all other checks have passed but the file is being validated outside the submission time window for the round:

```r
! 2023-10-14-UMass-trends_ensemble.csv: Submission time must be within accepted submission window for round.  Current time
  2023-10-03 12:23:08 is outside window 2023-10-08 EDT--2023-10-16 23:59:59 EDT.
Error in `check_for_errors()`:
! 
The validation checks produced some failures/errors reported above.
```


## Weekly ensemble build 

Every Thursday morning, we will generate a FluSight ensemble influenza hospital admission forecast using valid forecast submissions in the current week by the Wednesday 11PM ET deadline. Some or all participant forecasts may be combined into an ensemble forecast to be published in real time along with the participant forecasts. In addition, some or all forecasts may be displayed alongside the output of a baseline model for comparison.


## Policy on late or updated submissions 

In order to ensure that forecasting is done in real time, all forecasts are required to be submitted to this repository by 11PM ET on Wednesdays each week. We do not accept late forecasts.

## Evaluation criteria
Forecasts will be evaluated using a variety of metrics, including weighted interval score (WIS) and its components and prediction interval coverage. The CMU [Delphi group's Forecast Evaluation Dashboard](https://delphi.cmu.edu/forecast-eval/) and the COVID-19 Forecast Hub periodic [Forecast Evaluation Reports](https://covid19forecasthub.org/eval-reports/) provide examples of evaluations using these criteria.

Evaluation will use official data reported from data.cdc.gov as reported at the end or following the final forecast date (depending on data availability).

# Rate-trend forecast specifications
In order to mitigate the impact of reporting revisions and noise inherent in small counts, all week pairs with a difference of fewer than 10 hospital admissions will be classified as having a "stable" trend. 


**For one-week ahead rate trends (horizon = 0):**

*Stable:* forecasted changes in hospital admissions qualify as stable if either the magnitude of the rate change is less than 0.3/100k OR the corresponding magnitude of the count change is less than 10.

*Increase:* positive forecasted changes that do not qualify as stable and for which the forecasted rate change is less than 1.7/100k.

*Large increase:* positive forecasted rate changes that do not qualify as stable and for which the forecasted rate change is larger than or equal to 1.7/100k.

*Decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is less than 1.7/100k.

*Large decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is larger than or equal to 1.7/100k.

**For two-week ahead rate trends (horizon = 1):**

*Stable:* forecasted changes in hospital admissions qualify as stable if either the magnitude of the rate change is less than 0.5/100k OR the corresponding magnitude of the count change is less than 10.

*Increase:* positive forecasted changes that do not qualify as stable and for which the forecasted rate change is less than 3/100k.

*Large increase:* positive forecasted rate changes that do not qualify as stable and for which the forecasted rate change is larger than or equal to 3/100k.

*Decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is less than 3/100k.

*Large decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is larger than or equal to 3/100k.

**For three-week ahead rate trends (horizon = 2):**

*Stable:* forecasted changes in hospital admissions qualify as stable if either the magnitude of the rate change is less than 0.7/100k OR the corresponding magnitude of the count change is less than 10.

*Increase:* positive forecasted changes that do not qualify as stable and for which the forecasted rate change is less than 4/100k.

*Large increase:* positive forecasted rate changes that do not qualify as stable and for which the forecasted rate change is larger than or equal to 4/100k.

*Decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is less than 4/100k.

*Large decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is larger than or equal to 4/100k.

**For four-week and five-week ahead rate trends (horizon = 3):**

*Stable:* forecasted changes in hospital admissions qualify as stable if either the magnitude of the rate change is less than 1/100k OR the corresponding magnitude of the count change is less than 10.

*Increase:* positive forecasted changes that do not qualify as stable and for which the forecasted rate change is less than 5/100k.

*Large increase:* positive forecasted rate changes that do not qualify as stable and for which the forecasted rate change is larger than or equal to 5/100k.

*Decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is less than 5/100k.

*Large decrease:* negative forecasted rate changes that do not qualify as stable and for which the magnitude of the forecasted rate change is larger than or equal to 5/100k.

