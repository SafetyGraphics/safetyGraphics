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
    tabsetPanel(
      tabPanel("About",
        fluidRow(
          column(width=8, style='font-size:20px', uiOutput(outputId = "about")),
          column(width=4, imageOutput(outputId = "hex"))
        )
      ),
      tabPanel("Shiny App User Guide",
               tags$iframe(style="height:800px; width:100%; scrolling=yes;",  `data-type`="iframe",
                           src = "https://cran.r-project.org/web/packages/safetyGraphics/vignettes/shinyUserGuide.html")
      ),
      tabPanel("Hep Explorer workflow",
               tags$iframe(style="height:800px; width:100%; scrolling=yes;",  `data-type`="iframe",
                                    src = "https://cdn.jsdelivr.net/gh/SafetyGraphics/SafetyGraphics.github.io/ISG%20Hepatic%20Safety%20Explorer%20User's%20Manual%20%26%20Workflow%20v1.0.pdf")
      )
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
