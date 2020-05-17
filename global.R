###############################################################################
# Data sources

# The name of the csv file containing annual population estimates.
population.csv <- './data/population.csv'

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

# The technical notes tab of the app includes a table giving the
# correspondence between plot labels and ICD-10 codes for cause of death.  In
# this context, it is helpful to have short, fixed names for the elements of
# long.curve.labels, so that we can hard code the process of taking a
# reordered subset of long.curve.labels.
names(long.curve.labels) <- curve.labels

###############################################################################
# Variables used in selectizeInput widgets

# Choice of statistic for showing drug-overdose deaths.
statistic.labels <- c('death.count', 'normalized.death.count', 'percent.change')
names(statistic.labels) <- c('Number of deaths',
                             'Number of deaths per 100,000 people',
                             'Percent change from prior year')
# Labels used in the map and time-development tabs, given here to facilitate
# keeping them consistent with the main variable statistic.labels.
map.statistic.labels <- c('Number of drug-overdose deaths',
                          'Number of drug-overdose deaths per 100,000 people',
                          'Percent change in drug-overdose deaths')
time.statistic.labels <- c('Number of deaths',
                           'Number of deaths per 100,000 people',
                           'Percent change during one year')


dataset.labels <- c('drug.OD.data', 'population.data')
names(dataset.labels) <- c('Drug OD deaths', 'Annual state populations')

time.periods <- paste('September', seq(from = 2015, to = 2019))

state.labels <- append(c('United States'), state.name)

###############################################################################
# Objects needed for convenient handling of dates.

# In the data on deaths by drug OD, dates are given in the format 'January
# 2015'.  Define a function for converting this format to a Date object.
convert.to.date <- function(month.year) {
    date.object <-  as.Date(paste('01', month.year),
                           format = '%d %B %Y')
    return(date.object)
}

# The first date for which data is available.
dataset.start.date <- convert.to.date('January 2015')
