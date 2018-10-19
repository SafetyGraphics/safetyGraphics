library(shiny)

navbarPage("eDISH Shiny app",
           tabPanel("Data",
                    fluidRow(column(3, offset = 1, 
                                    fileInput("datafile", "Upload a data set",accept = c(".sas7bdat", ".csv"), multiple = TRUE)),
                             column(3, div(id = "placeholderDataSelect")))
           ),
           #  dataUploadUI("dataupload")),
           tabPanel("Settings",
                    fluidPage(
                      wellPanel(
                        fluidRow(
                          column(3, 
                                 h3("Data Standard"),
                                 selectInput("standard","Data Standard", choices = c("ADaM","SDTM","Other"), selected = "ADaM"),
                                 # temporarily (?) trigger settings generation 
                                 actionButton("generateSettings","Generate settings")
                          )
                        )
                      ),
                      renderSettingsUI("settingsUI")
                      )
                    ),
           tabPanel("Charts"))

