#' Render eDISH chart - server code
#'
#' This module creates the Chart tab for the Shiny app, which contains the interactive eDISH graphic.
#'
#' Workflow:
#' (1) A change in `data`, `settings`, or `valid` invalidates the eDISH chart output
#' (2) Upon a change in `valid`, the export chart functionality is conditionally made available or unavailable to user
#' (3) If "export chart" button is pressed, data and settings are passed to the parameterized report, knitted using
#'     Rmarkdown, and downloaded to user computer.
#'
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param data A data frame  [REACTIVE]
#' @param settings list of settings arguments for chart [REACTIVE]
#' @param chart name of chart to be rendered [STRING]
#' @param type type of chart (e.g. "htmlwidget")
#' @param valid A logical indicating whether data/settings combination is valid for chart [REACTIVE]

renderChart <- function(input, output, session, data, settings, valid, chart, type){

  ns <- session$ns

  # function for chart
  chart_fun <- match.fun(chart)
  # function for shiny output
  output_fun <- match.fun(paste0("output_", chart))
  # function for shiny render
  render_fun <- match.fun(paste0("render_", chart))
  # id for chart
  chart_id <- paste0("chart_", chart)

  # # render eDISH chart if settings pass validation
  # output$chart <- renderEDISH({
  #   req(data())
  #   req(settings())
  #
  #     trimmed_data <- safetyGraphics:::trimData(data = data(), settings = settings())
  #     eDISH(data = trimmed_data, settings = settings())
  #
  # })
  #

  ## code to dynamically generate the output location
  output$chart <- renderUI({
    output_fun(ns(chart_id))
  })

  ## code to render widget and fill in the output location
  output[[chart_id]] <- render_fun({
    req(data())
    req(settings())

    trimmed_data <- safetyGraphics:::trimData(data = data(), settings = settings())
    chart_fun(data = trimmed_data, settings = settings())
  })

}
