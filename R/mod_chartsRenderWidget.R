#' @title Charts Module - render static chart UI
#' @description  Charts Module - sub module for rendering a static chart
#' 
#' @export

chartsRenderWidgetUI <- function(id, widgetName, widgetPackage="safetyGraphics"){

    # shiny output binding for a widget named 'foo'
    widgetOutput <- function(outputId, width = "100%", height = "400px") {
        htmlwidgets::shinyWidgetOutput(outputId, widgetName, width, height, package=widgetPackage)
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
#' @param widgetName str name of the widget
#' @param widgetPackage str package containing the widget
#' @param initFunction function called before the chart is generated. Should return a list of parameters that will be provided to chartFunction. returns list(data=data, settings=settings) by default.
#' @param domain data domain  
#' @param data named list of data sets [reactive]
#' @param mapping data mapping [reactive]
#'
#' @export

chartsRenderWidget <- function(
    input, 
    output, 
    session,
    widgetName, 
    widgetPackage="safetyGraphics", 
    initFunction, 
    domain=NULL, 
    data, 
    mapping
){
    ns <- session$ns

    # shiny output binding
    widgetOutput <- function(outputId, width = "100%", height = "400px") {
        htmlwidgets::shinyWidgetOutput(outputId, widgetName, width, height, package=widgetPackage)
    }

    # shiny render function for a widget
    renderWidget <- function(expr, env = parent.frame(), quoted = FALSE) {
        if (!quoted) { expr <- substitute(expr) } # force quoted
        htmlwidgets::shinyRenderWidget(expr, widgetOutput, env, quoted = TRUE)
    }

    if(missing(initFunction)){
        initFunction <- function(data,settings){return(list(data=data,settings=settings))}
    }

    params <- reactive({
        #initialize the paramaters if specified (otherwise pass through data() and mapping())
        params <- initFunction(data=data(), settings=mapping())
        
        #subset data to specific domain (if specified)
        if(!is.null(domain)){
            params$data <- params$data[[domain]]
        }
        
        #convert list of parameters to json - subset to specific domain if specified
        params$settings <- jsonlite::toJSON(
            safetyGraphics::generateMappingList(params$settings, domain=domain),
            auto_unbox = TRUE,
            null = "null",  
        )
        params$ns <- ns("widgetChart")
        return(params)
    })

    # shiny render function for a widget named 'foo'
    output[["widgetChart"]] <- renderWidget({
        htmlwidgets::createWidget(
            name = widgetName,
            params(),
            package = widgetPackage,
            sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE),     
       )
    })
}
