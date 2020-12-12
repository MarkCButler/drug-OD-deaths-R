# drug-OD-deaths-R

This is an interactive web app written in R for exploring data on
drug-overdose deaths in the US.  The app is hosted at

https://markcbutler.shinyapps.io/drug-od-deaths/

Note that a similar web app implemented in Python is available at the repo

https://github.com/MarkCButler/drug-OD-deaths-Python

The
[data on drug-overdose deaths](https://data.cdc.gov/NCHS/VSRR-Provisional-Drug-Overdose-Death-Counts/xkb8-kh2a),
covering the period from January 2015 to September 2019, was converted to a
SQLite database by running the code in *preprocess.R*.  The data separates
drug-overdose deaths into categories based on the type of drug involved.
Death counts in different categories are given for individual states and for
the full US.

[Annual population estimates](https://www.census.gov/data/datasets/time-series/demo/popest/2010s-state-total.html)
are interpolated using the functions in *interpolate.R*.  The interpolated
population values are used to convert the death counts given in the raw data
to deaths per unit population.

The app offers interactive plots showing the time development and the
geographic distribution of drug-overdose deaths.  For each plot, the app
user has a choice between three statistics to display:  number of deaths,
number of deaths per 100,000 people, and percent change in one year.

For the plot showing time development, multiple categories of drug-overdose
deaths can be compared in a single plot for a selected state or for the full
US.

The plot showing geographic distribution is a choropleth map colored by the
selected statistic.  By choosing different time periods for the data displayed
on the map, the user can monitor the variation in geographic distribution with
time.

The summary tab of the app presents three plots illustrating take-away
messages that can be found using the interactive plots in the app.
