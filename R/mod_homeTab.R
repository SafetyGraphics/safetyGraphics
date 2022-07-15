#' @title UI for the home module
#'
#' @param id module id
#'
#' @export

homeTabUI <- function(id) {
  ns <- NS(id)
  fluidRow(
    column(width = 9, style = "font-size:20px", uiOutput(outputId = ns("about"))),
    column(width = 3, imageOutput(outputId = ns("hex")))
  )
}

#' @title Server for the filter module in datamods::filter_data_ui
#'
#' @param input mod input
#' @param output mod output
#' @param session mod session
#'
#' @export

homeTab <- function(input, output, session, config) {
  ns <- session$ns

  output$about <- renderUI({
    HTML(readLines(config$homeTabPath))
  })

  output$hex <- renderImage(
    {
      list(
        src = config$hexPath,
        width = "100%"
      )
    },
    deleteFile = FALSE
  )
}
