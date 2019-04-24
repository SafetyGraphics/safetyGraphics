#' Render safety hisotgram chart - UI code
#' 
#' This module creates the Chart tab for the Shiny app, which contains the interactive safety histogram graphic.  

#' @param id The module-specific ID that will get pre-pended to all element IDs
#'
#' @return The UI for the Chart tab
#'
render_safetyhistogram_chartUI <- function(id){
  
  ns <- NS(id)
  
  safetyHistogramOutput(ns("chart")) 
}