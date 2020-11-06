#' @title Charts Module - render module chart UI
#' @description  Charts Module - sub module for rendering a static chart
#' 
#' @import DT
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
#' @param chartFunction function to generate the chart.
#' @param params parameters to be passed to the widget [REACTIVE]
#'
#' @export

chartsRenderModule <- function(input, output, session, serverFunction, params){
    ns <- session$ns
    callModule(serverFunction, "customModUI", params)
}
