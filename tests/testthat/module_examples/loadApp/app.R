

library(shiny)
library(safetyGraphics)
library(shinyjs)
library(shinydashboard)
# reactlogReset()
# devtools::load_all()
charts_init <- makeChartConfig() # %>%keep(~.x$name=="aeTimelines")
domains_init <- unique(c(charts_init %>% map_chr(~ .x$domain)))
ui <- fluidPage(
  useShinyjs(),
  div(
    id = "step1",
    h2("Step 1: Select Charts"),
    loadChartsUI("load-charts", charts = charts_init),
    actionButton("submit-charts", "Submit Charts")
  ),
  div(
    id = "step2",
    h2("Step 2: Load Domain"),
    loadDomainsUI("load-data"),
    textOutput("dataSummary"),
    actionButton("start-app", "Submit Data and Start App"),
    actionButton("start-over", "Start Over")
  )
)

server <- function(input, output, session) {
  charts <- callModule(loadCharts, "load-charts", charts = charts_init)
  domains <- reactive({
    unique(charts() %>% map(~ .x$domain) %>% unlist())
  })
  domainData <- callModule(loadDomains, "load-data", domains)
  output$dataSummary <- renderText({
    domainData() %>% map_chr(~ paste(dim(.x()), collapse = "x"))
  })
}

shinyApp(ui, server)
