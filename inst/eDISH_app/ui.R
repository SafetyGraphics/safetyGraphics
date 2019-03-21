# UI Code for safetyGraphics App

tagList(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "index.css")
  ),
  navbarPage("eDISH Shiny app",  id="tabs",
             tabPanel(title = htmlOutput("data_tab_title"), 
                      dataUploadUI("datatab")
             ),
             tabPanel(title = htmlOutput("settings_tab_title"),
                    fluidPage(
                      renderSettingsUI("settingsUI")
                    )
           ), 
           navbarMenu("Charts")
          #  tabPanel(title = htmlOutput("chart_tab_title"),
          #           id = "charttab",
          #           renderEDishChartUI("chartEDish")
          # )
)
)
