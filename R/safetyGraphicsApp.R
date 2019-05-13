#' Run the interactive safety graphics builder
#'
#' @param charts Character vector of charts to include 
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
#' @importFrom shinyWidgets materialSwitch
#'
#' @export
#'
safetyGraphicsApp <- function(charts = NULL, maxFileSize = NULL) {
  
  # pass charts to include
  shinyOptions(safetygraphics_charts = charts)
  
  #increase maximum file upload limit
  if(!is.null(maxFileSize)){
    options(shiny.maxRequestSize=(maxFileSize*1024^2))  
  }
  
  path <- system.file("safetyGraphics_app", package = "safetyGraphics")
  shiny::runApp(path, launch.browser = TRUE)
}
