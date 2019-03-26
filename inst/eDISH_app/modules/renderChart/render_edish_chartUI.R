#' Render eDISH chart - UI code
#' 
#' This module creates the Chart tab for the Shiny app, which contains the interactive eDISH graphic.  

#' @param id The module-specific ID that will get pre-pended to all element IDs
#'
#' @return The UI for the Chart tab
#'
render_edish_chartUI <- function(id){
  
  ns <- NS(id)
  
  eDISHOutput(ns("chart")) 
}