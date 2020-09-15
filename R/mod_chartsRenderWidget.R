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
#' @param initFunction Function called before the chart is generated. The function should take `data` and `settings` as inputs and return `params` which should be a list which is then provided to the widget. If domain is specified, only domain-level information is passed to the init function, otherwise named lists containing information for all domains is provided. The mapping is parsed as a list using `generateMappingList()` before being passed to the init function.  By default, init returns an unmodified list of data and settings (possibly subset to the specified domain) e.g. - list(data=data, settings=settings). 
#' @param domain data domain. NULL by default.  
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
        
        #convert settings from data frame to list and subset to specified domain (if any)
        settingsList <-  safetyGraphics::generateMappingList(mapping(), domain=domain)
        
        #subset data to specific domain (if specified)
        if(!is.null(domain)){
            domainData <- data()[[domain]]
        }else{
            domainData<- data()
        }
        
        #customize initial the parameters if desired - otherwise pass through domain level data and mapping)
        params <- initFunction(data=domainData, settings=settingsList)
        
        #convert list of parameters to json - subset to specific domain if specified
        params$settings <- jsonlite::toJSON(
            params$settings,
            auto_unbox = TRUE,
            null = "null",  
        )
        params$ns <- ns("widgetChart")
        print(params)
        return(params)
    })

    # shiny render function for a widget named 'foo'
    output[["widgetChart"]] <- renderWidget({
        print(widgetName)
        htmlwidgets::createWidget(
            name = widgetName,
            params(),
            package = widgetPackage,
            sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE),     
       )
    })
}
