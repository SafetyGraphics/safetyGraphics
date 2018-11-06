library(shiny)

navbarPage("eDISH Shiny app", id = "inTabset",
           tabPanel(title = "Data", value = "data",
                    fluidRow(
                      column(3,
                             wellPanel(
                               h3("Data upload"), 
                               fileInput("datafile", "Upload a csv or sas7bdat file",accept = c(".sas7bdat", ".csv"), multiple = TRUE),
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
           tabPanel(title = "Settings", id = "settings",
                    fluidPage(
                      renderSettingsUI("settingsUI")
                    )
           ),
           tabPanel(title = "Charts", value = "charts",
                    eDISHOutput("chart")
                    )
           )

