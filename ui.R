library(plotly)
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

# The shinydashboard packaged used to organize this ui has a function box()
# that can put a nicer border around a figure or a map.  However, including a
# box can produce a distorted display, e.g., because of a time lag between
# resizing the box and resizing the boxed object.  As a result, figures and
# maps are set off from the edges of the viewing window using the column()
# function rather than the box() function.

data.source.deaths <- 'https://data.cdc.gov/NCHS/VSRR-Provisional-Drug-Overdose-Death-Counts/xkb8-kh2a'
data.source.pop <- 'https://www.census.gov/data/datasets/time-series/demo/popest/2010s-state-total.html'
source.code <- 'https://github.com/MarkCButler/drug-OD-deaths-R'
summary.tab <-  tabItem(
    tabName = 'summary',
    fluidRow(
        column(
            width = 12,
            h1('The Opioid Epidemic')
        ),
    ),
    fluidRow(
        column(
            width = 10,
            h4('The death rate in the US due to opioid overdose increased by almost a factor of six ',
               'between 1997 and 2017 [1].  Even though the overall number of drug-overdose deaths ',
               'has stabilized, the number of deaths due to synthetic opioids such as fentanyl ',
               'is still climbing.  (See the first plot below.)  There are signs of progress, ',
               'however.  In the second plot below, the downward slopes on the right side of the plot ',
               'show deceleration in growth of the death rate.  The map at the bottom of the ',
               'page shows the disturbing regional concentration in the per capita death rate ',
               'in 2017, when the overall number of drug-overdose deaths peaked.'
               ),
            p('[1] Sarah DeWeerdt, "Tracing the US opioid crisis to its roots", Nature 573, ',
              'S10-S12 (2019)')
        )
    ),
    fluidRow(
        column(
            width = 8,
            h3('Drug-overdose deaths in the US'),
            h4('Each data point represents the number of deaths during the preceding 12-month period.')
        )
    ),
    fluidRow(
        column(
            width = 10,
            plotOutput('opioid.epidemic'),
        )
    ),
    br(),
    fluidRow(
        column(
            width = 8,
            h3('Growth rate of the epidemic'),
        )
    ),
    fluidRow(
        column(
            width = 10,
            plotOutput('growth.rate'),
        )
    ),
    fluidRow(
        column(
            width = 10,
            h3('Regional distribution in 2017'),
            h4('Number of drug-overdose deaths per 100,000 people')
        )
    ),
    fluidRow(
        column(
            width = 10,
            plotlyOutput('distribution'),
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
            h1('Drug-Overdose Deaths in the US')
        )
    ),
    fluidRow(
        column(
            width = 8,
            h3(textOutput('map.title')),
            h4(textOutput('map.subtitle'))
        )
    ),
    fluidRow(
        column(
            width = 10,
            plotlyOutput('map'),
        )
    ),
    br(),
    fluidRow(
        column(
            width = 4,
            selectizeInput(inputId = 'map.statistic',
                           label = 'Select the statistic to display',
                           choices = statistic.labels,
                           selected = statistic.labels[1])
        ),
        column(
            width = 4,
            selectizeInput(inputId = 'period',
                           label = 'Select the twelve-month period ending',
                           choices = time.periods,
                           selected = time.periods[length(time.periods)])
        )
    ),
    fluidRow(
        column(
            width = 12,
            p('Because of variations in reporting by different states, ',
              'death rates involving specific drug categories are not compared between states.',
              'The only comparison made between states is the total number of drug-overdose deaths.')
        )
    )
)

time.tab <- tabItem(
    tabName = 'time',
    fluidRow(
        column(
            width = 12,
            h1('Time Development by Category')
        ),
    ),
    fluidRow(
        column(
            width = 8,
            h3(textOutput('time.title')),
            h4(textOutput('time.subtitle'))
        )
    ),
    fluidRow(
        column(
            width = 10,
            plotOutput('time.plot'),
        )
    ),
    br(),
    fluidRow(
        column(
            width = 4,
            selectizeInput(inputId = 'state',
                           label = 'Select the US or a state',
                           choices = state.labels,
                           selected = state.labels[1])
        ),
        column(
            width = 4,
            selectizeInput(inputId = 'time.statistic',
                           label = 'Select the statistic to display',
                           choices = statistic.labels,
                           selected = statistic.labels[1])
        ),
        column(
            width = 4,
            selectizeInput(inputId = 'categories',
                           label = 'Select one or more categories to display',
                           choices = curve.labels,
                           multiple = T,
                           selected = curve.labels[1])
        )
    ),
    fluidRow(
        column(
            width = 12,
            p('The death count was not reported for certain combinations of state, year, ',
              'month, and category.  As a result, some plots of time development are truncated, ',
              'and the available categories of drug-overdose deaths vary by state.')
        )
    ),
)

data.tab <- tabItem(
    tabName = 'data',
    fluidRow(
        column(
            width = 12,
            selectizeInput(inputId = 'dataset',
                           label = 'Data source',
                           choices = dataset.labels,
                           selected = dataset.labels[1]),
        )
    ),
    fluidRow(
        box(width = 12,
            DT::dataTableOutput('table'))
        ),
    br(),
    fluidRow(
        column(
            width = 12,
            h4('Data sources'),
            p('Drug OD deaths: ',
              a(href = data.source.deaths, data.source.deaths)),
            p('Annual populations:  ',
              a(href = data.source.pop, data.source.pop))
        )
    )
)

notes.tab <- tabItem(
    tabName = 'notes',
    fluidRow(
        column(
            width = 12,
            h1('Technical Notes')
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
                tags$li(
                    'The death counts are provisional values given by ',
                    'the Vital Statistics Rapid Release program of the US government.'
                ),
                tags$li(
                    'Provisional counts of drug-overdose deaths are reported with a lag time ',
                    'of six months following the date of death.'
                ),
                tags$li(
                    'The death count listed for a given month represents the number of deaths ',
                    'occuring during the preceding 12-month period.  As a result, the death count ',
                    'does not show seasonal variation.'
                ),
                tags$li(
                    'Due to low data quality, the death count ',
                    'was not reported for certain combinations of month, year, state, and drug category.  '
                ),
                tags$li(
                    'Because of variations in reporting by different states, death rates involving ',
                    'specific drug categories are not compared between states.  The only comparison made ',
                    'between states is the total number of drug-overdose deaths.'
                ),
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
                    'Additional information regarding the data on drug-overdose deaths is available at ',
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
                tags$li(
                    'Annual population estimates (dated July 1) are given by the ',
                    'US Census Bureau.'
                ),
                tags$li(
                    'For plots showing number of deaths per 100,000 population, linear interpolation ',
                    'is used to obtain population estimates that do not have an abrupt change in July.'
                ),
                tags$li(
                    'Additional information regarding the annual population estimates is available at ',
                    a(href = data.source.pop, data.source.pop)
                )
            )
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
