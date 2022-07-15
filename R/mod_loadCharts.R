#' @title UI for the chart loading module used in safetyGraphicsInit()
#'
#' @param id module id
#' @param charts list containing chart specifications like those returned by \link{makeChartConfig}.
#'
#' @importFrom purrr keep
#' @importFrom sortable bucket_list add_rank_list
#'
#' @export

loadChartsUI <- function(id, charts = makeChartConfig()) {
  ns <- NS(id)
  div(
    h4(
      "Chart Loader",
      actionButton(ns("addCharts"), "Select All", class = "btn-xs"),
      actionButton(ns("removeCharts"), "Remove All", class = "btn-xs")
    ),
    uiOutput(ns("chartLists"))
  )
}

#' @title Server for the chart loading module used in safetyGraphicsInit()
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param charts list containing chart specifications like those returned by \link{makeChartConfig}.
#'
#' @export

loadCharts <- function(input, output, session, charts = makeChartConfig()) {
  ns <- session$ns
  labels <- charts %>% map(~ makeChartSummary(.x, showLinks = FALSE, class = "chart-sortable"))
  rv <- reactiveValues(
    inactive = charts %>% keep(~ .x$order < 1) %>% map(~ makeChartSummary(.x, showLinks = FALSE, class = "chart-sortable")),
    active = charts %>% keep(~ .x$order >= 1) %>% map(~ makeChartSummary(.x, showLinks = FALSE, class = "chart-sortable"))
  )
  output$chartLists <- renderUI({
    div(
      sortable::bucket_list(
        header = NULL,
        group_name = ns("chartList"),
        orientation = "horizontal",
        add_rank_list(
          text = "Active Charts",
          labels = rv$active,
          input_id = ns("active")
        ),
        add_rank_list(
          text = "Inactive Charts",
          labels = rv$inactive,
          input_id = ns("inactive")
        )
      )
    )
  })

  # Sync input and reactiveValues
  observeEvent(input$active, {
    rv$active <- charts %>%
      purrr::keep(~ .x$name %in% input$active) %>%
      map(~ makeChartSummary(.x, showLinks = FALSE, class = "chart-sortable"))
    rv$inactive <- charts %>%
      purrr::keep(~ .x$name %in% input$inactive) %>%
      map(~ makeChartSummary(.x, showLinks = FALSE, class = "chart-sortable"))
  })

  observeEvent(input$inactive, {
    rv$active <- charts %>%
      purrr::keep(~ .x$name %in% input$active) %>%
      map(~ makeChartSummary(.x, showLinks = FALSE, class = "chart-sortable"))
    rv$inactive <- charts %>%
      purrr::keep(~ .x$name %in% input$inactive) %>%
      map(~ makeChartSummary(.x, showLinks = FALSE, class = "chart-sortable"))
  })

  # Update reactiveValues/Input on add/remove button clicks
  observeEvent(input$addCharts, {
    rv$active <- labels
    rv$inactive <- NULL
  })

  observeEvent(input$removeCharts, {
    rv$active <- NULL
    rv$inactive <- labels
  })
  chartsR <- reactive({
    charts %>%
      purrr::keep(~ .x$name %in% input$active) %>%
      map(function(chart) {
        chart$order <- match(chart$name, input$active)
        return(chart)
      })
  })
  return(chartsR)
}
