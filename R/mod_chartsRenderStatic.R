#' @title Charts Module - render static chart UI
#' @description  Charts Module - sub module for rendering a static chart
#' 
#' @export

chartsRenderStaticUI <- function(id){
  ns <- NS(id)
  plotOutput(ns("staticChart"))
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

chartsRenderStatic <- function(input, output, session, chartFunction, params){
  ns <- session$ns
  output[["staticChart"]] <- renderPlot(do.call(chartFunction,params())) 
}
