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

# The short curve labels are stored in the database for convenience.  Also
# short curve labels are hard-coded in a few places (e.g., in the definition
# of code.labels at the begnning of server.R), and so they should not be
# changed.
#
# The corresponding long curve labels are displayed in the technical notes and
# in the plots--these may change as the appearance of the plots is tweaked.
short.curve.labels <- c('all.drug.OD',
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
# as names for the vector short.curve.labels.
names(short.curve.labels) <- long.curve.labels

# The technical notes tab of the app includes a table giving the
# correspondence between plot labels and ICD-10 codes for cause of death.  In
# this context, it is helpful to have short, fixed names for the elements of
# long.curve.labels, so that we can hard code the process of taking a
# reordered subset of long.curve.labels.
names(long.curve.labels) <- short.curve.labels

###############################################################################
# Variables used in selectizeInput widgets

# Choice of statistic for showing drug-overdose deaths
statistic.labels <- c('death.count', 'normalized.death.count', 'percent.change')
names(statistic.labels) <- c('Number of deaths',
                             'Number of deaths per 100,000 population',
                             'Percent change during one year')

dataset.labels <- c('drug.od.data', 'population.data')
names(dataset.labels) <- c('Drug OD deaths', 'Annual state populations')

###############################################################################
# Variables involving state names and abbreviations

# The vector named.state.abbreviations is used for converting state names to
# state abbreviations.  State abbreviations are used in data frames, while
# full state names are shown in the user interface.
named.state.abbreviations <- setNames(state.abb, state.name)

# Vector used to achieve consistent row order in the display of data frames.
ordered.abbreviations <- append(c('US'), sort(state.abb))

# Vector used in the selectizeInput widget for selecting the US or a state.
# The full names will be displayed, with "United States" listed first and full
# state names listed alphabetically below.
state.labels <- c('US')
names(state.labels) <- c('United States')
state.labels <- append(state.labels, named.state.abbreviations)
