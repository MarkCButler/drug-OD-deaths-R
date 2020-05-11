library(DT)
library(shiny)
library(googleVis)

source('./database.R')
source('./time_series.R')


server <- function(input, output, session) {

    # Render the static table for technical notes.  Note that code.table is defined in
    # global.R.
    output$code.table = renderTable({code.table})

    # Connect to the database.  Note that the connection that will be
    # closed automatically when the session ends.
    conn <- get.managed.connection(session)

}
