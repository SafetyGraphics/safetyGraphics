#' Run the interactive safety chart builder
#'
#' @import shiny
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
