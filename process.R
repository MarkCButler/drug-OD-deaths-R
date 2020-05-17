library(dplyr)

# This file defines functions for processing the raw data to generate data
# frames containing the values to be plotted.
#
# In particular, the raw data gives the number of deaths during one year in
# each category, whereas the app gives the choice between three different
# statistics:  number of deaths, number of deaths per unit of population, or
# percent change from previous year.  The last two choices require additional
# processing.
#
# This file also define a function to determine the set of curves that can be
# plotted after the raw data has been processed.

# The unit used to normalize death count.
UNIT.POPULATION <- 1e5

# Bring the variables statistic.labels and curve.labels into the current
# namespace.
source('./global.R')

# Define the functions that interpolate annual population estimates in order to
# avoid spurious jumps in time-development plots.
source('./time_series.R')

# The app uses a slightly broader set of categories for drug-overdose deaths
# than the raw data, so it is necessary to add together some values from the
# raw data.  This is handled by get.labeled.data.
get.labeled.data <- function(data) {
    # Group by all columns except Value and take the sum of Value.
    data <- group_by_at(data, vars(-Value)) %>%
        summarise(Value = sum(Value)) %>%
        ungroup()
    return(data)
}

normalize.by.population <- function(data) {
    data['Population'] <- numeric(nrow(data))
    data <- mutate(data, Month.year = paste(Month, Year))

    # The function get.population defined in time_series.R accepts a vector of
    # dates but a single value for 'state' (which can be 'United States' or the
    # name of a state).  In the case of time-series data, there is only a single
    # value of 'state', so the interpolation can be done with a single call to
    # get.population.  For the map.data, however, it is necessary to do a loop
    # over the 51 values for state, each corresponding to a single row of the
    # data frame.
    #
    # For the general case, loop over the values of state in the data frame.
    states <- unique(data$State)
    for (state in states) {
        selector <- (data$State == state)
        dates <- convert.to.date(data[selector, 'Month.year'])
        populations <- get.population(state, dates)
        data[selector, 'Population'] <- populations
    }

    data <- mutate(data, Normalized.value = Value * UNIT.POPULATION / Population)

    return(select(data, -Population, -Month.year))
}

process.map.data <- function(data.selected.year, data.prior.year) {
    # Map data contains only a single label all.drug.OD, which corresponds to
    # a single value of Indicator in the raw data, so there is no need to call
    # get.labeled.data.

    # After this command is completed, we have the following column names:
    # State, Year, Month, Value, Normalized.value
    data <- normalize.by.population(data.selected.year)

    if (nrow(data.prior.year) > 0) {
        # Use a join to calculate percent change from the two data frames.  Note
        # that since the difference in the dates for data.selected.year and
        # data.prior.year is always 1 year, it is not strictly necessary to track the
        # year in connection with the join.  However, preserving the year
        # information makes it easier to check the data frame produced by the
        # join.
        data.prior.year <- rename(data.prior.year, Prior.year = Year, Prior.value = Value) %>%
            mutate(Year = Prior.year + 1)
        data <- inner_join(data, data.prior.year, by = c('State', 'Month', 'Year')) %>%
            mutate(Percent.change = (Value - Prior.value) / Prior.value * 100) %>%
            select(-Prior.year, -Prior.value)
    }

    return(data)
}

process.time.data <- function(data) {
    data <- get.labeled.data(data)
    return(data)
}

find.OD.categories <- function(data, statistic.label) {
    # Return random selection for testing reactive expressions in server.R.
    # Select 4 of the 7 labels.
    categories <- curve.labels[sample.int(length(curve.labels), size = 4)]
    return(categories)
}
