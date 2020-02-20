RenderChart <- R6::R6Class(
  "RenderChart", 
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
        # 
        # self$addInputPort(
        #   name = "chart",
        #   description = "Name of chart",
        #   sample = NA
        # )
        
      })
      
    },
    ui = function() {
      tagList(
        uiOutput(self$ns("chart"))
      )
    },
    server = function(input, output, session) {
      # Mandatory
      super$server(input, output, session)
      
      ns <- self$ns
      
      chartname <- stringr::str_remove(self$id, "charts-chart")
      chart_id <- paste0("chart_", chartname)

      # code to dynamically generate the output location
      output$chart <- renderUI({
        output_chartRenderer(ns(chart_id))
      })
 
        output[[chart_id]] <- render_chartRenderer({
          req(self$getInput("data"))
          req(self$getInput("settings"))
          chartRenderer(data = self$getInput("data")(),
                        settings = self$getInput("settings")(),
                        chart = chartname,
                        debug_js=TRUE)
        })

      
    }
    
  )
)
