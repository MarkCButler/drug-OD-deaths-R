library(dplyr)
library(DT)
library(shiny)
library(googleVis)

source('./database.R')
source('./process.R')

server <- function(input, output, session) {

    # Connect to the database.  The connection returned by
    # get.managed.connection will be closed when the session ends.
    conn <- get.managed.connection(session)

    ##########################################################################
    # Map tab

    # Reactive expression to fetch map data when it needs to be refreshed.
    # The function get.processed.map.data is defined in process.R.
    map.data <- eventReactive(input$period, {
        get.processed.map.data(conn, input$period)
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
        # Save the value of input$period so that we can preserve it after
        # updating the set of choices for the time period.  Note that because
        # both input widgets of the map tab are updated in response to user
        # selection, it should always be possible to preserve the selection.
        selected <- input$period

        if (input$map.statistic == statistic.labels[3]) {
            updateSelectizeInput(session, 'period', choices = time.periods[-1],
                                 selected = selected, server = F)
        } else {
            updateSelectizeInput(session, 'period', choices = time.periods,
                                 selected = selected, server = F)
        }
    })

    # Update the choice of statistic to display based on the selected time
    # period.
    observeEvent(input$period, {
        selected <- input$map.statistic

        # If the selected time period is the first choice in the list, the
        # option to display percent change from the previous year is removed.
        if (input$period == time.periods[1]) {
            updateSelectizeInput(session, 'map.statistic', choices = statistic.labels[-3],
                                 selected = selected, server = F)
        } else {
            updateSelectizeInput(session, 'map.statistic', choices = statistic.labels,
                                 selected = selected, server = F)
        }
    })

    output$map.title <- renderText({
        index <- match(input$map.statistic, statistic.labels)
        title <- map.titles[index]
        title
    })
    output$map.subtitle <- renderText({
        if (input$map.statistic == 'percent.change') {
            index <- match(input$period, time.periods)
            previous.period <- time.periods[index - 1]
            subtitle <- paste(previous.period, 'to', input$period)
        } else {
            subtitle <- paste('Twelve-month period ending',
                              input$period)
        }
        subtitle
    })

    output$map <- renderPlot({
        data <- map.data()

        if (input$map.statistic == 'normalized.death.count') {
            selected.column <- 'Normalized.value'
        } else if ((input$map.statistic == 'percent.change') && ('Percent.change' %in% colnames(data))) {
            selected.column <- 'Percent.change'
        } else {
            selected.column <- 'Value'
            if (input$map.statistic != 'death.count') {
                cat(file = stderr(),
                    '\nWARNING:  Unable to find a valid choice for the column to display ',
                    'on the map tab.\n')
            }
        }

        cat(file = stderr(), '\n\n\nPlotting map data\n')
        cat(file = stderr(), '\nnrow(data): ', nrow(data), '\n')
        cat(file = stderr(), '\ncolnames(data): ', colnames(data), '\n')
        cat(file = stderr(), '\ndata: ', toString(data), '\n')
        cat(file = stderr(), '\nselected.column: ', selected.column, '\n')
        cat(file = stderr(), '\ndata[, "State", drop = T]:  ', data[, 'State', drop = T])
        cat(file = stderr(), '\ndata[, selected.column, drop = T]:  ', data[, selected.column, drop = T])

        plot(data[, selected.column, drop = T])
    })

    ##########################################################################
    # Time-development tab

    # Reactive expression to fetch the data for the time-development tab.
    time.data <- eventReactive(input$state, {
        data <- get.time.data(conn, input$state)
        process.time.data(data)
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
        categories <- categories[order(match(categories, curve.labels))]

        # The selected choices should be the intersection of the previously
        # selected choices and the available categories, with order
        # corresponding to the previously selected values.
        selected.update <- intersect(selected, categories)
        if (length(selected.update) == 0) {
            selected.update <- categories[1]
        } else {
            selected.update <- selected.update[order(match(selected.update, selected))]
        }

        cat(file = stderr(), '\nNew categories:', toString(categories), '\n')
        updateSelectizeInput(session, 'category', choices = categories,
                             selected = selected.update, server = F)
    })

    output$time.title <- renderText({
        index <- match(input$time.statistic, statistic.labels)
        title <- time.titles[index]
    })
    output$time.subtitle <- renderText({
        input$state
    })

    output$time <- renderPlot({
        data <- time.data()

        cat(file = stderr(), '\n\n\nPlotting time data\n')
        cat(file = stderr(), '\nnrow(data): ', nrow(data), '\n')
        cat(file = stderr(), '\ncolnames(data): ', colnames(data), '\n')
        cat(file = stderr(), '\nhead(data): ', toString(data), '\n')
        plot(seq(1, 10))
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
