#' Add a navbar tab that initializes the Chart Module UI
#'
#' @param chart  chart metadata 
#' 
#' @export
#' 

chartsNav <- function(chart, label, package, type){
    print(chart)
    print(package)
    #chart$chartFunction <- NULL
    #chart$initFunction <- NULL 
    appendTab(
        inputId = "nav_id",
        menuName = "Charts",
        tab = tabPanel(
            title = label, 
            value = chart, 
            chartsTabUI(
                chart,
                chart=chart,
                package=package,
                label=label,
                type=type
            )
        )
    )
}