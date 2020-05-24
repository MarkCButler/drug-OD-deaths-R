# Static variables used only by the server are defined in this file.

source('./global.R')

# Define the data frame that gives the correspondence between curve labels
# and ICD-10 codes for cause of death.  Note that the vector
# long.curve.labels is defined in global.R.
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

# The population data frame is loaded in global.R and used in interpolate.R to
# define functions that interpolate annual population estimates.  In that
# context, it is convenient to have essentially a matrix of numbers for the
# columns of the data frame.
#
# The population data is also displayed in the Data tab of the user interface,
# along with the data on drug-overdose deaths.  For consistency in displaying
# the two data sets, add a column 'US / State' to the population data to be
# displayed.
population.data <- cbind(`US / State` = rownames(population), population)
