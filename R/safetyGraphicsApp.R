#' Run the interactive safety graphics builder
#'
#' @param charts Character vector of charts to include 
#' @param maxFileSize maximum file size in MB allowed for file upload
#' @param settingsLocation folder location of user-defined settings metadata. Files should be named settingsMetadata.rda, chartsMetadata.rda and standardsMetadata.rda and use the same structure established in the /data folder. 
#' @param customSettings Name of R script containing settings customizations to be run before the app is initialized. This is the recommended way to add additional charts (via addChart()), settings (addSetting()) and data standards (addStandard()). default = 'settingsLocation/customSettings.R'

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
safetyGraphicsApp <- function(charts = NULL, maxFileSize = NULL, settingsLocation = NULL, customSettings="customSettings.R") {
  
  # pass charts to include
  shiny::shinyOptions(safetygraphics_charts = charts)
  
  # pass user defined metadata location
  shiny::shinyOptions(settings_location = settingsLocation)
  
  #increase maximum file upload limit
  if(!is.null(maxFileSize)){
    options(shiny.maxRequestSize=(maxFileSize*1024^2))  
  }
  
  # run the custom settings file (if it exists)
  customSettingsScript<-paste(settingsLocation, customSettings,sep="/")
  if(file.exists(customSettingsScript)) source(customSettingsScript)
    
  path <- system.file("safetyGraphics_app", package = "safetyGraphics")
  shiny::runApp(path, launch.browser = TRUE)
}
