###############################################################################
# Bring the variables population.csv into the current namespace.
source('./global.R')

###############################################################################
# In the data on deaths by drug OD, dates are given in the format 'January 2015'.
# Define a function for converting this format to a Date object.

convert.to.Date <- function(month.year) {
    date.object <-  as.Date(paste('01', month.year),
                           format = '%d %B %Y')
    return(date.object)
}

###############################################################################
# Define a function for finding interpolated populations.

# The population.csv file was created by first manually modifying the .xlsx file
# downloaded from www.census.gov to create a csv file and then doing
# preprocessing with the script preprocess.R written for this app.  The csv file
# contains population estimates for the US and each of the 50 states.  For each
# of the years 2014 - 2019, there is an estimate of the population on July 1.
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
