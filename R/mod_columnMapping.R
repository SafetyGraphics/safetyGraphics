#' @title   ColumnMappingUI 
#' @description  Module that facilitates the mapping of a single column with a simple select UI
#'
#' @param id unique id for the UI
#' @param label associated with the control  
#' @param choices a list of options for the control
#' @param default default value for the control
#'
#' @section Output:
#' \describe{
#' \item{\code{columnMapping}}{list describing the column mapping}
#' }
#' 
#' @export

columnMappingInput <- function(id, label, choices, default=NULL){  
   ns <- NS(id)
    #select input
   
   # define placeholder code 
   defaultOptions <- NULL
   if (is.null(default)){
     defaultOptions <- list(onInitialize = I('function() {this.setValue("");}'))
   } else if (default %in% choices){
     defaultOptions <- list (onInitialize = I('function() { }'))
   } else {
     defaultOptions <- list(onInitialize = I('function() {this.setValue("");}'))
   }
   
    input <- selectizeInput(
        inputId = ns("colSelect"), 
        label = label, 
        selected = default,
        choices = choices, 
        options = defaultOptions,
        multiple = FALSE
    )
}

# Column Mapping server code

#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#'
#' @export

columnMapping <- function(input, output, session){
  ns <- session$ns
  
  observeEvent(input$colSelect,{
    print(paste("changed to",input$colSelect))
  })
  
  # return the current value of the input
  reactive(input$colSelect)
}
