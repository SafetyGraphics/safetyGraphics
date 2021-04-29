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
    if(hasName(chart,"links")){
        links<-purrr::map2(
            chart$links, 
            names(chart$links), 
            ~a(
                .y, 
                href=.x,
                class="chart-link"
            )
        )
        links<-div(tags$small("Links"), links, class="pull-right")

    }else{
        links<-NULL
    }
    
    labelDiv<-div(tags$small("Chart"),chart$label)
    typeDiv<-div(tags$small("Type"), chart$type)
    dataDiv<-div(tags$small("Data Domain"), chart$domain)
    header<-div(
        labelDiv,
        typeDiv,
        dataDiv, 
        links,
        class="chart-header"
    )

    chartWrap <- NULL
    if(tolower(chart$type=="module")){
        #render the module UI
        chartWrap <- chartsRenderModuleUI(id=ns("wrap"), chart$functions[[chart$workflow$ui]])
    }else if(tolower(chart$type=="htmlwidget")){
        #render the widget 
        chartWrap<-chartsRenderWidgetUI(id=ns("wrap"),chart=chart$name, package=chart$package)
    }else{
        #create the static or plotly chart
        chartWrap<-chartsRenderStaticUI(id=ns("wrap"), type=chart$type)
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
    
    params <- reactive({
        #convert settings from data frame to list and subset to specified domain (if any)
        settingsList <-  safetyGraphics::generateMappingList(mapping(), domain=chart$domain)

        #subset data to specific domain (if specified)
        if(chart$domain=="multiple"){
            domainData <- data()
        }else{
            domainData<- data()[[chart$domain]]
        }
        params <- list(data=domainData, settings=settingsList)

        #customize initial the parameters if desired - otherwise pass through domain level data and mapping)
        if(utils::hasName(chart,"functions")){
            if(utils::hasName(chart$workflow,"init")){
                message(chart$name, " has an init.")
                print(chart$functions[chart$workflow$init])
                params <- do.call(chart$functions[[chart$workflow$init]], params)
            }
        }
        return(params)
    })

    if(tolower(chart$type=="module")){
        #render the module UI
        message("chartsTab() is initializing a module at ", ns("wrap"))
        serverFunction <- chart$functions[[chart$workflow$server]]
        callModule(
            module=chartsRenderModule,
            id="wrap",
            serverFunction=serverFunction,
            params=params
        )
    }else if(tolower(chart$type=="htmlwidget")){
        message("chartsTab() is initializing a widget at ", ns("wrap"))
        message("chart is ", chart$name, "; package is ", chart$package)
        callModule(
            module=chartsRenderWidget,
            id="wrap",
            chart=chart$name,
            package=chart$package,
            params=params
        )
    }else{
        #create the static or plotly chart
        chartFunction <- chart$functions[[chart$workflow$main]]
        callModule(
            module=chartsRenderStatic,
            id="wrap",
            chartFunction=chartFunction,
            params=params, 
            type=chart$type
        )
    }
}
