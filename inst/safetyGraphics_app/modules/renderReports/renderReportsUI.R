#' Render eDISH chart - UI code
#'
#' This module creates the Chart tab for the Shiny app, which contains the interactive eDISH graphic.

#' @param id The module-specific ID that will get pre-pended to all element IDs
#'
#' @return The UI for the Chart tab
#'
renderReportsUI <- function(id){

  ns <- NS(id)
  
  fluidPage(
    fluidRow(
      column(10,
             wellPanel(
               class="reportPanel",
               h3(
                 "Charts"
               ),
               uiOutput(ns("checkboxes"))
             )
             
      )
    )
  )
  
}
