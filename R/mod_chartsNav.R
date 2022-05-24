#' Adds a navbar tab that initializes the Chart Module UI
#'
#' @param id
#' @param chart  chart metadata 
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
#' @param chart chart metadata 
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