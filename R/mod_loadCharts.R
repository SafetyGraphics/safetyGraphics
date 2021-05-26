#' @title   loadChartsUI 
#' @description  UI that helps users pick charts
#'
#' @param id module id
#' @param charts list of charts
#' 
#' @importFrom purrr keep
#' @import magrittr
#' 
#' @export

loadChartsUI <- function(id, charts=makeChartConfig()){ 
    ns <- NS(id)
    labels <- charts %>% map_chr(~paste0(.x$label," (", paste(.x$domain, collapse=", "),")"))
    names(labels)<-NULL
    print(labels)
    checkboxGroupInput(
        ns("chartList"),
        "Choose Charts:",
        choiceNames=labels,
        choiceValues=names(charts),
        selected=names(charts)
    )
}

#' @title   loadCharts
#' @description  server that facilitates selection of charts for safetyGraphicsApp
#'
#' @param domains List of data domains to be loaded

#' @export
loadCharts <- function(input, output, session, charts=makeChartConfig()) {
    reactive({charts %>% purrr::keep(~.x$name %in% input$chartList)})
}

