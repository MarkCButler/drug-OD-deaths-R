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

time.periods = paste('September', seq(from = 2015, to = 2019))
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
            selectizeInput(inputId = 'map.type',
                           label = 'Select type of data to display',
                           choices = statistic.labels)
        )
    ),
    fluidRow(
        column(
            width = 12,
            selectizeInput(inputId = 'period',
                           label = 'Twelve-month period ending',
                           choices = time.periods,
                           selected = time.periods[length(time.periods)] )
        )
    ),
    br(),
    fluidRow(
        column(
            width = 12,
            p('Because of variations in reporting by different states, ',
              'death rates involving specific drug categories are not compared between states.',
              'The only comparison made between states is the total number of drug-overdose deaths.')
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
            selectizeInput(inputId = 'time.type',
                           label = 'Select type of data to display',
                           choices = statistic.labels)
        )
    ),
    fluidRow(
        column(
            width = 12,
            selectizeInput(inputId = 'drug',
                           label = 'Select one or more curves to display',
                           choices = short.curve.labels,
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
                           choices = state.name,
                           selected = 'Texas')
        )
    ),
    br(),
    fluidRow(
        column(
            width = 12,
            p('Due to low data quality, the death count ',
              'was not reported for certain combinations of month, year, state, and drug category.  ',
              'In plots showing time-development, the data values that gave rise to the plot are ',
              'therefore shown as dots.')
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
            h1('Technical notes')
        ),
    ),
    fluidRow(
        column(
            width = 12,
            h4('Data for drug-overdose deaths')
        )
    ),
    fluidRow(
        column(
            width = 10,
            tags$ul(
                tags$li(HTML(
                    'The death counts are provisional values given by ',
                    'the Vital Statistics Rapid Release program of the US government.'
                )),
                tags$li(HTML(
                    'Provisional counts of drug-overdose deaths are reported with a lag time ',
                    'of six months following the date of death.'
                )),
                tags$li(HTML(
                    'The death count listed for a given month represents the number of deaths ',
                    'occuring during the preceding 12-month period.  As a result, the death count ',
                    'does not show seasonal variation.'
                )),
                tags$li(HTML(
                    'Due to low data quality, the death count ',
                    'was not reported for certain combinations of month, year, state, and drug category.  ',
                    'In plots showing time-development, the data values that gave rise to the plot are ',
                    'therefore shown as dots.'
                )),
                tags$li(HTML(
                    'Because of variations in reporting by different states, death rates involving ',
                    'specific drug categories are not compared between states.  The only comparison made ',
                    'between states is the total number of drug-overdose deaths.'
                )),
                tags$li(
                    HTML(
                        'The data includes cause-of-death codes from ICD–10, ',
                        'the Tenth Revision of the International Statistical Classification of Diseases ',
                        'and Related Health Problems.  The correspondence between plot labels and ',
                        'ICD-10 codes is as follows:'
                    ),
                    tableOutput('code.table')
                ),
                tags$li(
                    'Additional information regarding the data for drug-overdose deaths is available at ',
                    a(href = data.source.deaths, data.source.deaths)
                )
            )
        )
    ),
    fluidRow(
        column(
            width = 12,
            h4('Population data')
        )
    ),
    fluidRow(
        column(
            width = 10,
            tags$ul(
                tags$li(HTML(
                    'Annual population estimates (dated July 1) are given by the ',
                    'US Census Bureau.'
                )),
                tags$li(HTML(
                    'For plots showing number of deaths per 100,000 population, linear interpolation ',
                    'is used to obtain population estimates that do not have an abrupt change in July.'
                )),
                tags$li(
                    'Additional information regarding the annual population estimates is available at ',
                    a(href = data.source.pop, data.source.pop)
                ),
            )
        )
    ),
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
