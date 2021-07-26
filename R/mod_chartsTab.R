#' @title Charts Tab
#' @description  Charting module
#'
#' @param id module id
#' @param chart list containing chart specifications
#' 
#' @importFrom stringr str_to_title
#' @importFrom purrr map2
#' 
#' @export

chartsTabUI <- function(id, chart){
  ns <- shiny::NS(id)    
  header<-makeChartSummary(chart)
  chartWrap<-chart$functions$ui(ns("chart-wrap"))

  return(list(header, chartWrap))
}

#' @title  home tab - server
#' @description  server for the display of the chart tab  
#'
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param chart list containing a safetyGraphics chart object. see custom chart vignette for details. 
#' @param data named list of current data sets (Reactive).
#' @param mapping tibble capturing the current data mappings (Reactive).
#' 
#' @export

chartsTab <- function(input, output, session, chart, data, mapping){  
  ns <- session$ns
  message("chartsTab() starting for ",chart$name)

  # Initialize chart-specific parameters  
  params <- reactive({ 
    makeChartParams(
      data = data(),
      mapping = mapping(),
      chart = chart
    )
  })

  # Draw the chart
  if(chart$type=="module"){
    callModule(chart$functions$main, "chart-wrap", params)
  }else{
    output[["chart-wrap"]] <- chart$functions$server(
      do.call(
        chart$functions$main,
        params()
      )
    )
  }
  
}
