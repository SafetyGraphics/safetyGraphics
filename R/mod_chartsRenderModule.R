#' @title Charts Module - render module chart UI
#' @description  Charts Module - sub module for rendering a static chart
#' 
#' @param id module id
#' @param customModUI UI function for chart module
#' 
#' @export

chartsRenderModuleUI <- function(id, customModUI){
    ns <- NS(id)
    customModUI(ns("customModUI"))
}

#' @title  Charts Module - render static chart server
#' @description  server for the display of the loaded data  
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param serverFunction server function for the module
#' @param params parameters to be passed to the widget (Reactive)
#'
#' @export

chartsRenderModule <- function(input, output, session, serverFunction, params){
    ns <- session$ns
    callModule(serverFunction, "customModUI", params)
}
