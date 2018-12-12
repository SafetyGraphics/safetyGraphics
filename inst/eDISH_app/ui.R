library(shiny)
library(shinyjs)

tagList(
  useShinyjs(),
  navbarPage("eDISH Shiny app", id = "inTabset", 
           tabPanel(title = "Data", value = "data",
                    dataUploadUI("datatab")
           ),
           tabPanel(title = "Settings", id = "settings",
                    fluidPage(
                      renderSettingsUI("settingsUI")
                    )
           ),
           tabPanel(title = "Charts", 
                    id = "charts",
                    renderEDishChartUI("chartEDish")
          )
)
)
