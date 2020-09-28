#' @title Settings Module - chart details
#' @description  Settings Module - sub-module showing details for the charts loaded in the app - UI
#'
#' @export

settingsChartsUI <- function(id){
  ns <- NS(id)
  list(
    h1("Chart Metadata"),
    verbatimTextOutput(ns("chartList")))
}

#' @title  Settings Module - charts details - server
#' @description  server for the display of the charts
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param named list data frame summarizing the charts
#' 
#' @export

settingsCharts <- function(input, output, session, charts){
  ns <- session$ns
  output$chartList <- renderPrint({
    print(charts)
  })
}