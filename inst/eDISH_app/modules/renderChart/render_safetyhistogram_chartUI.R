render_safetyhistogram_chartUI <- function(id){
  
  ns <- NS(id)
  
  safetyHistogramOutput(ns("chart")) 
}