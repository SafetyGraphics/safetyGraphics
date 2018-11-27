library(shiny)
library(shinyjs)

navbarPage("eDISH Shiny app", id = "inTabset",
           tabPanel(title = "Data", value = "data",
                    fluidRow(
                      column(3,
                             wellPanel(
                               h3("Data upload"), 
                               fileInput("datafile", "Upload a csv or sas7bdat file",accept = c(".sas7bdat", ".csv"), multiple = TRUE),
                              radioButtons("select_file","Select file for eDISH chart", 
                                           choiceNames = list(HTML("<p>Example data - <em style='color:green; font-size:12px;'>AdAm</em></p>")), 
                                           choiceValues = "Example data") 
                             )
                      ),
                      column(6, 
                             fluidRow(
                               wellPanel( 
                               uiOutput("datapreview_header"),
                               div(DT::dataTableOutput("data_preview"), style = "font-size: 75%")
                             )
                             ),
                             fluidRow(
                               br(),
                               tags$style(type='text/css', '#detectStandard_msg {font-size:23px;}')
                             )
                      )
                    )
           ),
           tabPanel(title = "Settings", id = "settings",
                    fluidPage(
                      useShinyjs(),
                      renderSettingsUI("settingsUI")
                    )
           ),
           tabPanel(title = "Charts", value = "charts",
                      eDISHOutput("chart"),
                      downloadButton("reportDL", "Export Chart", style = "position: relative; top: 440px;")  
                    )
           )

