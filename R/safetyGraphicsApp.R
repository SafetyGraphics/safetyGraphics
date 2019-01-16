#' Run the interactive safety graphics builder
#'
#' @importFrom shiny runApp
#' @import shinyjs
#' @import dplyr
#' @import DT
#' @importFrom purrr map keep
#' @importFrom magrittr "%>%"
#' @import rmarkdown 
#'
#' @export
#'
safetyGraphicsApp <- function() {
  path <- system.file("eDISH_app", package = "safetyGraphics")
  shiny::runApp(path, launch.browser = TRUE)
}
