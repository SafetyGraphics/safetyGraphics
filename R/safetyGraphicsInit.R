#' Run the interactive safety graphics app
#'
#' @param charts chart object
#' 
#' @import shiny
#' @import safetyData
#' 
#' @export

safetyGraphicsInit <- function(charts=makeChartConfig(),delayTime=500){
  charts_init<-charts
  ui<-fluidPage(
    useShinyjs(),
    div(id="init-steps",
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
    ),
    hidden(
      div(id="sg-app",
        uiOutput("sg")
      )
    )


  )

  server <- function(input,output,session){ 
    charts<-callModule(loadCharts, "load-charts",charts=charts_init)
    domains <- reactive({unique(charts() %>% map(~.x$domain) %>% unlist())})
    domainDataR <- callModule(loadDomains, "load-data", domains) #this is a reactive list with reactives (?!)
    domainData <- reactive({domainDataR() %>% map(~.x())})
    output$dataSummary <- renderText({
      domainDataR() %>% map_chr(~paste(dim(.x()),collapse="x")) #Update this to be something useful
    })

    # Prep config once the user clicks run app
    config<- reactive({
      app_startup(
        domainData = domainData(),
        meta = safetyGraphics::meta, 
        charts= charts(), 
        mapping=NULL, 
        filterDomain="dm", 
        chartSettingsPaths = NULL
      )
    })

    output$sg <- renderUI({
      safetyGraphicsUI(
        "sg",
        config()$meta, 
        config()$domainData, 
        config()$mapping, 
        config()$standards
      )    
    })

    observeEvent(input$runApp,{
      print("running the app server now :p")
      hide(id="init-steps")
      show(id="sg-app")
      # delay is needed to get the appendTab in mod_chartsNav to trigger properly 
      delay(
        delayTime,
        callModule(
          safetyGraphicsServer,
          "sg",
          config()$meta, 
          config()$mapping, 
          config()$domainData, 
          config()$charts, 
          config()$filterDomain
        )
      )
    })
  }

  app <- shinyApp(ui = ui, server = server)

  runApp(app, launch.browser = TRUE)
}
  
  
  

