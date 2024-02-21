# Target data 

The target-data folder contains the laboratory confirmed influenza hospital admission ("gold standard") data that FluSight forecasts are eventually compared to. Influenza hospitalization data are taken from the [HealthData.gov COVID-19 Reported Patient Impact and Hospital Capacity by State Timeseries](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh).

*Table of Contents*

-   [Hospitalization data](#hospitalization-data)
-   [Other data sources](#data-sources)
-   [Accessing target data](#accessing-target-data)


Hospitalization data
----------------------

### HealthData.gov Hospitalization Timeseries

FluSight hospital admission prediction targets (`wk inc flu hosp` and `wk flu hosp rate changes`) for this season will continue to be based on the influenza 'previous day's admissions with laboratory confirmed influenza virus infection' [Field 34](https://www.hhs.gov/sites/default/files/covid-19-faqs-hospitals-hospital-laboratory-acute-care-facility-data-reporting.pdf) reported through CDC's NHSN (the dataset formerly known as HHS-Protect), [HealthData.gov COVID-19 Reported Patient
Impact and Hospital Capacity by State
Timeseries](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh).
These data are released weekly.



Previously collected influenza data from the 2020-21 and the 2022-23 influenza seasons (Fields 33-38) are included in the COVID-19 Reported Patient Impact and Hospital Capacity by State Timeseries dataset. Reporting of the influenza fields 33-35 became mandatory in February 2022, and additional details are provided in the current [hospital reporting guidance and FAQs](https://www.hhs.gov/sites/default/files/covid-19-faqs-hospitals-hospital-laboratory-acute-care-facility-data-reporting.pdf). Numbers of reporting hospitals increased after the period that reporting became mandatory in early 2022 but have since stabilized at high levels of compliance.  The number of hospitals reporting these data each day by state are available in the previous_day_admission_influenza_confirmed_coverage variable found in the COVID-19 Reported Patient Impact and Hospital Capacity by State Timeseries dataset.

During the 2021-22 and 2022-23 influenza forecasting seasons, the dataset was updated daily based on data reported through the day prior. Therefore, datasets updated on Monday would include data reported through the immediately preceding Sunday, and this data snapshot would capture influenza hospital admissions that occurred through Saturday (see the data processing section for more information). As of June 11, 2023, the reporting cadence changed to weekly, so that qualifying facilities are required to report daily hospitalizations for the previous week to the [National Healthcare Safety Network (NHSN)](https://www.cdc.gov/nhsn/index.html) on each Tuesday, as indicated in the [hospital reporting guidance](https://www.hhs.gov/sites/default/files/covid-19-faqs-hospitals-hospital-laboratory-acute-care-facility-data-reporting.pdf). 

Aggregated official counts are publicly released on Fridays. Official counts can be revised in subsequent data updates.
These data are also available in a facility-level dataset; data values less than 4 are suppressed in the [facility-level dataset](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/anag-cw7u). 


*Please note the following detail from the [dataset description](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh)*: 

"The file will be updated regularly and provides the latest values reported by each facility within the last four days for all time. This allows for a more comprehensive picture of the hospital utilization within a state by ensuring a hospital is represented, even if they miss a single day of reporting."  

This implies that some values may be repeated. Extra caution should be applied in these cases and in particular for interpreting data the most recent week of data, as hospitals report hospital admissions for the previous day (further detail below).


Some of these data are also available programmatically through the [EpiData](https://cmu-delphi.github.io/delphi-epidata/) API. See accessing target (truth) data section below for details.


Other data sources
------------

Influenza hospitalization admissions data is also available in a [facility-level dataset](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/anag-cw7u); data values less than 4 are suppressed in the [facility-level dataset](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/anag-cw7u). 

Percent of Emergency Department visits with a specified pathogen (COVID-19, Influenza, and Respiratory Syncytial Virus) out of all emergency department visits in a given epiweek are reported by the CDC National Syndromic Surveillance Program (NSSP) and provided in the [2023 Respiratory Virus Response - NSSP Emergency Department Visits dataset](https://data.cdc.gov/Public-Health-Surveillance/2023-Respiratory-Virus-Response-NSSP-Emergency-Dep/vutn-jzwm).  Weekly national-level Emergency Department Visits for these pathogens are available for download by age-group in this [landing page](https://www.cdc.gov/ncird/surveillance/respiratory-illnesses/index.html).   

Additional historical influenza surveillance data from other surveillance systems are available at [https://www.cdc.gov/flu/weekly/fluviewinteractive.htm](https://www.cdc.gov/flu/weekly/fluviewinteractive.htm). These data are updated every Friday at noon Eastern Time. The "cdcfluview" R package can be used to retrieve these data. Additional potential data sources are available in Carnegie Mellon University's [Epidata API](https://delphi.cmu.edu/).


### Data processing

The hospitalization target data is computed based on the `previous_day_admission_influenza_confirmed`
field which provides the new daily admissions with a confirmed diagnosis of influenza.

CDC has been reporting COVID hospital admission data on public facing websites using the dates listed in the date field, rather than shifting the admissions to the previous date to represent the actual date of admission. This season, FluView and FluSight will adopt this practice and no longer shift the dates to account for the actual event date of admission. Influenza hospitalization forecasts should no longer shift the admissions data by one day before aggregating to the weekly epiweek count, and epiweek forecasts this season will include admissions reported Sunday to Saturday. This also aligns with the availability of data from this system now that hospitals are required to report data Sunday to Saturday (capturing admissions that occurred Saturday through Friday) by the following Tuesday. These changes are only for FluSight influenza forecasts, not for COVID forecasts. We will generate a new dataset with the observed target weekly values that no longer shifts the data by one day and will be stored in this subdirectory.

For each horizon of predictions, we will use the specification of
epidemiological weeks (EWs) [defined by the US
CDC](https://wwwn.cdc.gov/nndss/document/MMWR_Week_overview.pdf) which
run Sunday through Saturday. As an example, if 17 confirmed influenza hospital admissions were reported in the `previous_day_admission_influenza_confirmed` field in a row where the `date` field was 2023-11-15, then the target dataset would assign those 17 hospital admissions to a date of 2023-11-15. These hospital admissions would then be counted towards the weekly total computed for EW46 in 2023, which runs from 2023-11-12 through 2023-11-18. There are standard software packages to convert from dates to epidemic weeks and vice versa (e.g. [MMWRweek](https://cran.r-project.org/web/packages/MMWRweek/) for R and [pymmwr](https://pypi.org/project/pymmwr/) and [epiweeks](https://pypi.org/project/epiweeks/) for Python).


### Additional resources

Here are a few additional resources that describe these hospitalization
data:

-   [data dictionary for the
    dataset](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh)
-   the [official document describing the **guidance for hospital
    reporting**](https://www.hhs.gov/sites/default/files/covid-19-faqs-hospitals-hospital-laboratory-acute-care-facility-data-reporting.pdf)


Accessing target (truth) data
----------
While we make efforts to create clean versions of the weekly target data, these should be seen as secondary sources to the original data at the HHS Protect site. National hospitalization, i.e., US, data are constructed from these data by summing the data across all 50 states, Washington DC (DC), and Puerto Rico (PR). Note that due to low counts in additional territories, such as the US Virgin Islands (VI) and American Samoa (AS) will not be included.       
Note that reported data are occasionally revised as data are updated. Please see appendix below for information on accessing archived data versions.


### CSV files
A set of comma-separated plain text files are automatically updated every week with the latest observed values for incident hospitalizations. A corresponding CSV file is created in `target-data/target-Incident-Hospitalizations.csv`.


### Resources for Accessing Hospitalization Data

Our collaborators at the [Delphi Group at
CMU](https://delphi.cmu.edu/) have provided resources to make these data (as well as archived versions) available through their [Delphi Epidata
API](https://cmu-delphi.github.io/delphi-epidata/api/README.html).
The current weekly timeseries of the hospitalization data as well as
prior versions of the data are available under the ["covidcast"
endpoint of the
API](https://cmu-delphi.github.io/delphi-epidata/api/covidcast.html). In particular, under the ["hhs" data source name](https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/hhs.html), there are flu-related HHS signals, such as:

- *Confirmed Influenza Admissions per day* `confirmed_addmissions_influenza_1d`


Also under the "covidcast" endpoint, under the ["chng" data source name](https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/chng.html), there are signals pertaining to confirmed influenza from outpatient visits:

- *Confirmed Influenza from Doctor's Visits* `smoothed_outpatient_flu`
- *Confirmed Influenza from Doctors'Visits (with weekday adjustment)* `smoothed_adj_outpatient_flu`

**Note:** the covidcast "hhs" data source does shift dates so that time_values reflect date of admissions, not the date after admissions. FluSight forecasting teams using covidcast should plan to account for this difference from the FluSight target definition (e.g., by reversing this shift) while preparing forecast submissions.

Other related and potentially helpful endpoints of the Epidata API include:
- [COVID-19 Hospitalization by State](https://cmu-delphi.github.io/delphi-epidata/api/covid_hosp.html)
- [COVID-19 Hospitalization by Facility](https://cmu-delphi.github.io/delphi-epidata/api/covid_hosp_facility.html)
- [COVID-19 Hospitalization:  Facility Lookup](https://cmu-delphi.github.io/delphi-epidata/api/covid_hosp_facility_lookup.html)

To access these data, teams can use the [R Epidatr package](https://github.com/cmu-delphi/epidatr), the draft [epidatpy package](https://github.com/cmu-delphi/epidatpy), or the legacy COVIDCast [R package](https://cmu-delphi.github.io/covidcast/covidcastR/) or [Python package](https://cmu-delphi.github.io/covidcast/covidcast-py/html/). Basic examples of pulling data with these packages are provided below; *additional related snippets are available [here](https://github.com/cmu-delphi/flusight-helper-snippets)*.

```
## In R #########################################################################
 
# install.packages("epidatr")

library(magrittr) # for `%>%`

# Fetch daily HHS hospitalization count data for all states and territories for
# April 2022 using `epidatr`, a draft new client package for accessing the
# Delphi Epidata API:
april <- epidatr::pub_covidcast(
  "hhs", "confirmed_admissions_influenza_1d",
  "state", "day",
  geo_values = "*",
  time_values = epidatr::epirange(20220401, 20220430)
)

# Fetch these measurements as they were reported on May 10, rather than the
# current version:
april_as_of_may10 <-
  epidatr::pub_covidcast(
	"hhs", "confirmed_admissions_influenza_1d",
	"state", "day",
	"*",
	epidatr::epirange(20220401, 20220430),
	as_of = 20220510
  )

# Fetch the first data set using the older `covidcast` package:
# remotes::install_github("cmu-delphi/covidcast", subdir="R-packages/covidcast")
april_with_covidcast = covidcast::covidcast_signal(
  "hhs", "confirmed_admissions_influenza_1d",
  as.Date("2022-04-01"), as.Date("2022-04-30"),
  "state", "*"
)

```

```
## In Python #########################################################################
 
# pip install -e "git+https://github.com/cmu-delphi/epidatpy.git#egg=epidatpy"
# pip install covidcast
 
import datetime
 
import pandas as pd
 
import epidatpy.request
import covidcast
 
# Fetch daily HHS hospitalization count data for all states and territories for
# April 2022 using `epidatpy`, a draft new client package for accessing the
# Delphi Epidata API:
cce = epidatpy.request.CovidcastEpidata()
april = cce[("hhs", "confirmed_admissions_influenza_1d")].call(
   	"state", "*",
   	epidatpy.request.EpiRange(20220401, 20220430)
).df()
 
# Fetch these measurements as they were reported on May 10, rather than the
# current version:
april_as_of_may10 = cce[("hhs", "confirmed_admissions_influenza_1d")].call(
   	"state", "*",
   	epidatpy.request.EpiRange(20220401, 20220430),
   	as_of = 20220510
).df()
 
# Fetch the first data set using the older `covidcast` package:
april_with_covidcast = covidcast.signal(
  "hhs", "confirmed_admissions_influenza_1d",
  datetime.date(2022, 4, 1), datetime.date(2022, 4, 30),
  "state", "*"
)
 
```
