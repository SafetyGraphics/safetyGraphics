#' Run the interactive safety graphics builder
#'
#' @param maxFileSize maximum file size in MB allowed for file upload.
#'
#' @importFrom shiny runApp
#' @import shinyjs
#' @import dplyr
#' @import DT
#' @importFrom purrr map keep
#' @importFrom magrittr "%>%"
#' @import rmarkdown 
#' @importFrom haven read_sas
#'
#' @export
#'
safetyGraphicsApp <- function(maxFileSize = 20) {
  #increase maximum file upload limit
  options(shiny.maxRequestSize=(maxFileSize*1024^2))
  
  path <- system.file("eDISH_app", package = "safetyGraphics")
  shiny::runApp(path, launch.browser = TRUE)
}
