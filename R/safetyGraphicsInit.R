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
      actionButton("submit-charts","Submit Charts")        
    ),
    div(id="step2",
      h2("Step 2: Load Domain"),
      loadDomainsUI("load-data"),
      textOutput("dataSummary"),
      actionButton("start-app","Submit Data and Start App"),
      actionButton("start-over","Start Over")
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
  
  
  

