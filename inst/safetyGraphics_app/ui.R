# UI Code for safetyGraphics App

tagList(
  useShinyjs(),
  add_busy_spinner(spin = "fading-circle", position = "bottom-left", timeout=3000),
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
                             src = "https://cdn.jsdelivr.net/gh/SafetyGraphics/SafetyGraphics.github.io/guide/HepExplorerWorkflow_v1_1.pdf")
        )
      )
    ),
    navbarMenu("Config",
               tabPanel(
                 title = "Domain: labs",
                 configUI("labs")
               ),
               tabPanel(
                 title = "Domain: AEs",
                 configUI("aes")
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
