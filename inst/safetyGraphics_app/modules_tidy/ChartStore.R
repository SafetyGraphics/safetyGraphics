ChartStore <- R6::R6Class(
  classname = "ChartStore",
  inherit = TidyModule,
  public = list(
    initialize = function(...){
      # mandatory
      super$initialize(...)
  
      self$definePort(
        self$addOutputPort(
          name = "chartmods",
          description = "Names of chart modules",
          sample = "chartid")
      )
        
    },
      
    ui = function(){
        tableOutput(self$ns("myns"))
    },
    server = function(input, output, session){
      # Mandatory
      super$server(input,output,session)
      
      mods <- reactive({
        s <- self$getStore()
        d <- do.call(
          rbind,
          lapply(
            s$getMods(self),
            function(l){
              data.frame(
                namespace = l$module_ns,
                class = paste(class(l),collapse = " <- "),
                group = ifelse(is.null(l$group),"",l$group)
              )
              }
          )
        )
        return(subset(d, group=="charts"))
      })
      
      output$myns <- renderTable({
        mods()
      })
      
      chart_mods <- reactive({
        req(mods())
        mods()$namespace
      })
      
      self$assignPort({
        self$updateOutputPort(
          id = "chartmods",
          output = chart_mods
        ) 
      })
      
    }
  )
)
