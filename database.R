library(RSQLite)

# This file defines functions for accessing the app's sqlite database.

###############################################################################
# Bring the variables db.name and table.name into the current namespace.
source('./global.R')

###############################################################################
# Define a function that returns a database connection that will be closed
# when the session ends.
get.managed.connection <- function(session) {
    conn <- dbConnect(SQLite(), db.name)
    session$onSessionEnded(function() {
        dbDisconnect(conn)
    })
    return(conn)
}

###############################################################################
# Define functions that perform database queries for different tabs and
# plots.  It is not necessary to sanitize input for database queries in this
# app, since the parameters input to queries are supplied by app functions
# rather than by users.  However, the functions defined below still follow
# best practice for database queries, including sanitizing input.

get.raw.data <- function(conn) {
    query <- paste('SELECT State, Year, Month, Indicator, Value',
                  'FROM', table.name)
    return(dbGetQuery(conn, query))
}

# Helper function called after a parameterized query has been defined.
execute.parameterized.query <- function(conn, query, query.parameters) {
    submitted.query <- dbSendQuery(conn, query)
    dbBind(submitted.query, query.parameters)
    result <- dbFetch(submitted.query)
    dbClearResult(submitted.query)
    return(result)
}

get.map.data <- function(conn, year, month) {
    query <- paste('SELECT State, Year, Month, Value',
                  'FROM', table.name,
                  'WHERE Year = :year AND Month = :month AND Label = :label')
    query.parameters <- list(year = year, month = month, label = 'all.drug.OD')
    result <- execute.parameterized.query(conn, query, query.parameters)
    return(result)
}

get.time.data <- function(conn, state) {
    query <- paste('SELECT State, Year, Month, Label, Value',
                  'FROM', table.name,
                  'WHERE State = :state')
    query.parameters <- list(state = state)
    result <- execute.parameterized.query(conn, query, query.parameters)
    return(result)
}
