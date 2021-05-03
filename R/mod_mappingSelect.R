#' Mapping Select UI 
#' 
#' UI that facilitates the mapping of a single data element (column or field) with a simple select UI
#'
#' @param id unique id for the UI
#' @param label label associated with the control  
#' @param choices a list of options for the control
#' @param default default value for the control
#'
#' @return returns the selected value wrapped in a \code{reactive()}.
#'
#' @export

mappingSelectUI <- function(id, label, choices=NULL, default=NULL){  
    ns <- NS(id)
    # define placeholder code 
    defaultOptions <- NULL
    if (is.null(default)){
        defaultOptions <- list(onInitialize = I('function() {this.setValue("");}'))
    } else if (default %in% choices){
        defaultOptions <- list(onInitialize = I('function() {}'))
    } else {
        defaultOptions <- list(onInitialize = I('function() {this.setValue("");}'))
    }
    
    selectizeInput(
        inputId = ns("colSelect"), 
        label = label, 
        selected = default,
        choices = as.list(choices), 
        options = defaultOptions,
        multiple = FALSE
    )
}

#' @title  mappingSelect
#' @description  server function that facilitates the mapping of a single data element (column of field) with a simple select UI
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' 
#' @return A reactive containing the selected column
#'
#' @export

mappingSelect <- function(input, output, session){
    # return the current value of the column select
    reactive(input$colSelect)
}
