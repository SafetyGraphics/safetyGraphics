#' RStudio Add-in for constructing lean ADLB and ADAE data
#' 
#' 
#' @import shiny
#' @import shinyFiles
#' @import listviewer
#' 


app_init_addin <- function(){
  
  
  ui <- bootstrapPage(
    
    shiny::wellPanel(
      h1("Choose Configs"),
      shinyFiles::shinyDirButton('directory', label='Dir select', title='Please select a folder', multiple=FALSE),
      shiny::verbatimTextOutput("directorypath")
    ),
    
    
    shiny::wellPanel(
      h1("View and Edit Config"),
      hr(),
      
      shiny::wellPanel(
        h3("Edit Chart level config/Meta data"),
        listviewer::reactjsonOutput( "rjed" )
      ),
      hr(),
      
      shiny::wellPanel(
        h3("Result config/chart meta data"),
        DT::DTOutput("DTmeta")
      ),
      hr(),
      
      shiny::wellPanel(
        h3("Add chart"),
        splitLayout(
          textInput("chart_name", label = "Chart Name or ID", value="new_chart"),
          textInput("chart_label", label = "Chart Label", value="New Chart"), 
          selectizeInput("chart_type", "Type of chart", choices=c("plot", "module", "htmlwidget"), selected="plot"),
          selectizeInput("chart_domain", "Choose data domain", choices=c("aes", "labs", "mutliple"), selected="labs"),
          textInput("chart_package", "R package", value = "No Package"),
          textInput("chart_path", "Path to chart yaml file")
        ),
        actionButton("addChartBtn",  "Add chart")
      )
    ),
    
    
    tags$head(
      tags$style(HTML("
       iframe
    {
        max-height: 200vh;
        height:800px;
    }
    "))
    ),
    
    shiny::wellPanel(
      h1("Preview App"),
      uiOutput("app")
    ) 
    
  )
  
  server <- function(input, output, session) {
    
    volumes <- c(Home = fs::path_home(), "R Installation" = R.home(), shinyFiles::getVolumes()())
    
    shinyFiles::shinyFileChoose(input, "file", roots = volumes, session = session)
    shinyFiles::shinyDirChoose(input, "directory", roots = volumes, session = session, restrictions = system.file(package = "base"), allowDirCreate = FALSE)
    
    
    local_rv <- reactiveValues()
    
    shiny::observeEvent(input$selectFile, {
      
      path <- rstudioapi::selectFile()
      
      local_rv$filesel <- file.info(path)
      
    })
    
    
    output$fileSelected <- renderPrint({
    
      local_rv$filesel
    })    
    
    output$filepaths <- renderPrint({
      if (is.integer(input$file)) {
        cat("No files have been selected (shinyFileChoose)")
      } else {
        shinyFiles::parseFilePaths(volumes, input$file)
      }
    })
    
    dirParsed <- reactive({
      shinyFiles::parseDirPath(volumes, input$directory)
    })
    
    output$directorypath <- renderPrint({
      if (is.integer(input$directory)) {
        cat("No directory has been selected (shinyDirChoose)")
      } else {
        dirParsed()
      }
    })
    
    # load config
    configObj <- reactive({
      req(dirParsed())
      safetyGraphics::makeChartConfig(
        dirs = dirParsed()
      )
      
    })
    
    
    safetyGraphicsApp1 <- function(
      domainData=list(
        labs=safetyGraphics::labs, 
        aes=safetyGraphics::aes, 
        dm=safetyGraphics::dm
      ),
      meta = safetyGraphics::meta, 
      charts=NULL,
      mapping=NULL,
      chartSettingsPaths = NULL
    ){
      
      config <- safetyGraphics:::app_startup(domainData, meta, charts, mapping, chartSettingsPaths)
      
      app <- shinyApp(
        ui =  app_ui(config$meta, config$domainData, config$mapping, config$standards),
        server = app_server(input, output, session, config$meta, config$mapping, config$domainData, config$charts)
      )
    }
    
    
    output$app <- renderUI({
      req(input$rjed_edit)
      #browser()
      print(names(newConfig()))
      tagList(
        safetyGraphicsApp1(charts = newConfig())
      )
    })
    

    output$rjed <- listviewer::renderReactjson({
      req(configObj())
      listviewer::reactjson( configObj() )
    })
    

    oldConfig <- reactive({
      safetyGraphics::makeChartConfig(dirs=dirParsed()) 
    })
    
    newConfig <- eventReactive(eventExpr = input$rjed_edit, valueExpr = {
      
      
      newChartConfig <- input$rjed_edit$value$updated_src
      
      for (i in seq_along(names(newChartConfig))) {
        
        
        chartFunctions <- newChartConfig[[i]]$functions
        chartFunctionsNames <- names(chartFunctions)
        
        chartFunctions <- lapply(chartFunctionsNames, 
                                 function(cf) {
                                   eval(parse(text=paste(unlist(chartFunctions[[cf]]), collapse = "\n")), 
                                        envir = .GlobalEnv)
                                 })  
        names(chartFunctions) <- chartFunctionsNames
        newChartConfig[[i]]$functions <- chartFunctions
      }
      newChartConfig
    })
    
    tblMeta <- function(charts){
      
      bbb <- purrr::map(charts, ~{
        bb <- as_tibble(t(tibble(.x)))
        names(bb) <- names(.x)
        bb
      })
      
      bbbb<- do.call(bind_rows,  bbb)
      
    }

    
    # DT for charts meta data
    output$DTmeta <- DT::renderDT({
      tblMeta(newConfig())
    })
    
    
    
    
  }
  
  #viewer <- dialogViewer("SafetyApp initializer", width = 1200, height = 900)
  viewer <- shiny::browserViewer(browser = getOption("browser"))
  shiny::runGadget(ui, server, viewer = viewer )
}


