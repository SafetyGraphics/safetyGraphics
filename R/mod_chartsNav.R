#' Adds a navbar tab that initializes the Chart Module UI
#'
#' @param chart  chart metadata 
#' @param ns namespace
#' 
#' @export 
#' 

chartsNav <- function(chart,ns){
    appendTab(
        inputId = "safetyGraphicsApp",
        menuName = "Charts",
        tab = tabPanel(
            title = makeChartSummary(chart, showLinks=FALSE, class="chart-nav"), 
            value = chart$name, 
            chartsTabUI(
                id=ns(chart$name),
                chart=chart
            )
        )
    )
}