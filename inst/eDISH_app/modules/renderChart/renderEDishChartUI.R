renderEDishChartUI <- function(id){
  
  ns <- NS(id)
  
  tagList(
    eDISHOutput(ns("chart"))
  )
}