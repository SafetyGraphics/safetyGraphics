#' @title   loadChartsUI 
#' @description  UI that helps users pick charts
#'
#' @param id module id
#' @param charts list of charts
#' 
#' @importFrom purrr keep
#' @import magrittr
#' @importFrom sortable bucket_list
#' 
#' @export

loadChartsUI <- function(id, charts=makeChartConfig()){ 
    ns <- NS(id)
    labels <- charts%>%map(~makeChartSummary(.x,showLinks=FALSE,class="chartObj"))
    div(
        h4(textOutput(ns("chartSummary"))),
        sortable::bucket_list(
            header = "Select and Order Active Charts",
            group_name = ns("chartList"),
            orientation = "horizontal",
            add_rank_list(
                text = "Active Charts",
                labels = labels,
                input_id = ns("active")
            ),
            add_rank_list(
                text = "Inactive Charts",
                labels = NULL,
                input_id = ns("inactive")
            )
        )
    )

}

#' @title   loadCharts
#' @description  server that facilitates selection of charts for safetyGraphicsApp
#'
#' @param domains List of data domains to be loaded

#' @export
loadCharts <- function(input, output, session, charts=makeChartConfig()) {
    chartNamesR <- reactive({
        charts %>% map_chr(~paste0(.x$label," (", paste(.x$domain, collapse=", "),")"))
    }) 
    chartsR<-reactive({
        print(input$active)
        charts %>% purrr::keep(~.x$name %in% input$active)
    })
    domains <- reactive({unique(chartsR() %>% map(~.x$domain) %>% unlist())})
    output$chartSummary <- renderText({
        paste(length(chartsR())," Charts from ",length(domains())," domains selected.")
    })
    return(chartsR)
}