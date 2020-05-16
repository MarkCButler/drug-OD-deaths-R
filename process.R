library(dplyr)

# This file defines functions for processing the raw data to generate data
# frames containing the values to be plotted.  It also defines a function to
# determine the set of curves that can be plotted after the raw data has been
# processed.

# Bring the variables statistic.labels and short.curve.labels. into the
# current namespace.
source('./global.R')


# The app uses a slightly broader set of categories for drug-overdose deaths
# than the raw data, so it is necessary to add together some values from the
# raw data.  This is handled by get.labeled.data.
get.labeled.data <- function(data) {
}

process.map.data <- function(data.selected.year, data.prior.year) {
    # Return first input for testing reactive inputs in server.R
    return(data.selected.year)
}

process.time.data <- function(data) {
    # Return input used for testing reactive inputs in server.R
    return(data)
}

find.OD.categories <- function(data, statistic.label) {
    # Return random selection for testing reactive expressions in server.R.
    # Select 4 of the 7 labels.
    categories <- short.curve.labels[sample.int(length(short.curve.labels), size = 4)]
    return(categories)
}
