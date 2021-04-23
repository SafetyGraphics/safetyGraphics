#' @title Charts Module - render static chart UI
#' @description  Charts Module - sub module for rendering a static chart
#' 
#' @param id module id
#' @param type output type for the chart. Valid options are "plot", "html" and "table"
#' @export

chartsRenderStaticUI <- function(id, type){
  ns <- NS(id)
  if(type=="plot"){
    plotOutput(ns("staticPlot"))
  } else if(type=="html"){
    htmlOutput(ns("staticHTML"))
  } else if(type=="table"){
    DT::dataTableOutput(ns("staticTable"))
  } else if(type == "rtf") {
    div(
      downloadButton(ns("downloadRTF"), "Download RTF"),
      DT::dataTableOutput(ns("rtfTable"))
    )
    
  }
  
}

#' @title  Charts Module - render static chart server
#' @description  server for the display of the loaded data  
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param chartFunction function to generate the chart.
#' @param params parameters to be passed to the widget (Reactive)
#' @param type output type for the chart. Valid options are "plot", "html" and "table"
#'
#' @export

chartsRenderStatic <- function(input, output, session, chartFunction, params, type){
  ns <- session$ns
  if(type=="plot"){
    output[["staticPlot"]] <- renderPlot(do.call(chartFunction,params())) 
  }else if(type=="html"){
    output[["staticHTML"]] <- renderText(do.call(chartFunction,params())) 
  }else if(type=="table"){
    output[["staticTable"]] <- DT::renderDataTable(do.call(chartFunction,params()), rownames = FALSE,
                                                   options = list(pageLength = 20,
                                                                  ordering = FALSE,
                                                                  searching = FALSE)) 
  } else if(type == "rtf") {
    output[["rtfTable"]] <- DT::renderDataTable(do.call(chartFunction,params())$table, rownames = FALSE,
                                                options = list(pageLength = 20,
                                                               ordering = FALSE,
                                                               searching = FALSE)) 
    
    output[["downloadRTF"]] <- downloadHandler(
      filename = "SafetyGraphics.rtf",
      content = function(file) {
        pharmaRTF::write_rtf(do.call(chartFunction,params()), file = file)
      }
    )
  }
}
