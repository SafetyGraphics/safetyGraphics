# UI Code for safetyGraphics App

tagList(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "index.css")
  ),
  navbarPage("eDISH Shiny app",  id="nav_id",
             tabPanel(title = htmlOutput("data_tab_title"), 
                      dataUploadUI("datatab")
             ),
             tabPanel(title = "Settings",
                    fluidPage(
                      renderSettingsUI("settingsUI")
                    )
           ), 
           navbarMenu("Charts")
)
)
