library(dplyr)
library(RSQLite)
library(stringr)

###############################################################################
# Bring the variables population.csv, db.name, and table.name into the current
# namespace.
source('./global.R')

# The code in this file was run only once.  It does preprocessing to generate
# a csv file and a sqlite database used by the app.

###############################################################################
# The population.csv file loaded here was created by manually modifying the
# .xlsx file downloaded from www.census.gov.  The preprocessing done here
# converts state names to state abbreviations.  This is fairly trivial
# preprocessing, but there's no reason to have it repeated each time the app
# runs, while the user is waiting for the app to start.

population <- read.csv(population.csv, row.names = 1)

# Replace the row names with abbreviations without assuming a particular order
# for the row names.  The first row name is excluded because it is 'US'.
state.row.names <- rownames(population)[-1]
named.state.abb <- setNames(state.abb, state.name)
rownames(population)[-1] <- named.state.abb[state.row.names]
write.csv(population, population.csv)

###############################################################################
# The csv file with information on drug overdose deaths was not modified
# manually after it was downloaded from data.cdc.gov.  After it is read, columns
# and rows needed for the app are extracted, a column of curve labels is added,
# and the resulting dataframe is converted to a sqlite database.

deaths.csv <- './data/VSRR_Provisional_Drug_Overdose_Death_Counts.csv'
deaths.df <- read.csv(deaths.csv, stringsAsFactors = F)

# Extract the columns and rows needed for the app.  Also filter out rows that
# are missing the death count, since this simplifies later processing.
deaths.df <- select(deaths.df, State, Year, Month, Indicator, Data.Value) %>%
    rename(Value = Data.Value) %>%
    filter(
        str_detect(Indicator, 'T[:digit:]|Drug Overdose Deaths'),
        !str_detect(Indicator, 'incl\\. methadone'),
        !(State %in% c('DC', 'YC')),
        !is.na(Value)
    )
paste()
# Next add a label column to simplify data analysis.  This column will not be
# shown in the Data tab of the app, which displays only the raw data.

# In the following command, which creates a vector of labels based on  the
# Indicator column, the order of the case statements is significant.  For
# instance, the indicator
#
# 'Opioids (T40.0-T40.4,T40.6)'
#
# is detected early in the series of cases by checking for the substring
# 'T40.0', and after this check, simple substrings such as 'T40.4' uniquely
# identify the remaining indicators.
#
# The labels are elements of the vector short.curve.labels defined in global.R.
label <- case_when(
    str_detect(deaths.df$Indicator, 'T40.0') ~ 'all.opioids',
    str_detect(deaths.df$Indicator, 'T40.1') ~ 'heroin',
    str_detect(deaths.df$Indicator, 'T40.2') ~ 'prescription.opioids',
    str_detect(deaths.df$Indicator, 'T40.[34]') ~ 'synthetic.opioids',
    str_detect(deaths.df$Indicator, 'T40.5') ~ 'cocaine',
    str_detect(deaths.df$Indicator, 'T43') ~ 'other.stimulants',
    str_detect(deaths.df$Indicator, 'Drug Overdose') ~ 'all.drug.OD'
)

deaths.df <- mutate(deaths.df, Label = label)

# Order the rows, for convenience in checking deaths.df.  The call to match
# returns the month number corresponding to the month name, e.g. 1 for
# 'January'.  A similar call is used in displaying raw data in the app.
deaths.df <- arrange(deaths.df, State, Year, match(Month, month.name), Indicator)

###############################################################################
# Create sqlite database.

conn <- dbConnect(SQLite(), db.name)
dbWriteTable(conn = conn,
             name = table.name,
             value = deaths.df)
dbDisconnect(conn)
