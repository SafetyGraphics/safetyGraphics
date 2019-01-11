library(shiny)
library(shinyjs)

tagList(
  useShinyjs(),
  tags$style(HTML("
        .ok { color:#008000;}
        .notok {color: #FF0000;}")),
  navbarPage("eDISH Shiny app",  
             tabPanel(title = htmlOutput("data_tab_title"), 
                      dataUploadUI("datatab")
             ),
             tabPanel(title = htmlOutput("settings_tab_title"),
                    fluidPage(
                      renderSettingsUI("settingsUI")
                    )
           ),
           tabPanel(title = htmlOutput("chart_tab_title"),
                    id = "charttab",
                    renderEDishChartUI("chartEDish")
          )
)
)
