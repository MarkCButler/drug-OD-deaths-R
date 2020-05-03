library(shinydashboard)

####################################################################################################
# Layout of dashboardHeader, dashboardSidebar, and dashboardBody defined separately for readability.
####################################################################################################

header <- dashboardHeader(title = 'Drug OD Deaths')

sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem('Summary', tabName = 'summary', icon = icon('hand-point-right'), selected = T),
        menuItem('Map', tabName = 'map', icon = icon('map')),
        menuItem('Time series', tabName = 'series', icon = icon('chart-line')),
        #selectizeInput(inputId = 'cause', label = 'Cause / grouping', choice = NULL),
        #selectizeInput(inputId = 'region', label = 'State / region', choices = NULL),
        menuItem('Data', tabName = 'data', icon = icon('database')),
        menuItem('Technical Notes', tabName = 'notes', icon = icon('file-alt'))
    )
)


############################################################
# Layout of each tabItem defined separately for readability.
############################################################

data.source.deaths = 'https://data.cdc.gov/NCHS/VSRR-Provisional-Drug-Overdose-Death-Counts/xkb8-kh2a'
data.source.pop = 'https://www.census.gov/data/datasets/time-series/demo/popest/2010s-state-total.html'
summary.tab =  tabItem(
    tabName = 'summary',
    fluidRow(
        column(
            width = 12,
            h1('Drug overdose deaths in the US')
        ),
    ),
    br(),
    fluidRow(
        column(
            width = 12,
            h4('Data sources'),
            p('Drug OD deaths: ',
              a(href = data.source.deaths, data.source.deaths)),
            p('Annual state populations:  ',
              a(href = data.source.pop, data.source.pop))
        )
    )
)

map.tab = tabItem(
    tabName = 'map',
    fluidRow(
        column(
            width = 12,
            h1('Number of Drug OD deaths')
        )
    ),
    fluidRow(
        column(
            width = 12,
            selectizeInput(inputId = 'region',
                           label = 'Twelve-month period ending',
                           choices = NULL)
        )
    ),
    fluidRow(
        column(
            width = 12,
            h2('Place holder: map of US colored by number of drug OD deaths')
        )
    ),
    br(),
    fluidRow(
        column(
            width = 12,
            p('Technical note:  Because of variations in reporting by different states, ',
              'death rates involving specific drugs are not compared between states .')
        )
    ),
)

series.tab = tabItem(
    tabName = 'series',
    fluidRow(
        column(
            width = 12,
            # Want to be able to include causes of death in plot.  The causes of deaths
            # will be shown for both the US and the selected state.
            # The heading can be "Drug" and one of the choices can be "all drug OD deaths"
            # That one should be first.
            # The plot on the left will be for the US, while the plot on the right
            # will be for a particular state.
            selectizeInput(inputId = 'region',
                           label = 'Twelve-month period ending',
                           choices = NULL)
        )
    ),
    br(),
    fluidRow(
        column(
            width = 12,
            p('Technical note:  Because of gaps in reporting, time series data for certain states ',
              'may be missing or incomplete.')
        )
    ),
)

body <- dashboardBody(
    tabItems(
        summary.tab,
        map.tab,
        series.tab,
        tabItem(tabName = 'data', 'blank'),
        tabItem(tabName = 'notes', 'blank')
    )
)

dashboardPage(header, sidebar, body)
