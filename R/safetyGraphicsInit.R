#' Run the interactive safety graphics app
#'
#' @param charts chart object
#' @param delayTime time (in ms) between drawing app UI and starting server. Default set to 1000 (1 second), but could need to be higher on slow machine. 
#' 
#' @import shiny
#' @importFrom shinyjs hidden hide show delay disabled disable enable
#' 
#' @export

safetyGraphicsInit <- function(charts=makeChartConfig(), delayTime=1000){
  charts_init<-charts
  all_domains <- charts_init %>% map(~.x$domain) %>% unlist() %>% unique()

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
          all_domains %>% map(~loadDataUI(.x, domain=.x)),
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
    #initialize the chart selection moduls
    charts<-callModule(loadCharts, "load-charts",charts=charts_init) 
    domainDataR<-all_domains %>% map(~callModule(loadData,.x,domain=.x, visible=.x %in% current_domains))
    domainData<- reactive({domainDataR %>% map(~.x())})


    current_domains <- reactive({
      charts() %>% map(~.x$domain) %>% unlist() %>% unique()
    })

    observe({
      print(paste("current domains are:",paste(current_domains(),collapse=",")))
      for(domain in all_domains){
        if(domain %in% current_domains()){
          shinyjs::show(id=paste0(domain,"-wrap"))
        }else{
          shinyjs::hide(id=paste0(domain,"-wrap"))
        }
      }
    })

    initStatus <- reactive({
      currentData <- domainData()
      chartCount<-length(charts())
      domainCount<-length(currentData)
      loadCount<-sum(currentData %>% map_lgl(~!is.null(.x)))
      notAllLoaded <- any(currentData %>% map_lgl(~is.null(.x)))
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
  #app <- shinyApp(ui = ui, server = function(input,output,session){})
  runApp(app, launch.browser = TRUE)
}
