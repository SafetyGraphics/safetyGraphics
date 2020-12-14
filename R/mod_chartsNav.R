#' Add a navbar tab that initializes the Chart Module UI
#'
#' @param chart  chart metadata 
#' 
#' @export
#' 

chartsNav <- function(chart){
    appendTab(
        inputId = "safetyGraphicsApp",
        menuName = "Charts",
        tab = tabPanel(
            title = chart$label, 
            value = chart$name, 
            chartsTabUI(
                id=chart$name,
                chart=chart
            )
        )
    )
}