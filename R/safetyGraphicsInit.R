#' Run the interactive safety graphics app
#'
#' @param charts chart object
#' 
#' @import shiny
#' @import safetyData
#' 
#' @export

safetyGraphicsInit <- function(charts=makeChartConfig()){
  charts_init<-charts
  ui<-fluidPage(
    useShinyjs(),
    div(id="step1",
      h2("Step 1: Select Charts"),
      loadChartsUI("load-charts", charts=charts_init),
    ),
    div(id="step2",
      h2("Step 2: Load Data for each Domain"),
      loadDomainsUI("load-data"),
      textOutput("dataSummary"),
    ),
    div(id="step3",
      h2("Step 3: Code to intialize the app"),
      textOutput("appCode"),
      actionButton("runApp","Run App")
    )
  )

  server <- function(input,output,session){ 
    charts<-callModule(loadCharts, "load-charts",charts=charts_init)
    domains <- reactive({unique(charts() %>% map(~.x$domain) %>% unlist())})
    domainData <- callModule(loadDomains, "load-data", domains)

    output$dataSummary <- renderText({
      domainData() %>% map_chr(~paste(dim(.x()),collapse="x"))
    })
  }

  app <- shinyApp(ui = ui, server = server)

  runApp(app, launch.browser = TRUE)
}
  
  
  

