library(DT)
library(shiny)
library(googleVis)

source('./database.R')
source('./time_series.R')

# Table giving the correspondence between plot labels and ICD-10 codes for
# cause of death.  This table is included in the technical notes tab but is
# rendered by the server.
code.label <- c('All opioids',
                'Heroin',
                'Prescription opioids',
                'Fentanyl and synthetic opioids',
                'Cocaine',
                'Methamphetamine and other psychostimulants')
codes <- c('T40.0-T40.4, T40.6',
           'T40.1',
           'T40.2',
           'T40.3, T40.4',
           'T40.5',
           '43.6')
code.table <- data.frame(label = code.label, codes)

server <- function(input, output, session) {
    output$code.table = renderTable({code.table})
}
