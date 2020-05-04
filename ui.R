library(shinydashboard)

############################
# Define header and sidebar
############################

header <- dashboardHeader(title = 'Drug OD Deaths')

sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem('Summary', tabName = 'summary', icon = icon('hand-point-right'), selected = T),
        menuItem('Map', tabName = 'map', icon = icon('map')),
        menuItem('Time development', tabName = 'time', icon = icon('chart-line')),
        menuItem('Data', tabName = 'data', icon = icon('database')),
        menuItem('Technical notes', tabName = 'notes', icon = icon('file-alt'))
    )
)


###############################################################
# Define the layout of the five tabItems in the dashboard body
###############################################################

data.source.deaths <- 'https://data.cdc.gov/NCHS/VSRR-Provisional-Drug-Overdose-Death-Counts/xkb8-kh2a'
data.source.pop <- 'https://www.census.gov/data/datasets/time-series/demo/popest/2010s-state-total.html'
source.code <- 'https://github.com/MarkCButler/drug-OD-deaths-app'
summary.tab <-  tabItem(
    tabName = 'summary',
    fluidRow(
        column(
            width = 12,
            h1('Drug overdose deaths in the US')
        ),
    ),
    fluidRow(
        column(
            width = 12,
            h2('Place holder for plots')
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
              a(href = data.source.pop, data.source.pop)),
            h4('Source code'),
            a(href = source.code, source.code)
        )
    )
)

map.tab <- tabItem(
    tabName = 'map',
    fluidRow(
        column(
            width = 12,
            h1('Number of drug overdose deaths')
        )
    ),
    fluidRow(
        column(
            width = 12,
            h2('Place holder: map of US colored by stastic')
        )
    ),
    fluidRow(
        column(
            width = 12,
            selectizeInput(inputId = 'map.category',
                           label = 'Select data category to display',
                           choices = c('Number of deaths',
                                       'Number of deaths per 100,000 population',
                                       'Percent change during one year'))
        )
    ),
    fluidRow(
        column(
            width = 12,
            selectizeInput(inputId = 'period',
                           label = 'Twelve-month period ending',
                           choices = NULL)
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

time.tab <- tabItem(
    tabName = 'time',
    fluidRow(
        column(
            width = 12,
            h1('Time development by category')
        ),
    ),
    fluidRow(
        column(
            width = 12,
            selectizeInput(inputId = 'drug',
                           label = 'Select one or more categories to display',
                           choices = NULL,
                           multiple = T)
        )
    ),
    fluidRow(
        column(
            width = 6,
            h2('Place holder: time-series curve(s) for US')
        ),
        column(
            width = 6,
            h2('Place holder: time-series curve(s) for selected state')
        )
    ),
    fluidRow(
        column(
            width = 6,
            offset = 6,
            selectizeInput(inputId = 'state',
                           label = 'State',
                           choices = NULL)
        )
    ),
    br(),
    fluidRow(
        column(
            width = 12,
            p('Technical note:  Because of gaps in reporting, time-series data for certain states ',
              'may be missing or incomplete.')
        )
    ),
)

data.tab <- tabItem(
    tabName = 'data',
    fluidRow(
        column(
            width = 12,
            selectizeInput(inputId = 'data.source',
                           label = 'Data source',
                           choices = c('Drug OD deaths', 'Annual state populations')),
        )
    ),
    fluidRow(
        column(
            width = 12,
            h2('Place holder for displayed table')
        )
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

notes.tab <- tabItem(
    tabName = 'notes',
    fluidRow(
        column(
            width = 12,
            h2('Data limitations')
        )
    ),
    fluidRow(
        column(
            width = 12,
            h2('Data processing')
        )
    )
)
#####################################################
# Define the dashboard body and create the dashboard
#####################################################

body <- dashboardBody(
    tabItems(
        summary.tab,
        map.tab,
        time.tab,
        data.tab,
        notes.tab
    )
)

dashboardPage(header, sidebar, body)
