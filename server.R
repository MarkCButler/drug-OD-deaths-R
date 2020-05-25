library(dplyr)
library(DT)
library(plotly)
library(shiny)

source('./database.R')
source('./plot.R')
source('./process.R')
source('./server_variables.R')

server <- function(input, output, session) {

    # Connect to the database.  The connection returned by
    # get.managed.connection will be closed when the session ends.
    conn <- get.managed.connection(session)

    ##########################################################################
    # Map tab

    # Reactive expression to fetch map data when it needs to be refreshed.
    # The function get.processed.map.data is defined in process.R.
    map.data <- eventReactive(input$period, {
        cat(file = stderr(), '\n\nUpdating map data\n')
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

    output$map <- renderPlotly({
        generate.map(map.data(), input$map.statistic)
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
    # The available categories also depend on the choice of statistic to
    # display.  For instance, when the time span for available state data
    # corresponding to a particular category is less than a year, a
    # time-series plot of "percent change from prior year" cannot be shown.
    #
    # The input widget that presents the user with a list of available
    # categories and selected categories therefore needs to be updated when the
    # time data changes as well as when the selected statistic changes.
    #
    # In order to avoid error/warning messages from the plotting commands, we
    # also need to guarantee that the categories being used for the plotting
    # commands are valid.  So we define a reactive vector of selected
    # categories.  This in turn depends on a reactive vector of available
    # categories.
    #
    # Another way to understand the need for these two reactive vectors is to
    # note that in updating the input widget that shows available categories, it
    # is necessary to find a vector of available catogies as well as a vector
    # corresponding to the subset that will remain selected when the widget is
    # updated.  By exposing these two vectors as reactive values, we can make
    # them available to plotting commands.  In this way, we avoid error/warning
    # messages that would otherwise appear when a plotting command tries to do
    # something impossible because its data frame has been updated but the
    # categories to plot are temporarily invalid until information has
    # propagated from an update to the user widget.

    available.categories <- reactive({
        # The function find.available.categories is defined in process.R.
        find.available.categories(time.data(), input$time.statistic)
    })

    selected.categories <- reactive({
        current.selection <- input$categories
        new.categories <- available.categories()

        # The selected choices should be the intersection of the previously
        # selected choices and the available categories, with order
        # corresponding to the previously selected values.
        updated.selection <- intersect(current.selection, new.categories)
        if (length(updated.selection) == 0) {
            updated.selection <- new.categories[1]
        } else {
            reordered.indices <- order(match(updated.selection, current.selection))
            updated.selection <- updated.selection[reordered.indices]
        }
        updated.selection
    })

    # Update the input widget that presents the user with a list of available
    # categories.  Since we do not want the widget updated each time the
    # categories selected by the user change (i.e., when input$categories
    # changes), we use observeEvent to update only when available.categories()
    # changes.
    observeEvent(available.categories(), {
        categories <- available.categories()
        updated.selection <- selected.categories()

        updateSelectizeInput(session, 'categories', choices = categories,
                             selected = updated.selection, server = F)
    })

    output$time.title <- renderText({
        index <- match(input$time.statistic, statistic.labels)
        title <- time.titles[index]
    })

    output$time.subtitle <- renderText({
        input$state
    })

    output$time.plot <- renderPlot({
        generate.time.plot(time.data(), input$time.statistic, selected.categories())
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

    # Render the static table for the technical notes.
    output$code.table <- renderTable({code.table})
}
