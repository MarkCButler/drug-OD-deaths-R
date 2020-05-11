###############################################################################
# Data sources

# The name of the csv file containing annual population estimates.
population.csv <- './data/population.csv'

# The name of the database and table containing death counts due to drug
# overdose.
db.name <- './data/deaths.sqlite'
table.name <- 'deaths'

###############################################################################
# Choice of statistic for showing drug-overdose deaths
statistic.labels = c('Number of deaths',
                     'Number of deaths per 100,000 population',
                     'Percent change during one year')

###############################################################################
# Variables related to the labels for plotted curves

# The short curve labels are stored in the database for convenience.  In a few
# places short curve labels are hard-coded in a few places (e.g., in the
# definition of code.labels below), and so they should not be change.
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
# correspondence between plot labels and ICD-10 codes for cause of death.
# Since one column of this table is a reordered subset of the variable
# long.curve.labels defined above, the table is also defined here.  In this
# context, it is helpful to have short, fixed names for the elements of
# long.curve.labels, so that we can hard code the process of taking a
# reordered subset of long.curve.labels.
names(long.curve.labels) <- short.curve.labels
code.labels <- long.curve.labels[c('all.opioids',
                                   'heroin',
                                   'prescription.opioids',
                                   'synthetic.opioids',
                                   'cocaine',
                                   'other.stimulants')]
codes <- c('T40.0-T40.4, T40.6',
           'T40.1',
           'T40.2',
           'T40.3, T40.4',
           'T40.5',
           '43.6')
code.table <- data.frame(label = code.labels, codes)
