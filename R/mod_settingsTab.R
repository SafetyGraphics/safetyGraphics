#' UI for the settings page
#'
#' @param id module ID
#'  
#' @export

settingsTabUI <- function(id){
  ns <- NS(id)
  list(
    h1("Chart Metadata"),
    tabsetPanel(
      tabPanel(title = "Code", icon=icon("code"), settingsCodeUI(ns("codeSettings"))),
      tabPanel(title = "Mapping", icon=icon("map"), settingsMappingUI(ns("metaSettings"))),
      tabPanel(title = "Charts", icon=icon("chart-line"), settingsChartsUI(ns("chartSettings"))),
      tabPanel(title = "Data", icon=icon("table"), settingsDataUI(ns("dataSettings"))),
      type="pills" 
    )
  )
}


#' @title  Server for the setting page
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param domains domains
#' @param metadata metadata
#' @param mapping mapping
#' @param charts charts
#' 
#' @export

settingsTab <- function(id, input, output, session, domains, metadata, mapping, charts){
  callModule(settingsCode, "codeSettings",  mapping=mapping)
  callModule(settingsData, "dataSettings", domains = domains)
  callModule(settingsMapping, "metaSettings", metadata=metadata, mapping=mapping)
  callModule(settingsCharts, "chartSettings", charts = charts)
}