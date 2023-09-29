# Gold standard data 

The data-truth folder contains the "gold standard" data that forecasts 
are eventually compared to. 

*Table of Contents*

-   [Data sources](#data-sources)
-   [Hospitalization data](#hospitalization-data)
-   [Accessing gold standard data](#accessing-gold-standard-data)


Data sources
----------------------

Influenza hospitalization data are taken from the [HealthData.gov COVID-19 Reported Patient Impact and Hospital Capacity by State Timeseries](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh).

*Please note the following detail from the [dataset description](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh)*: 

"The file will be updated regularly and provides the latest values reported by each facility within the last four days for all time. This allows for a more comprehensive picture of the hospital utilization within a state by ensuring a hospital is represented, even if they miss a single day of reporting."  

This implies that some values may be repeated. Extra caution should be applied in these cases and in particular for interpreting data for the current day, as hospitals report hospital admissions for the previous day (further detail below).


Some of these data are also available programmatically through the [EpiData](https://cmu-delphi.github.io/delphi-epidata/) API. 


Hospitalization data
------------

### HealthData.gov Hospitalization Timeseries

The gold standard data that hospitalization forecasts (`inc hosp` targets) will
be evaluated against are the [HealthData.gov COVID-19 Reported Patient
Impact and Hospital Capacity by State
Timeseries](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh).
These data are released weekly.


Previously collected influenza data from the 2020-21 influenza season ([Fields 33-38](https://www.hhs.gov/sites/default/files/covid-19-faqs-hospitals-hospital-laboratory-acute-care-facility-data-reporting.pdf)) are included in the [COVID-19 Reported Patient Impact and Hospital Capacity by State Timeseries](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh) dataset. This dataset is updated regularly based on data reported through the day prior. Therefore, datasets updated on Monday will include data reported through the immediately preceding Sunday, and this dataset will capture influenza hospital admissions that occurred through Saturday (see the data processing section for more information).

Reporting of the influenza fields 33-35 became mandatory in February 2022, and additional details are provided in the current [hospital reporting guidance and FAQs](https://www.hhs.gov/sites/default/files/covid-19-faqs-hospitals-hospital-laboratory-acute-care-facility-data-reporting.pdf). Numbers of reporting hospitals increased after the period that reporting became mandatory in early 2022 but have since stabilized at high levels of compliance.  The number of hospitals reporting these data each day by state are available in the previous_day_admission_influenza_confirmed_coverage variable found in the [COVID-19 Reported Patient Impact and Hospital Capacity by State Timeseries](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh) dataset. 

These data are also available in a [facility-level dataset](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/anag-cw7u); data values less than 4 are suppressed in the [facility-level dataset](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/anag-cw7u). Additional historical influenza surveillance data from other surveillance systems are available at [https://www.cdc.gov/flu/weekly/fluviewinteractive.htm](https://www.cdc.gov/flu/weekly/fluviewinteractive.htm). These data are updated every Friday at noon Eastern Time. The "cdcfluview" R package can be used to retrieve these data. Additional potential data sources are available in Carnegie Mellon University's [Epidata API](https://delphi.cmu.edu/).




### Data processing

The hospitalization truth data is computed based on the `previous_day_admission_influenza_confirmed`
field which provides the new daily admissions with a confirmed diagnosis of influenza.

Since these admission data are listed as “previous day” admissions in
the raw data, the truth data shifts values in the `date` column one day
earlier so that `inc hosp` align with the date the admissions occurred.

As an example, the following data from HealthData.gov

       date    | previous_day_admission_influenza_confirmed 
    -----------|--------------------------------------------
    2020-10-30 |                  5                         

would turn into the following observed data for *daily* incident
hospitalizations

       date    | incident_hospitalizations
    -----------|----------------------------
    2020-10-29 |          5               

National hospitalization, i.e. US, data are constructed from these data
by summing the data across all 50 states, Washington DC (DC), Puerto
Rico(PR), and the US Virgin Islands (VI). The HHS data do not include
admissions for additional territories.

Daily admission counts are then aggregated into epidemiological weeks. 

For week-ahead forecasts, we will use the specification of
epidemiological weeks (EWs) [defined by the US
CDC](https://wwwn.cdc.gov/nndss/document/MMWR_Week_overview.pdf) which
run Sunday through Saturday. For example, a 1-week-ahead forecast made for the Forecast Due Date of Monday, November 28, 2022, would correspond to EW48, which ends on (i.e., has a `target_end_date` of Saturday, December 3, 2022). A 2-week-ahead forecast made for that date would correspond to EW49 and have a `target_end_date` of Saturday, December 10, 2022. There are standard software packages to convert from dates to epidemic weeks and vice versa (e.g. [MMWRweek](https://cran.r-project.org/web/packages/MMWRweek/) for R and [pymmwr](https://pypi.org/project/pymmwr/) and [epiweeks](https://pypi.org/project/epiweeks/) for Python).


### Additional resources

Here are a few additional resources that describe these hospitalization
data:

-   [data dictionary for the
    dataset](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/g62h-syeh)
-   the [official document describing the “guidance for hospital
    reporting”](https://www.hhs.gov/sites/default/files/covid-19-faqs-hospitals-hospital-laboratory-acute-care-facility-data-reporting.pdf)


Accessing gold standard data
----------
While we make efforts to create accurate, verified, clean versions of the gold standard data, these should be seen as secondary sources to the original data at the HHS Protect site.

### CSV files
A set of comma-separated plain text files are automatically updated every week with the latest observed values for incident hospitalizations. A corresponding CSV file is created in `data-truth/truth-Incident Hospitalizations.csv`.


### Resources for Accessing Hospitalization Data

Our collaborators at the [Delphi Group at
CMU](https://delphi.cmu.edu/) have provided resources to make these data (as well as archived versions) available through their [Delphi Epidata
API](https://cmu-delphi.github.io/delphi-epidata/api/README.html).
The current weekly timeseries of the hospitalization data as well as
prior versions of the data are available under the ["covidcast"
endpoint of the
API](https://cmu-delphi.github.io/delphi-epidata/api/covidcast.html). In particular, under the ["hhs" data source name](https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/hhs.html), there are flu-related HHS signals:

- *Confirmed Influenza Admissions per day* `confirmed_addmissions_influenza_1d`
- *Confirmed Influenza Admissions (smoothed with a 7 day trailing average)* `confirmed_admissions_influenza_1d_7dav`

Also under the "covidcast" endpoint, under the ["chng" data source name](https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/chng.html), there are signals pertaining to confirmed influenza from outpatient visits:

- *Confirmed Influenza from Doctor's Visits* `smoothed_outpatient_flu`
- *Confirmed Influenza from Doctors'Visits (with weekday adjustment)* `smoothed_adj_outpatient_flu`

Other related and potentially helpful endpoints of the Epidata API include:
- [COVID-19 Hospitalization by State](https://cmu-delphi.github.io/delphi-epidata/api/covid_hosp.html)
- [COVID-19 Hospitalization by Facility](https://cmu-delphi.github.io/delphi-epidata/api/covid_hosp_facility.html)
- [COVID-19 Hospitalization:  Facility Lookup](https://cmu-delphi.github.io/delphi-epidata/api/covid_hosp_facility_lookup.html)

To access these data, teams can utilize the COVIDCast [Rpackage](https://cmu-delphi.github.io/covidcast/covidcastR/) or [Python package](https://cmu-delphi.github.io/covidcast/covidcast-py/html/).


