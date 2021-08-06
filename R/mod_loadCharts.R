#' @title   loadChartsUI 
#' @description  UI that helps users pick charts
#'
#' @param id module id
#' @param charts list of charts
#' 
#' @importFrom purrr keep
#' @importFrom sortable bucket_list add_rank_list
#' 
#' @export

loadChartsUI <- function(id, charts=makeChartConfig()){ 
    ns <- NS(id)
    inactive <- charts%>%keep(~.x$order < 1)%>%map(~makeChartSummary(.x,showLinks=FALSE,class="chart-sortable"))
    active <- charts%>%keep(~.x$order >= 1)%>%map(~makeChartSummary(.x,showLinks=FALSE,class="chart-sortable"))

    div(
        sortable::bucket_list(
            header = h4("Chart Loader"),
            group_name = ns("chartList"),
            orientation = "horizontal",
            add_rank_list(
                text = "Active Charts",
                labels = active,
                input_id = ns("active")
            ),
            add_rank_list(
                text = "Inactive Charts",
                labels = inactive,
                input_id = ns("inactive")
            )
        )
    )

}

#' @title   loadCharts
#' @description  server that facilitates selection of charts for safetyGraphicsApp
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param charts Initial list of charts

#' @export
loadCharts <- function(input, output, session, charts=makeChartConfig()) {
    chartsR<-reactive({
        charts %>% 
            purrr::keep(~.x$name %in% input$active) %>%
            map(function(chart){
                chart$order <- match(chart$name, input$active)
                return(chart)
            })
    })
    return(chartsR)
}