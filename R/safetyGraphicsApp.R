#' Run the interactive safety graphics builder
#'
#' @param charts Character vector of charts to include 
#' @param maxFileSize maximum file size in MB allowed for file upload
#' @param settingsLocation folder location of user-defined settings metadata
#'
#' @importFrom shiny runApp shinyOptions
#' @import shinyjs
#' @import dplyr
#' @import DT
#' @importFrom purrr map keep
#' @importFrom magrittr "%>%"
#' @import rmarkdown 
#' @importFrom haven read_sas
#' @importFrom shinyWidgets materialSwitch
#' @importFrom tidyr gather
#'
#' @export
#'
safetyGraphicsApp <- function(charts = NULL, maxFileSize = NULL, settingsLocation = NULL) {
  
  # pass charts to include
  shiny::shinyOptions(safetygraphics_charts = charts)
  
  # pass user defined metadata location
  shiny::shinyOptions(settings_location = settingsLocation)
  
  #increase maximum file upload limit
  if(!is.null(maxFileSize)){
    options(shiny.maxRequestSize=(maxFileSize*1024^2))  
  }
  
  path <- system.file("safetyGraphics_app", package = "safetyGraphics")
  shiny::runApp(path, launch.browser = TRUE)
}
