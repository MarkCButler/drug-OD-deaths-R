# The file defines functions for interpolating the annual population estimates
# obtained from www.census.gov.  The interpolation is needed in order to avoid
# spurious jumps in time-series plots.

###############################################################################
# Bring the variable population.csv and the function convert.to.Date into the
# current namespace.
source('./global.R')

###############################################################################
# Define data structures and helper functions needed for the function
# get.population that gets interpolated population estimates.

# The population.csv file loaded here was created by manually modifying the
# .xlsx file downloaded from www.census.gov.  The csv file contains population
# estimates for the US and each of the 50 states.  For each of the years 2014
# - 2019, there is an estimate of the population on July 1.
population <- read.csv(population.csv, row.names = 1, check.names = F)

# First lapply is used to define one function for each row of the population
# data frame.  Then a single function is defined to do the interpolation given
# a state abbreviation (or 'US') together with a vector Date objects.
#
# Note that this interpolation is needed primarily for time-series plots that
# show number of deaths per 100,000 population.  The interpolation avoids
# spurious jumps in such plots.
population.dates = convert.to.Date(
    paste('July', seq(from = 2014, to = 2019))
)
get.interp.function <- function(state) {
   approxfun(x = population.dates,
             y = as.numeric(population[state,]),
             method = 'linear',
             rule = 2)
}
interp.functions <- lapply(rownames(population), get.interp.function)
names(interp.functions) <- rownames(population)
get.population <- function(state, dates) {
    population.estimates <- interp.functions[[state]](dates)
    return(population.estimates)
}
