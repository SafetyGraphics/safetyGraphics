RenderReports <- R6::R6Class(
  "RenderReports", 
  inherit = tidymodules::TidyModule,
  public = list(
    initialize = function(...){
      # mandatory
      super$initialize(...)
      
      self$definePort({
        
        self$addInputPort(
          name = "data",
          description = "Input data",
          sample = data.frame(c(1,2,3)))
        
        self$addInputPort(
          name = "settings",
          description = "settings object corresponding to selected data",
          sample = list()
        )
        
        self$addInputPort(
          name = "charts",
          description = "Name of charts to include",
          sample = NA
        )
        
      })
      
    },
    ui = function() {
      fluidPage(
        fluidRow(
          column(10,
                 wellPanel(
                   class="reportPanel",
                   h3(
                     "Charts"
                   ),
                   uiOutput(self$ns("checkboxes"))
                 )
                 
          )
        )
      )
    },
    server = function(input, output, session) {
      # Mandatory
      super$server(input, output, session)
      
      ns <- self$ns
      
    #  observeEvent(self$getInput("charts")(), {
      observe({
        req(self$getInput("charts"))
        
        checkboxes <- checkboxGroupInput(ns('chk'), choices = self$getInput("charts")(), 
                                         selected = self$getInput("charts")(), 
                                         label = "Select Charts for Export")
        
        output$checkboxes <- renderUI(checkboxes)
        
      }) #, ignoreNULL=TRUE, ignoreInit = TRUE)
      
      
      
      # insert export chart(s) button if there are charts selected
      
      #  observeEvent(self$getInput("charts")(), {
      observe({
        req(self$getInput("charts"))
        
        removeUI(selector = paste0("#", ns("download")))
        if (!is.null(self$getInput("charts")())){
          insertUI (
            selector  = "div.reportPanel",
            where = "afterEnd",
            ui =  div(id=ns("download"), # give the container div an id for easy removal
                      style="float: left;",
                      span(       downloadButton(ns("reportDL"), "Export Chart(s)")) )
          )
        }
      }) #, ignoreNULL=TRUE, ignoreInit=TRUE)
      
      
      # Set up report generation on download button click
      output$reportDL <- downloadHandler(
        filename = "safetyGraphicsReport.html",
        content = function(file) {
          # Copy the report file to a temporary directory before processing it, in case we don't
          # have write permissions to the current working dir (which can happen when deployed).
          templateReport <- system.file("safetyGraphics_app/modules/renderReports","safetyGraphicsReport.Rmd", package = "safetyGraphics")
          tempReport <- file.path(tempdir(), "report.Rmd")
          file.copy(templateReport, tempReport, overwrite = TRUE)
          params <- list(data = self$getInput("data")(), 
                         settings = self$getInput("settings")(), 
                         charts=input$chk )
          
          rmarkdown::render(tempReport,
                            output_file = file,
                            params = params,  ## pass in params
                            envir = new.env(parent = globalenv())  ## eval in child of global env
          )
        }
      )
      
      
      
    }
    
  )
)
