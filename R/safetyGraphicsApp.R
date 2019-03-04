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
#' @importFrom shinyWidgets materialSwitch
#'
#' @export
#'
safetyGraphicsApp <- function(maxFileSize = NULL) {
  #increase maximum file upload limit
  if(!is.null(maxFileSize)){
    options(shiny.maxRequestSize=(maxFileSize*1024^2))  
  }
  
  path <- system.file("eDISH_app", package = "safetyGraphics")
  shiny::runApp(path, launch.browser = TRUE)
}
