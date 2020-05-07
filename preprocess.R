library(RSQLite)

# The population.csv file loaded here was created by manually modifying the
# .xlsx file downloaded from www.census.gov.  The preprocessing done here
# converts state names to state abbreviations.  This is fairly trivial
# preprocessing, but there's no reason to have it repeated each time the app
# runs, while the user is waiting for the app to start.
population.csv <- './data/population.csv'
population <- read.csv(population.csv, row.names = 1)

# Replace the row names with abbreviations without assuming a particular order
# for the row names.  The first row name is excluded because it is 'US'.
state.row.names <- rownames(population)[-1]
named.state.abb <- setNames(state.abb, state.name)
rownames(population)[-1] <- named.state.abb[state.row.names]
write.csv(population, population.csv)

# The csv file with information on drug overdose deaths was not modified
# manually after it was downloaded from data.cdc.gov.
deaths.csv <- './data/VSRR_Provisional_Drug_Overdose_Death_Counts.csv'
db.name <- './data/od_deaths.sqlite'
df.name <- 'od_deaths'
