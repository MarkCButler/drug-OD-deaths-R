library(dplyr)
library(DT)
library(shiny)
library(googleVis)

source('./database.R')
source('./time_series.R')


# The vector long.curve.labels is defined in global.R.
code.labels <- long.curve.labels[c('all.opioids',
                                   'heroin',
                                   'prescription.opioids',
                                   'synthetic.opioids',
                                   'cocaine',
                                   'other.stimulants')]
codes <- c('T40.0-T40.4, T40.6',
           'T40.1',
           'T40.2',
           'T40.3, T40.4',
           'T40.5',
           '43.6')
code.table <- data.frame(label = code.labels, codes)


server <- function(input, output, session) {

    # Render the static table for technical notes.  Note that code.table is defined in
    # global.R.
    output$code.table <- renderTable({code.table})

    # Connect to the database.  Note that the connection will be closed
    # automatically when the session ends.
    conn <- get.managed.connection(session)

    # Define output object for the data tab.  For the display of the table,
    # reorder the rows to have data for the full US first, with the month
    # names for a given year appearing in chronological order.
    drug.od.data <- get.raw.data(conn) %>%
        arrange(match(State, ordered.abbreviations),
                Year,
                match(Month, month.name),
                Indicator) %>%
        rename(`US / State` = State)

    output$table <- DT::renderDataTable({
        if (input$dataset == 'drug.od.data') {
            table = datatable(drug.od.data, rownames = F)
        } else {
            table = datatable(population, rownames = T)
        }
        table
    })
}
