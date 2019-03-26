#' Render Safety Histogram chart - server code
#' 
#' This module creates the Chart tab for the Shiny app, which contains the interactive Histogram graphic. 
#' 
#' Workflow: 
#' (1) A change in `data`, `settings`, or `valid` invalidates the safety histogram chart output
#' (2) Upon a change in `valid`, the export chart functionality is conditionally made available or unavailable to user
#' 
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param data A data frame 
#' @param valid A logical indicating whether data/settings combination is valid for chart

render_safetyhistogram_chart <- function(input, output, session, data, settings, valid){
  
  ns <- session$ns
  
  
  # render eDISH chart if settings pass validation
  output$chart <- renderSafetyHistogram({
    req(data())
    req(settings())
    
  #  if (valid()==TRUE){
      trimmed_data <- safetyGraphics:::trimData(data = data(), settings = settings())
      safetyHistogram(data = data(), settings = settings())
    # } else{
    #   return()
    # }
  }) 
  
}