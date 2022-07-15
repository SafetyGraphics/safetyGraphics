#' App to select charts, load data and then initialize the core safetyGraphics app
#'
#' @param charts chart object
#' @param delayTime time (in ms) between drawing app UI and starting server. Default set to 1000 (1 second), but could need to be higher on slow machine.
#' @param maxFileSize maximum file size in MB allowed for file upload
#'
#' @import shiny
#' @importFrom shinyjs hidden hide show delay disabled disable enable
#'
#' @export

safetyGraphicsInit <- function(charts = makeChartConfig(), delayTime = 1000, maxFileSize = NULL) {
  charts_init <- charts
  all_domains <- charts_init %>%
    map(~ .x$domain) %>%
    unlist() %>%
    unique()

  # increase maximum file upload limit
  if (!is.null(maxFileSize)) {
    options(shiny.maxRequestSize = (maxFileSize * 1024^2))
    if (maxFileSize > 100) {
      message("NOTE: Loading very large files may cause performance issues in the safetyGraphics app.")
    }
  }

  css_path <- system.file("www", "index.css", package = "safetyGraphics")
  app_css <- HTML(readLines(css_path))

  ui <- fluidPage(
    useShinyjs(),
    tags$head(tags$style(app_css)),
    div(
      id = "init",
      titlePanel("safetyGraphics Initializer"),
      sidebarLayout(
        position = "right",
        sidebarPanel(
          h4("Data Loader"),
          all_domains %>% map(~ loadDataUI(.x, domain = .x)),
          textOutput("dataSummary"),
          hr(),
          shinyjs::disabled(
            actionButton("runApp", "Run App", class = "btn-block")
          )
        ),
        mainPanel(
          p(
            icon("info-circle"),
            "First, select charts by dragging items between the lists below. Next, load the required data domains using the controls on the right. Finally, click Run App to start the safetyGraphics Shiny App. Reload the webpage to select new charts/data.",
            class = "info"
          ),
          loadChartsUI("load-charts", charts = charts_init),
        )
      ),
    ),
    shinyjs::hidden(
      div(
        id = "sg-app",
        uiOutput("sg")
      )
    )
  )

  server <- function(input, output, session) {
    # initialize the chart selection moduls
    charts <- callModule(loadCharts, "load-charts", charts = charts_init)
    domainDataR <- all_domains %>% map(~ callModule(loadData, .x, domain = .x))
    names(domainDataR) <- all_domains
    domainData <- reactive({
      domainDataR %>% map(~ .x())
    })


    current_domains <- reactive({
      charts() %>%
        map(~ .x$domain) %>%
        unlist() %>%
        unique()
    })

    observe({
      for (domain in all_domains) {
        if (domain %in% current_domains()) {
          shinyjs::show(id = paste0(domain, "-wrap"))
        } else {
          shinyjs::hide(id = paste0(domain, "-wrap"))
        }
      }
    })

    initStatus <- reactive({
      currentData <- domainData()
      chartCount <- length(charts())
      domainCount <- length(current_domains())
      loadCount <- sum(currentData %>% map_lgl(~ !is.null(.x)))
      notAllLoaded <- sum(currentData %>% map_lgl(~ !is.null(.x))) < domainCount
      ready <- FALSE
      if (domainCount == 0) {
        status <- paste("No charts selected. Select one or more charts and then load domain data to initilize app.")
      } else if (notAllLoaded) {
        status <- paste(chartCount, " charts selected. ", loadCount, " of ", domainCount, " data domains loaded. Load remaining data domains to initialize app.")
      } else {
        status <- paste("Loaded ", loadCount, " data domains for ", chartCount, " charts. Click 'Run App' button to initialize app.")
        ready <- TRUE
      }
      return(
        list(
          status = status,
          ready = ready
        )
      )
    })

    output$dataSummary <- renderText({
      initStatus()$status
    })
    observe({
      if (initStatus()$ready) {
        shinyjs::enable(id = "runApp")
      } else {
        shinyjs::disable(id = "runApp")
      }
    })

    observeEvent(input$runApp, {
      shinyjs::hide(id = "init")
      shinyjs::show(id = "sg-app")
      config <- app_startup(
        domainData = domainData() %>% keep(~ !is.null(.x)),
        meta = NULL,
        charts = charts(),
        # mapping=NULL,
        filterDomain = "dm",
        autoMapping = TRUE,
        # chartSettingsPaths = NULL
      )

      output$sg <- renderUI({
        safetyGraphicsUI(
          "sg",
          config$meta,
          config$domainData,
          config$mapping,
          config$standards
        )
      })

      # delay is needed to get the appendTab in mod_chartsNav to trigger properly
      shinyjs::delay(
        delayTime,
        callModule(
          safetyGraphicsServer,
          "sg",
          config$meta,
          config$mapping,
          config$domainData,
          config$charts,
          config$filterDomain
        )
      )
    })
  }

  app <- shinyApp(ui = ui, server = server)
  runApp(app, launch.browser = TRUE)
}
