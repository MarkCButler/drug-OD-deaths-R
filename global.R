###############################################################################
# Data sources

# The population.csv file loaded here was created by manually modifying the
# .xlsx file downloaded from www.census.gov.  The csv file contains population
# estimates for the US and each of the 50 states.  For each of the years 2014
# - 2019, there is an estimate of the population on July 1.
population <- read.csv('./data/population.csv', row.names = 1, check.names = F)

# The name of the database and table containing death counts due to drug
# overdose.
db.name <- './data/deaths.sqlite'
table.name <- 'deaths'

###############################################################################
# Variables involving the labels for plotted curves

# The short curve labels defined by the variable curve.labels are stored in
# the database for convenience.  Short curve labels are also hard-coded in a
# few places (e.g., in the definition of the data frame code.table presented
# in the technical notes), and so they should not be changed.
#
# The corresponding long curve labels are displayed in the technical notes and
# in the plots--these may change as the appearance of the plots is tweaked.
curve.labels <- c('all.drug.OD',
                  'all.opioids',
                  'prescription.opioids',
                  'synthetic.opioids',
                  'heroin',
                  'cocaine',
                  'other.stimulants')
long.curve.labels <- c('All drug overdose deaths',
                       'All opioids',
                       'Prescription opioid pain relievers',
                       'Fentanyl and other synthetic opioids',
                       'Heroin',
                       'Cocaine',
                       'Methamphetamine and other stimulants')

# When a vector of choices is passed to selectizeInput in the user interface,
# it is the element names rather than the elements themselves that are
# displayed.  Because of this, it is convenient to use the long curve labels
# as names for the vector curve.labels.
names(curve.labels) <- long.curve.labels

# By naming the elements of long.curve.labels using the short labels in
# curve.labels, we have the option of selecting the long labels (that may be
# changed freely) using hard-coded short labels that do not change.  This is
# done in multiple places in the app.
names(long.curve.labels) <- curve.labels

###############################################################################
# Definitions involving the choice of statistics to display

# Choice of statistic for showing drug-overdose deaths.
statistic.labels <- c('death.count', 'normalized.death.count', 'percent.change')
long.statistic.labels <- c('Number of deaths',
                           'Deaths per 100,000 people',
                           'Percent change in one year')
names(statistic.labels) <- long.statistic.labels
names(long.statistic.labels) <- statistic.labels

# Character vectors used in plot titles for the map and time-development tabs
# are defined here to facilitate keeping them consistent with the main
# variable statistic.labels.  (For instance:  given an index in
# statistic.labels, we want to extract the corresponding value from
# map.titles, so the two vectors need to be kept consistent.)
map.titles <- c('Number of drug-overdose deaths',
                'Number of drug-overdose deaths per 100,000 people',
                'Percent change in drug-overdose deaths')
time.titles <- c('Number of deaths',
                 'Number of deaths per 100,000 people',
                 'Percent change in one year')
colorbar.titles <- c('Number of deaths',
                     'Deaths per\n100,000 people',
                     'Percent change\nin one year')
names(colorbar.titles) <- statistic.labels

# After the data has been processed, the column names for the three different
# choices of statistic are 'Value', 'Normalized.value', and 'Percent.change'.
# Given a user selection for the statistic to display, we need to find the
# corresponding column.  Rather than imposing a rigid correspondence between the
# column names and the strings in the vector statistic.labels, define the
# function get.column.name to handle the correspondence.
get.column.name <- function(data, statistic.label) {
    if (statistic.label == 'normalized.death.count') {
        column.name <- 'Normalized.value'
    } else if ((statistic.label == 'percent.change') && ('Percent.change' %in% colnames(data))) {
        column.name <- 'Percent.change'
    } else {
        column.name <- 'Value'
        if (statistic.label != 'death.count') {
            cat(file = stderr(),
                '\nWARNING:  Unable to find a valid choice for the column to display ',
                'in get.column.name\n')
        }
    }

    return(column.name)
}

###############################################################################
# Variables associated with other widgets in the user interface

dataset.labels <- c('drug.OD.data', 'population.data')
names(dataset.labels) <- c('Drug OD deaths', 'Annual state populations')

time.periods <- paste('September', seq(from = 2015, to = 2019))

state.labels <- append(c('United States'), state.name)

###############################################################################
# Function needed for convenient handling of dates.

# In the data on deaths by drug OD, dates are given in the format 'January
# 2015'.  Define a function for converting this format to a Date object.
convert.to.date <- function(month.year) {
    date.object <-  as.Date(paste('01', month.year),
                           format = '%d %B %Y')
    return(date.object)
}
