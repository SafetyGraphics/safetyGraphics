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
  # Chart header with description and links
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

#chartsTab <- function(input, output, session, chart, type, package, chartFunction, initFunction, domain, data, mapping){
chartsTab <- function(input, output, session, chart, data, mapping){  
  ns <- session$ns
  message("chartsTab() starting for ",chart$name)

  # Initialize chart-specific parameters  
  params <- reactive({ 
    makeChartParams(
      data = data(),
      mapping= mapping(),
      chart=chart
    )
  })

  # Draw the chart
  output[["chart-wrap"]] <- chart$functions$server(
    do.call(
      chart$functions$main,
      params()
    )
  )
  # if(chart$type=="plot"){
  #   output[["chart-wrap"]] <- renderPlot(
  #     do.call(
  #       chart$functions[[chart$workflow$main]],
  #       params()
  #     )
  #   ) 
  # }else if(chart$type=="html"){
  #   output[["chart-wrap"]] <- renderText(
  #     do.call(
  #       chart$functions[[chart$workflow$main]],
  #       params()
  #     )
  #   ) 
  # }else if(chart$type=="table"){
  #   output[["chart-wrap"]] <- DT::renderDataTable(
  #     do.call(
  #       chart$functions[[chart$workflow$main]], 
  #       params()
  #     ), 
  #     rownames = FALSE,
  #     options = list(
  #       pageLength = 20,
  #       ordering = FALSE,
  #       searching = FALSE
  #     )
  #   ) 
  # }else if(chart$type=="htmlwidget"){
  #   output[["chart-wrap"]] <- renderWidget(
  #     htmlwidgets::createWidget(
  #       name = chart$workflow$widget,
  #       params(),
  #       package = chart$package,
  #       sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE),     
  #     )
  #   )
  # }else if(chart$type=="module"){
  #   callModule( 
  #     chart$functions[[chart$workflow$server]], 
  #     "chart-wrap", 
  #     params
  #   )
  # } else if(type == "rtf") {
  #   output[["chart-wrap"]] <- DT::renderDataTable(
  #     do.call(chartFunction,params())$table, 
  #     rownames = FALSE,
  #     options = list(
  #       pageLength = 20,
  #       ordering = FALSE,
  #       searching = FALSE
  #     )
  #   ) 
    
  #   output[["downloadRTF"]] <- downloadHandler(
  #     filename = "SafetyGraphics.rtf",
  #     content = function(file) {
  #       pharmaRTF::write_rtf(do.call(chartFunction,params()), file = file)
  #     }
  #   )
  # }
}
