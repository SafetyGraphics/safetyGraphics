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
    title = "Home", icon=icon("home"),
    fluidRow(
     # tags$style(type='text/css', '#about {font-size:23px;}'),
      column(width=9, style='font-size:20px', uiOutput(outputId = "about"))
    )
  ),
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
        renderReportsUI("reportsUI")
      )
    )
  )
)
