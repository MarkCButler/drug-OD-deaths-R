library(dplyr)
library(RSQLite)
library(stringr)

# The code in this file was run only once.  It does preprocessing to generate
# the sqlite database used by the app.

# Bring the variables db.name, table.name, and state.labels into the current
# namespace.
source('./global.R')

# The csv file imported here was not modified manually after it was downloaded
# from data.cdc.gov.  After the data frame is loaded, columns and rows needed
# for the app are extracted, a column of curve labels is added, state
# abbreviations are converted to full names, and the resulting dataframe is
# converted to a sqlite database.  (Since the sqlite database is only about 1
# MB, the choice of data stored in it is designed to simplify the processing
# that must be done in the app.)
deaths.csv <- './data/VSRR_Provisional_Drug_Overdose_Death_Counts.csv'
deaths.df <- read.csv(deaths.csv, stringsAsFactors = F)

# Extract the columns and rows needed for the app.  Also filter out rows that
# are missing the death count, in order to simplify later processing.
deaths.df <- select(deaths.df, State, Year, Month, Indicator, Data.Value) %>%
    rename(Value = Data.Value) %>%
    filter(
        str_detect(Indicator, 'T[:digit:]|Drug Overdose Deaths'),
        !str_detect(Indicator, 'incl\\. methadone'),
        !(State %in% c('DC', 'YC')),
        !is.na(Value)
    )

# Next add a label column to simplify data analysis.  This column will not be
# shown in the Data tab of the app, which displays only the raw data.
#
# In the following command, which creates a vector of labels based on  the
# Indicator column, the order of the cases is significant.  For instance, the
# indicator
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

# Convert state abbreviations (and also 'US') to full names.  Note that the
# vector state.labels is defined in global.R as
#
# state.labels <- append(c('United States'), state.name)
names(state.labels) <- append(c('US'), state.abb)
deaths.df <- mutate(deaths.df, State = state.labels[State])


# Order the rows in the default order desired for display in the app.  I haven't
# tested whether this actually makes any database operations more efficient.
#
# The second call to match  in the command below returns the month number
# corresponding to the month name, e.g. 1 for 'January'.  A similar call is used
# in displaying raw data in the app.
deaths.df <- arrange(deaths.df,
                     match(State, state.labels),
                     Year,
                     match(Month, month.name),
                     Indicator)

# Create sqlite database.
conn <- dbConnect(SQLite(), db.name)
dbWriteTable(conn = conn,
             name = table.name,
             value = deaths.df)
dbDisconnect(conn)
