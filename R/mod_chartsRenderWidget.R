#' @title Charts Module - render static chart UI
#' @description  Charts Module - sub module for rendering a static chart
#' 
#' @param id module id
#' @param chart chart name - must match the name of a widget in the specified pacakge
#' @param package pacakge containing the widget
#' 
#' @export

chartsRenderWidgetUI <- function(id, chart, package){

    # shiny output binding for a widget named 'foo'
    widgetOutput <- function(outputId, width = "100%", height = "400px") {
        htmlwidgets::shinyWidgetOutput(outputId, chart, width, height, package=package)
    }
    ns <- NS(id)
    widgetOutput(ns("widgetChart"))
}

#' @title  Charts Module - render static chart server
#' @description  server for the display of the loaded data  
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param chart chart name - must match the name of a widget in the specified pacakge
#' @param package package containing the widget. Note that package name is required for htmlwidgets. 
#' @param params parameters to be passed to the widget [REACTIVE]
#' @param settingsToJSON convert param$settings to json? Default = TRUE
#'
#' @export

chartsRenderWidget <- function(
    input, 
    output, 
    session,
    chart, 
    package, 
    params, 
    settingsToJSON=TRUE
){
    ns <- session$ns

    
    # shiny output binding
    widgetOutput <- function(outputId, width = "100%", height = "400px") {
        htmlwidgets::shinyWidgetOutput(outputId, chart, width, height, package=package)
    }

    # shiny render function for a widget
    renderWidget <- function(expr, env = parent.frame(), quoted = FALSE) {
        if (!quoted) { expr <- substitute(expr) } # force quoted
        htmlwidgets::shinyRenderWidget(expr, widgetOutput, env, quoted = TRUE)
    }

    widgetParams <- reactive({
        widgetParams<-params()
        if(settingsToJSON){
            widgetParams$settings <- jsonlite::toJSON(
                widgetParams$settings,
                auto_unbox = TRUE,
                null = "null",  
            )
        }
        widgetParams$ns <- ns("widgetChart")
        return(widgetParams)
    })

    # shiny render function for the widget 
    output[["widgetChart"]] <- renderWidget({
        htmlwidgets::createWidget(
            name = chart,
            widgetParams(),
            package = package,
            sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE),     
       )
    })
}
