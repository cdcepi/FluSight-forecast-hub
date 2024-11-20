# Target data 

The target-data folder contains the laboratory confirmed influenza hospital admission ("gold standard") data that FluSight forecasts are eventually compared to. Influenza hospitalization data are taken from the [National Healthcare Safety Network Hospital Respitatory Dataset](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/ua7e-t2fy/about_data).

*Table of Contents*

-   [Hospitalization data](#hospitalization-data)
-   [Other data sources](#data-sources)
-   [Accessing target data](#accessing-target-data)


Hospitalization data
----------------------

### NHSN Weekly Hospital Respiratory Data

FluSight hospital admission prediction targets (`wk inc flu hosp`,`wk flu hosp rate changes`, `peak week inc flu hosp`, and `peak inc flu hosp`) for this season will be based on the ['total number of patients hospitalized with influenza captured for the Wednesday of the reporting week'](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/ua7e-t2fy/about_data) reported through CDC's NHSN (the dataset formerly known as HHS-Protect), [Weekly Hospital Respiratory Data](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/mpgq-jmmr/about_data).
These data are released weekly.



Previously collected influenza data from the 2020-21, 2022-23, and 2023-2024 influenza seasons are included in the NHSN Weekly Hospital Respiratory Data as well as originally in the archived COVID-19 Reported Patient Impact and Hospital Capacity by State Timeseries dataset. Reporting of the influenza fields 33-35 became mandatory in February 2022, and additional details are provided in the current [hospital reporting guidance and FAQs](https://www.cdc.gov/nhsn/psc/hospital-respiratory-reporting.html). Numbers of reporting hospitals increased after the period that reporting became mandatory in early 2022 but have since stabilized at high levels of compliance.  The number of hospitals reporting these data each week by state are available in the `totalconffluhosppatshosprep` variable found in the Weekly Hospital Respiratory Dataset.

[Weekly official counts](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/ua7e-t2fy/about_data) are publicly released on Fridays. [Preliminary counts](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/mpgq-jmmr/about_data) are released on Wednesdays. Official counts can be revised in subsequent data updates.


*Please note the following detail from the [dataset description](https://data.cdc.gov/Public-Health-Surveillance/Weekly-Hospital-Respiratory-Data-HRD-Metrics-by-Ju/ua7e-t2fy/about_data)*: 

"Data quality: While CDC reviews reported data for completeness and errors and corrects those found, some reporting errors might still exist within the data. CDC and partners work with reporters to correct these errors and update the data in subsequent weeks. Data reported as of December 1, 2020 are subject to thorough, routine data quality review procedures, including identifying and excluding invalid values from metric calculations and application of error correction methodology; data prior to this date may have anomalies that are not yet resolved. Data prior to August 1, 2020, are unavailable. As a result of data quality implementation and submission of any backfilled data, data and metrics might fluctuate or change week-over-week after initial posting."

This implies that some values may be repeated. Extra caution should be applied in these cases and in particular for interpreting data the most recent week of data, as hospitals report hospital admissions for the previous day (further detail below).


Some of these data are also available programmatically through the [EpiData](https://cmu-delphi.github.io/delphi-epidata/) API. See accessing target (truth) data section below for details.


Other data sources
------------

Percent of Emergency Department visits with a specified pathogen (COVID-19, Influenza, and Respiratory Syncytial Virus) out of all emergency department visits in a given epiweek are reported by the CDC National Syndromic Surveillance Program (NSSP) and provided in the [2023 Respiratory Virus Response - NSSP Emergency Department Visits dataset](https://data.cdc.gov/Public-Health-Surveillance/2023-Respiratory-Virus-Response-NSSP-Emergency-Dep/vutn-jzwm).  Weekly national-level Emergency Department Visits for these pathogens are available for download by age-group in this [landing page](https://www.cdc.gov/ncird/surveillance/respiratory-illnesses/index.html).   

Additional historical influenza surveillance data from other surveillance systems are available at [https://www.cdc.gov/flu/weekly/fluviewinteractive.htm](https://www.cdc.gov/flu/weekly/fluviewinteractive.htm). These data are updated every Friday at noon Eastern Time. The "cdcfluview" R package can be used to retrieve these data. Additional potential data sources are available in Carnegie Mellon University's [Epidata API](https://delphi.cmu.edu/).


### Data processing

The hospitalization target data is computed based on the `totalconfflunewadm`
field which provides the new weekly admissions with a confirmed diagnosis of influenza.

For each horizon of predictions, we will use the specification of
epidemiological weeks (EWs) [defined by the US
CDC](https://ndc.services.cdc.gov/wp-content/uploads/MMWR_Week_overview.pdf) which
run Sunday through Saturday.There are standard software packages to convert from dates to epidemic weeks and vice versa (e.g. [MMWRweek](https://cran.r-project.org/web/packages/MMWRweek/) for R and [pymmwr](https://pypi.org/project/pymmwr/) and [epiweeks](https://pypi.org/project/epiweeks/) for Python).


### Additional resources

Here are a few additional resources that describe these hospitalization
data:

-   [data dictionary for the
    dataset](https://www.cdc.gov/nhsn/pdfs/pscmanual/Hospital-Respiratory-Data-Weekly-Template-Mapping.pdf)
-   the [official document describing the **guidance for hospital
    reporting**](https://www.cdc.gov/nhsn/pdfs/pscmanual/HRD-Protocol-Final.pdf)


Accessing target (truth) data
----------
While we make efforts to create clean versions of the weekly target data, these should be seen as secondary sources to the original data at the HHS Protect site. National hospitalization, i.e., US, data are constructed from these data by summing the data across all 50 states, Washington DC (DC), and Puerto Rico (PR). Note that due to low counts in additional territories, jurisdictions such as the US Virgin Islands (VI) and American Samoa (AS) will not be included.       
Note that reported data are occasionally revised as data are updated. Please see appendix below for information on accessing archived data versions.


### CSV files
A set of comma-separated plain text files are automatically updated every week with the latest observed values for incident hospitalizations. A corresponding CSV file is created in `target-data/target-hospital-admissions.csv`.


### Resources for Accessing Hospitalization Data

Version history of NHSN hospitalization data can be accessed through the [COVID-19 Reported Patient Impact ad Hospital Capacity by State Timeseries Archive Repository](https://healthdata.gov/dataset/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/qqte-vkut/about_data).Our collaborators at the [Delphi Group at
CMU](https://delphi.cmu.edu/) have provided resources to make these data (as well as archived versions) available through their [Delphi Epidata
API](https://cmu-delphi.github.io/delphi-epidata/). State-level hospitalization time series data prepared from the old reporting form, as well as prior versions of this time series, are available under the ["covidcast" endpoint of the API](https://cmu-delphi.github.io/delphi-epidata/api/covidcast.html) with the ["hhs" data source name](https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/hhs.html) and `confirmed_admissions_influenza_1d` signal name.

**Note:** The covidcast "hhs" data source shifts dates so that the time_values reflect date of admissions, not the date after admissions for the time period when data was reported using the previous_day_admission_influenza_confirmed field.

Various other data sets and their version histories, including data sets not available elsewhere, are available and continue to be added to the Epidata API.  For influenza this season, these include:

- [National Syndromic Surveillance Program data](https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/nssp.html)
- [Google Symptoms data](https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/google-symptoms.html)
- [Additional fields for state-level HHS&NHSN hospitalization reporting (old form)](https://cmu-delphi.github.io/delphi-epidata/api/covid_hosp.html) 
- [Facility-level hospitalization reporting (old form)](https://cmu-delphi.github.io/delphi-epidata/api/covid_hosp_facility.html) 
- [Facility lookup](https://cmu-delphi.github.io/delphi-epidata/api/covid_hosp_facility_lookup.html)

Other data available in the API are listed in the [API documentation](https://cmu-delphi.github.io/delphi-epidata/) and [signal discovery tool](https://delphi.cmu.edu/signals/) (in development). To access these data, teams can utilize the [epidatr R package](https://cmu-delphi.github.io/epidatr/) or [epidatpy Python package](https://cmu-delphi.github.io/epidatpy/). Some basic examples of pulling old influenza data are available [here](https://github.com/cmu-delphi/flusight-helper-snippets).

