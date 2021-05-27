#' Run the interactive safety graphics app
#'
#' @param charts chart object
#' 
#' @import shiny
#' @importFrom shinyjs hidden hide show delay

#' 
#' @export

safetyGraphicsInit <- function(charts=makeChartConfig(),delayTime=500){
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
          textOutput("dataSummary"),
          loadDomainsUI("load-data"),
          hr(),
          actionButton("runApp","Run App",class = "btn-block")
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
    output$dataSummary <- renderText({
      ifelse(
        length(domainDataR())==0, 
        "Select charts and then load data.",
        "Load data for selected domains and then initialize"
      )
      #domainDataR() %>% map_chr(~paste(dim(.x()),collapse="x")) #Update this to be something useful
    })
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
      shinyjs::hide(id="init")
      shinyjs::show(id="sg-app")
      # delay is needed to get the appendTab in mod_chartsNav to trigger properly 
      shinyjs::delay(
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
