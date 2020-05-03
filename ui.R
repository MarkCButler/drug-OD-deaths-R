library(shinydashboard)

header <- dashboardHeader(title = 'Drug Overdose Deaths')

sidebar <- dashboardSidebar()

body <- dashboardBody()

dashboardPage(header, sidebar, body)