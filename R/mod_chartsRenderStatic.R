#' @title Charts Module - render static chart UI
#' @description  Charts Module - sub module for rendering a static chart
#' 
#' @export

chartsRenderStaticUI <- function(id, type){
  ns <- NS(id)
  if(type=="plot"){
    plotOutput(ns("staticPlot"))
  } else if(type=="html"){
    htmlOutput(ns("staticHTML"))
  } else if(type=="table"){
    DT::dataTableOutput(ns("staticTable"))
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
  }
}
