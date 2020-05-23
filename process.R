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

# Bring the the function get.column.name into the current namespace.
source('./global.R')

# Define functions for fetching data.
source('./database.R')

# Define the functions that interpolate annual population estimates in order to
# avoid spurious jumps in time-development plots.
source('./time_series.R')

# The unit used to normalize death count.
unit.population <- 1e5

normalize.by.population <- function(data) {
    data['Population'] <- numeric(nrow(data))
    data <- mutate(data, Month.year = paste(Month, Year))

    # The function get.population defined in time_series.R accepts a vector of
    # dates but a single value for 'state' (which can be 'United States' or the
    # name of a state).  In the case of time-series data, there is only a single
    # value of 'state' in the data frame, so the interpolation can be done
    # with a single call to get.population.  For the map.data, however, it is
    # necessary to do a loop over the 51 values for state, each corresponding
    # to a single row of the data frame.
    #
    # For the general case, loop over the values of state in the data frame.
    states <- unique(data$State)
    for (state in states) {
        selector <- (data$State == state)
        dates <- convert.to.date(data[selector, 'Month.year', drop = T])
        populations <- get.population(state, dates)
        data[selector, 'Population'] <- populations
    }

    data <- mutate(data, Normalized.value = Value * unit.population / Population)

    return(select(data, -Population, -Month.year))
}

# The function that processes the map data also fetches the data from the
# database.  Separating the tasks of fetching and processing the map data
# would complicate the code unnecessarily, since the number of data frames
# fetched from the database depends on the time period selected by the user.
#
# The input to get.processed.map.data is a string of the form 'September 2019'
# obtained from a widget on the map tab.  The string represents the 12-month
# period ending at a given month and year.
get.processed.map.data <- function(conn, month.year) {

    # Fetch and process map data for the selected month / year combination.  The
    # call to normalize.by.population adds a column Normalized.value giving the
    # number of deaths per unit population, For the map data (which is seen when
    # the user scans over the map with the mouse), we round this new column.
    month.year.split <- unlist(strsplit(month.year, ' '))
    month <- month.year.split[1]
    year <- month.year.split[2]
    data <- get.map.data(conn, year, month) %>%
        normalize.by.population() %>%
        mutate(Normalized.value = round(Normalized.value, 1))

    # If possible get data from the prior year.
    prior.year <- as.character(as.numeric(year) - 1)
    if (dataset.start.date <= convert.to.date(paste(month, prior.year))) {
        data.prior.year <- get.map.data(conn, prior.year, month)

        # Use a join to calculate percent change from the two data frames.  Note
        # that since the difference in the dates for data.selected.year and
        # data.prior.year is always 1 year, and it is not strictly necessary to
        # track the month or year in connection with the join.  However, I find
        # this form of the join (which is similar to the form used for the time
        # data) conceptually clear.
        data.prior.year <- rename(data.prior.year, Prior.year = Year, Prior.value = Value) %>%
            mutate(Year = Prior.year + 1)
        data <- inner_join(data, data.prior.year, by = c('State', 'Month', 'Year')) %>%
            mutate(Percent.change = round((Value - Prior.value) / Prior.value * 100, 1)) %>%
            select(-Prior.year, -Prior.value)
    }

    return(data)
}

# The app uses a slightly broader set of categories for drug-overdose deaths
# than the raw data, so it is necessary to add together some values from the
# raw data.  This is handled by the function get.labeled.data defined here.
#
# Note that this processing is not needed for the map data, since this data only
# includes the category 'all drug-overdose deaths', which is a category in the
# raw data.
get.labeled.data <- function(data) {
    data <- group_by_at(data, vars(-Value)) %>%
        summarise(Value = sum(Value)) %>%
        ungroup()
    return(data)
}

find.available.categories <- function(data, statistic.label) {
    column.name <- get.column.name(data, statistic.label)

    filtered.labels <- select(data, Year, Month, Label, one_of(column.name)) %>%
        na.omit() %>%
        group_by(Label) %>%
        summarise(count = n()) %>%
        filter(count >= 2)

    available.categories <- filtered.labels[, 'Label', drop = T]

    # The categories that can be plotted will appear in a widget in the user
    # interface.  The actual choices shown in the widget will be the element
    # names rather than the elements of the vector.  In order to have
    # descriptive choice labels rather than the shorter labels used in the
    # database, we need to replace the elements in available.categories with
    # corresponding named elements from the global variable curve.labels.
    category.indices <- sort(match(available.categories, curve.labels))

    return(curve.labels[category.indices])
}

process.time.data <- function(data) {
    data <- get.labeled.data(data)  %>%
        normalize.by.population()

    # In order to find the percent change, do a self join.  In the code, create a
    # modified copy of data before doing the join.
    data.prior.year <- rename(data, Prior.year = Year, Prior.value = Value) %>%
        mutate(Year = Prior.year + 1) %>%
        select(-Normalized.value)
    data <- left_join(data, data.prior.year, by = c('State', 'Month', 'Year', 'Label')) %>%
        mutate(Percent.change = (Value - Prior.value) / Prior.value * 100) %>%
        select(-Prior.year, -Prior.value)

    return(data)
}
