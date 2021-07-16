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
  ns <- NS(id)    
  # Chart header with description and links
  header<-makeChartSummary(chart)

  # Make Chart Wrapper
  if(chart$type=="plot"){
    chartWrap<-plotOutput(ns("chart-wrap"))
  }else if(chart$type=="html"){
    chartWrap<-htmlOutput(ns("chart-wrap"))
  }else if(chart$type=="table"){
    chartWrap<-DT::dataTableOutput(ns("chart-wrap"))
  }else if(chart$type=="rtf"){
    chartWrap<-div(
      downloadButton(ns("downloadRTF"), "Download RTF"),
      DT::dataTableOutput(ns("chart-wrap"))
    )
  }else if(chart$type=="htmlwidget"){
    chartWrap<-htmlwidgets::shinyWidgetOutput(
      ns("chart-wrap"), 
      chart$workflow$widget, 
      "100%", 
      "100%",
      package=chart$package
    )
  }else if(chart$type=="module"){
    chartWrap<-chart$functions[[chart$workflow$ui]](ns("chart-wrap"))
  }else{
    chartWrap <- div("Invalid Chart Type")
  }

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

  # Helper functions for html widget render
  widgetOutput <- function(outputId, width = "100%", height = "400px") {
    htmlwidgets::shinyWidgetOutput(outputId, chart, width, height, package=package)
  }

  renderWidget <- function(expr, env = parent.frame(), quoted = FALSE) {
    if (!quoted) { expr <- substitute(expr) } # force quoted
    htmlwidgets::shinyRenderWidget(expr, widgetOutput, env, quoted = TRUE)
  }

  # Draw the chart
 
  if(chart$type=="plot"){
    output[["chart-wrap"]] <- renderPlot(
      do.call(
        chart$functions[[chart$workflow$main]],
        params()
      )
    ) 
  }else if(chart$type=="html"){
    output[["chart-wrap"]] <- renderText(
      do.call(
        chart$functions[[chart$workflow$main]],
        params()
      )
    ) 
  }else if(chart$type=="table"){
    output[["chart-wrap"]] <- DT::renderDataTable(
      do.call(
        chart$functions[[chart$workflow$main]], 
        params()
      ), 
      rownames = FALSE,
      options = list(
        pageLength = 20,
        ordering = FALSE,
        searching = FALSE
      )
    ) 
  }else if(chart$type=="htmlwidget"){
    output[["chart-wrap"]] <- renderWidget(
      htmlwidgets::createWidget(
        name = chart$workflow$widget,
        params(),
        package = chart$package,
        sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE),     
      )
    )
  }else if(chart$type=="module"){
    callModule( 
      chart$functions[[chart$workflow$server]], 
      "chart-wrap", 
      params
    )
  } else if(type == "rtf") {
    output[["chart-wrap"]] <- DT::renderDataTable(
      do.call(chartFunction,params())$table, 
      rownames = FALSE,
      options = list(
        pageLength = 20,
        ordering = FALSE,
        searching = FALSE
      )
    ) 
    
    output[["downloadRTF"]] <- downloadHandler(
      filename = "SafetyGraphics.rtf",
      content = function(file) {
        pharmaRTF::write_rtf(do.call(chartFunction,params()), file = file)
      }
    )
  }
}
