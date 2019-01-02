#' Run the interactive safety chart builder
#'
#' @importFrom shiny runApp
#' @import shinyjs
#' @import dplyr
#' @import DT
#' @importFrom purrr map keep
#' @importFrom magrittr "%>%"
#'
#' @export
#'
chartBuilderApp <- function() {
  path <- system.file("eDISH_app", package = "safetyGraphics")
  shiny::runApp(path, launch.browser = TRUE)
}
