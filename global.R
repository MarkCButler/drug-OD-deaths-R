# The name of the csv file containing annual population estimates.
population.csv <- './data/population.csv'

# The name of the database and table containing death counts due to drug
# overdose.
db.name <- './data/deaths.sqlite'
table.name <- 'deaths'

# Labels for plotted curves.  The short curve labels are for storing in the
# data base, as well as for referring to curves in the code.  The long curve
# labels are displayed in the interface and in the plots--these may change as
# the plots are tweaked.
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
