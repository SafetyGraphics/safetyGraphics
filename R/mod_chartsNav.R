#' Adds a navbar tab that initializes the Chart Module UI
#'
#' @param id module id
#' @param chart chart metadata 
#' 
#' @export 
#' 

chartsNavUI <- function(id, chart){
    ns <- NS(id)
    panel<-tabPanel(
        title = uiOutput(ns("tabTitle")), 
        value = chart$name, 
        chartsTabUI(
            id=ns("chart"),
            chart=chart
        )
    )
    return(panel)
}

#' Server for  a navbar tab 
#'
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param chart list containing a safetyGraphics chart object like those returned by \link{makeChartConfig}.
#' @param data named list of current data sets (Reactive).
#' @param mapping tibble capturing the current data mappings (Reactive).
#' 
#' @export 
#' 

chartsNav<-function(input, output, session, chart, data, mapping){
    chartStatus <- reactive({
        if(hasName(chart, 'dataSpec')){
            status<-getChartStatus(chart, mapping())
        }else{
            status<-NULL
        }
        return(status)
    })    

    ns <- session$ns
    print(paste("running chartsNav() in:", ns('')))
    output$tabTitle <- renderUI({makeChartSummary(chart, status=chartStatus(), showLinks=FALSE, class="chart-nav")})

    callModule(
        module=chartsTab,
        id='chart',
        chart=chart,
        data=data,
        mapping=mapping,
        status=chartStatus
    )
}