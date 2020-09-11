#' @title Charts Tab
#' @description  Charting module
#'
#' @export

chartTabUI <- function(id){
  ns <- NS(id)
  uiOutput(outputId = ns("chart"))
}

#' @title  home tab - server
#' @description  server for the display of the home tab  
#'
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param data list of data frames  [REACTIVE]
#' @param mapping data frame containing mapping arguments for chart [REACTIVE]
#' @param chartID string containing the chart ID. 
#' @param chartMeta data frame with the following columns. \enumerate{
#' \item `chartID` chartID
#' \item `label` text label
#' \item `type` type must be  'htmlwidget', 'module', 'static' or 'plotly'. Other optional parameters are: 
#' \item `UI` a function that accepts parameters called `data` and `mapping` and returns a chart object of the expected type. Defaults to `name()`
#' \item `server` a function that calls a shiny module server defaults to `nameServer()`. Ignored unless type='module'.
#' \item `onInit` a function that that accepts parameters called `data` and `mapping` and returns a list of custom parameters to be passed to the UI and server functions. returns list(data=data, mapping=mapping) with no changes by default. 
#'} If chartID isn't found in chartMeta, the system will attempt to draw a static plot with the provided data and mapping. 
#' 
#' @export

chartTab <- function(input, output, session, chart, data, mapping){
  ns <- session$ns
  
  #prepare the parameters for the chart
  chartParams<- list(data=data,mapping=mapping)
  
  if(tolower(type=="module")){
      #render the module UI
      #call the module server
  }else if(tolower(type=="htmlwidget")){
      #render the widget 
  }else{
      #create the static or plotly chart
  }

  
  
}