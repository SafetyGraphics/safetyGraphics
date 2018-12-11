#' Run the interactive safety chart builder
#'
#' @export
chartBuilderApp <- function() {
  path <- system.file("eDISH_app", package = "safetyGraphics")
  shiny::runApp(path, launch.browser = TRUE)
  
}
