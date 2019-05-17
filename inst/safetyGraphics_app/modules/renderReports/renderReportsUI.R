#' Render Reports Tab - UI code
#'
#' This module creates the Reports tab for the Shiny app.

#' @param id The module-specific ID that will get pre-pended to all element IDs
#'
#' @return The UI for the Reports tab
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
