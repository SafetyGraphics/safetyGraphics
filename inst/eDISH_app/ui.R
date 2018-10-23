library(shiny)

navbarPage("eDISH Shiny app", id = "inTabset",
           tabPanel(title = "Data", value = "data",
                    fluidRow(
                      column(3,
                             wellPanel(
                               h3("Data upload"), 
                               fileInput("datafile", "Upload a csv or sas7bdat file",accept = c(".sas7bdat", ".csv"), multiple = TRUE),
                              # div(id = "placeholderDataSelect")
                              radioButtons("select_file","Select file for eDISH chart", choices = "No files available")
                             )
                      ),
                      column(6, 
                             fluidRow(
                               wellPanel( 
                               h3("Data preview"), 
                               div(DT::dataTableOutput("data_preview"), style = "font-size: 75%")
                             )
                             ),
                             fluidRow(
                               br(),
                               tags$style(type='text/css', '#detectStandard_msg {font-size:23px;}'),
                               uiOutput("detectStandard_msg"),
                               actionButton("view_chart","View Chart")
                             )
                      )
                    )
           ),
           #  dataUploadUI("dataupload")),
           tabPanel(title = "Settings", value = "settings",
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
           tabPanel(title = "Charts", value = "charts",
                    eDISHOutput("chart")
                    )
           )

