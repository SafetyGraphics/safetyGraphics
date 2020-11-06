#' Add a navbar tab that initializes the Chart Module UI
#'
#' @param chart  chart metadata 
#' 
#' @export
#' 

chartsNav <- function(name, label, type, package){
    #chart$chartFunction <- NULL
    #chart$initFunction <- NULL 
    appendTab(
        inputId = "safetyGraphicsApp",
        menuName = "Charts",
        tab = tabPanel(
            title = label, 
            value = name, 
            chartsTabUI(
                id=name,
                name=name,
                package=package,
                label=label,
                type=type
            )
        )
    )
}