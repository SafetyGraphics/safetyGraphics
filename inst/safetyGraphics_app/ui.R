# UI Code for safetyGraphics App

tagList(
  useShinyjs(),
  tags$head(
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "index.css"
    ),
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "https://use.fontawesome.com/releases/v5.8.1/css/all.css"
    )
  ),
  navbarPage(
    "safetyGraphics Shiny app",
    id="nav_id",
    tabPanel(
      title = "Data",
      dataUploadUI("datatab")
    ),
    tabPanel(
      title = "Settings",
      fluidPage(
        renderSettingsUI("settingsUI")
      )
    ),
    navbarMenu("Charts"),
    tabPanel(
      title = "Reports",
      fluidPage(
        fluidRow(
          column(10,
                 wellPanel(
                   class="reportPanel",
                   h3(
                     "Reports THAT YOU NEED"
                   )
                 )
                 
          )
        )
      )
    )
    )
)
