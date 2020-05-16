library(dplyr)
library(DT)
library(shiny)
library(googleVis)

source('./database.R')
source('./time_series.R')
source('./process.R')


server <- function(input, output, session) {

    # Connect to the database.  The connection returned by
    # get.managed.connection will be closed when the session ends.
    conn <- get.managed.connection(session)

    ##########################################################################
    # Map tab

    # Reactive expression to fetch map data when it needs to be refreshed.  Note
    # that a change to input$period triggers all updates and data processing for
    # the map tab, including an attempt to calculate percent change from the
    # prior year if possible (i.e., if the year is not the first year for which
    # data is available).
    map.data <- eventReactive(input$period, {
        # Get map data for the selected month / year combination.
        month.year <- unlist(strsplit(input$period, ' '))
        month <- month.year[1]
        year <- month.year[2]
        data.selected.year <- get.map.data(conn, year, month)

        # If possible get data from the prior year.
        prior.year <- as.character(as.numeric(month.year[2]) - 1)
        if (dataset.start.date <= convert.to.date(paste(month, prior.year))) {
            data.prior.year <- get.map.data(conn, prior.year, month)
        } else {
            data.prior.year <- data.frame(fake.column = character(0))
        }

        # The function process.map.data just returns its first input in order
        # to allow testing of reactive expressions.
        data <- process.map.data(data.selected.year, data.prior.year)
        cat(file = stderr(), '\nUpdated map.data\n')
        cat(file = stderr(), 'nrow(map.data): ', nrow(data), '\n')
        cat(file = stderr(), 'head(map.data): ', toString(head(data)), '\n')

        data
    })

    # Update the choice of time periods based on the selection for
    # map.statistic.
    #
    # In particular, if the statistic selected is the percent change during
    # one year, we need to eliminate 2015 from the set of choices for the time
    # period.  The reason is that the raw data gives the number of deaths from
    # 2015 to 2019, which allows the percent change to be calculated for the
    # years 2016 to 2019.
    #
    # Note that the call to updateSelectizeInput uses the 'selected' parameter
    # to set the value of input$period, which is monitored by eventReactive in
    # the definition of map.data just above.  This raises a question:  if
    # the value of input$period set by updateSelectizeInput is the same as the
    # value before the call to updateSelectizeInput, does the code in
    #
    # eventReactive(input$period, ... )
    #
    # run in response?  Inserting calls to cat(file = stderr(), ... ) show that
    # the answer is no, so there is no loss of efficiency due to
    # updateSelectizeInput.
    observeEvent(input$map.statistic, {
        # Save the value of input$period so that we can preserve it if
        # possible after updating the set of choices for the time period.
        selected <- input$period

        if (input$map.statistic == 'percent.change') {
            # If the user had selected September 2015, switch to September
            # 2016.
            if (selected == time.periods[1]) {
                selected <- time.periods[2]
            }
            updateSelectizeInput(session, 'period', choices = time.periods[-1],
                                 selected = selected, server = F)
        } else {
            updateSelectizeInput(session, 'period', choices = time.periods,
                                 selected = selected, server = F)
        }
    })

    # Fake map output to trigger reactive expressions that fetch map data.
    output$map <- renderGvis({
        head(map.data())
        state_stat <- data.frame(state.name = rownames(state.x77), state.x77)
        choice <- colnames(state_stat)[-1]
        gvisGeoChart(state_stat, "state.name", choice[1],
                     options=list(region="US", displayMode="regions",
                                  resolution="provinces",
                                  width="auto", height="auto"))
    })

    ##########################################################################
    # Time-development tab

    # Reactive expression to fetch the time-development data.  All processing
    # needed for the data is done in response to a change in input$state.
    time.data <- eventReactive(input$state, {
        data <- get.time.data(conn, input$state)

        # The function process.map.data just returns its input in order
        # to allow testing of reactive expressions.
        data <- process.time.data(data)
        cat(file = stderr(), '\nUpdated time.data\n')
        cat(file = stderr(), 'nrow(time.data): ', nrow(data), '\n')
        cat(file = stderr(), 'head(time.data): ', toString(head(data)), '\n')

        data
    })

    # The available categories of drug-overdose deaths depend on the selected
    # state.  For instance, the only category available for CA in the raw data
    # is "Number of Drug Overdose Deaths."
    #
    # The available categories could also depend on the choice of statistic to
    # display.  For instance, if the time span for available state data
    # corresponding to a particular category is less than a year, a
    # time-series plot of "percent change from prior year" cannot be shown.
    #
    # The function find.OD.categories in process.R is used to find the
    # available categories from the processed data.
    #
    # Note that we want the set of categories to update in response to changes
    # in the (reactive) time.data and/or input$time.statistic.  However, the
    # code that is run in response includes the reactive value input$category.
    # In order to avoid executing the code to update the set of categories
    # unnecessarily, use observeEvent and define a reactive value
    # check.OD.categories.  In the definition of check.OD.categories below,
    # the argument to reactive() can be any set of statements that includes
    # the two input values that need to be monitored.
    check.OD.categories <- reactive({
        c(time.data(), input$time.statistic)
    })
    observeEvent(check.OD.categories(), {
        selected <- input$category
        categories <- find.OD.categories(time.data(), input$time.statistic)

        # Order the categories based on their position in the full list of
        # categories.
        categories <- categories[order(match(categories, short.curve.labels))]

        # The selected choices should be the intersection of the previously
        # selected choices and the available categories, with order
        # corresponding to the previously selected values.
        selected.update <- intersect(selected, categories)
        if (length(selected.update) == 0) {
            selected.update <- categories[1]
        } else {
            selected.update <- selected.update[order(match(selected.update, selected))]
        }

        updateSelectizeInput(session, 'category', choices = categories,
                             selected = selected.update, server = F)
    })

    # Fake plot output to trigger reactive expressions that fetch time data.
    output$time <- renderPlot({
        head(time.data())
        x <- seq(1, 10)
        plot(x)
    })

    ##########################################################################
    # Data tab

    # Define output object for the data tab.  For the display of the table,
    # reorder the rows to have data for the US first, with the month
    # names for a given year appearing in chronological order.
    drug.OD.data <- get.raw.data(conn) %>%
        arrange(match(State, state.labels),
                Year,
                match(Month, month.name),
                Indicator) %>%
        rename(`US / State` = State)

    # For consistency with drug.OD.data, add a column 'US / State' to the
    # population data to be displayed.
    population.data <- cbind(`US / State` = rownames(population), population)

    output$table <- DT::renderDataTable({
        if (input$dataset == 'drug.OD.data') {
            table <- datatable(drug.OD.data, rownames = F)
        } else if (input$dataset == 'population.data') {
            table <- datatable(population.data, rownames = F)
        }
        table
    })

    ##########################################################################
    # Technical Notes tab

    # Define the data frame that gives the correspondence between curve labels
    # and ICD-10 codes for cause of death.  Note that the vector
    # long.curve.labels is defined in global.R.
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

    # Render the static table for the technical notes.
    output$code.table <- renderTable({code.table})
}
