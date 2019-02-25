tagList(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "index.css")
  ),
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
