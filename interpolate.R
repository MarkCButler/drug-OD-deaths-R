# Annual population estimates for each state are available from
# www.census.gov, and this file defines functions for interpolating these
# annual estimates.  The interpolation is needed in order to avoid spurious
# jumps in time-series plots that show number of deaths per unit population.

# Bring the population data frame and the function convert.to.date into the
# current namespace.
source('./global.R')

# Define a vector of dates for which population estimates are available.
population.dates <- convert.to.date(
    paste('July', seq(from = 2014, to = 2019))
)

# Use lapply to create a list of helper functions, one for each row of the
# population data frame.  Then define a single function to do the
# interpolation given a state name (or 'United States') together with a vector
# of Date objects.

get.interp.function <- function(state) {
   approxfun(x = population.dates,
             y = as.numeric(population[state, ]),
             method = 'linear',
             rule = 2)
}

interp.functions <- lapply(rownames(population), get.interp.function)

names(interp.functions) <- rownames(population)

get.population <- function(state, dates) {
    population.estimates <- interp.functions[[state]](dates)
    return(population.estimates)
}
