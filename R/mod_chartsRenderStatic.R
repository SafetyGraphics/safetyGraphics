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
#' @param initFunction function called before the chart is generated. Should return a list of parameters that will be provided to chartFunction. returns list(data=data, settings=settings) by default. 
#' @param data named list of data sets [reactive]
#' @param mapping data mapping [reactive]
#'
#' @export

chartsRenderStatic <- function(input, output, session, chartFunction, initFunction, data, mapping){
  ns <- session$ns

  if(missing(initFunction)){
    initFunction <- function(data,settings){return(list(data=data,settings=settings))}
  }

  params <- reactive({
    initFunction(data=data(),settings=mapping())
  })

  output[["staticChart"]] <- renderPlot(do.call(chartFunction,params())) 
}
