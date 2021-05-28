#' Run the interactive safety graphics app
#'
#' @param charts chart object
#' @param delayTime time (in ms) between drawing app UI and starting server. Default set to 1000 (1 second), but could need to be higher on slow machine. 
#' 
#' @import shiny
#' @importFrom shinyjs hidden hide show delay disabled disable enable
#' 
#' @export

safetyGraphicsInit <- function(charts=makeChartConfig(),delayTime=1000){
  charts_init<-charts
  app_css <- NULL
  for(lib in .libPaths()){
    if(is.null(app_css)){
      css_path <- paste(lib,'safetyGraphics', 'www','index.css', sep="/")
      if(file.exists(css_path)) app_css <-  HTML(readLines(css_path))
    }
  }
    
  ui<-fluidPage(
    useShinyjs(),
    tags$head(tags$style(app_css)),
    div(
      id="init",
      titlePanel("safetyGraphics Initialization app"),
      sidebarLayout(
        position="right",
        sidebarPanel(
          h4("Data Loader"),
          loadDomainsUI("load-data"),
          textOutput("dataSummary"),
          hr(),
          shinyjs::disabled(
            actionButton("runApp","Run App",class = "btn-block")
          )
        ),
        mainPanel(  
          loadChartsUI("load-charts", charts=charts_init),
        )
      ),
    ),
    shinyjs::hidden(
      div(
        id="sg-app",
        uiOutput("sg")
      )
    )
  )

  server <- function(input,output,session){ 
    charts<-callModule(loadCharts, "load-charts",charts=charts_init)
    domains <- reactive({unique(charts() %>% map(~.x$domain) %>% unlist())})
    domainDataR <- callModule(loadDomains, "load-data", domains) #this is a reactive list with reactives (?!)
    domainData <- reactive({domainDataR() %>% map(~.x())})

    initStatus <- reactive({
      chartCount<-length(charts())
      domainCount<-length(domainData())
      loadCount<-sum(domainData() %>% map_lgl(~!is.null(.x)))
      notAllLoaded <- any(domainData() %>% map_lgl(~is.null(.x)))
      ready<-FALSE
      if(domainCount==0){
        status<-paste("No charts selected. Select one or more charts and then load domain data to initilize app.")
      }else if(notAllLoaded) {
        status<-paste(chartCount, " charts selected. ",loadCount," of ",domainCount," data domains loaded. Load remaining data domains to initialize app.")
      }else{
        status<-paste("Loaded ",loadCount," data domains for ",chartCount," charts. Click 'Run App' button to initialize app.")
        ready<-TRUE
      }
      return(
        list(
          status=status,
          ready=ready
        )
      )
    })

    output$dataSummary <- renderText({initStatus()$status})
    observe({
      if(initStatus()$ready){
        shinyjs::enable(id="runApp")
      } else {
        shinyjs::disable(id="runApp")
      }
    })


    observeEvent(input$runApp,{
      print("running the app server now :p")
      shinyjs::hide(id="init")
      shinyjs::show(id="sg-app")
      config<- app_startup(
        domainData = domainData(),
        meta = safetyGraphics::meta, 
        charts= charts(),
        #mapping=NULL, 
        filterDomain="dm", 
        #chartSettingsPaths = NULL
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
