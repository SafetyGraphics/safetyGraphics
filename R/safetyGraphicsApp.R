#' Run the interactive safety graphics builder
#'
#' @param charts Character vector of charts to include
#' @param maxFileSize maximum file size in MB allowed for file upload
#' @param settingsLocation folder location of user-defined settings metadata. Files should be named settingsMetadata.rda, chartsMetadata.rda and standardsMetadata.rda and use the same structure established in the /data folder.
#' @param customSettings Name of R script containing settings customizations to be run before the app is initialized. This is the recommended way to add additional charts (via addChart()), settings (addSetting()) and data standards (addStandard()). default = 'settingsLocation/customSettings.R'
#' @param loadData Option to pre-load data into the app. Defaults to \code{FALSE}.
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
safetyGraphicsApp <- function(charts = NULL, maxFileSize = NULL,
                              settingsLocation = ".",  
                              customSettings="customSettings.R", 
                              loadData=FALSE) {


  # pass charts to include
  shiny::shinyOptions(safetygraphics_charts = charts)

  # pass user defined metadata location
  shiny::shinyOptions(settings_location = settingsLocation)

  #increase maximum file upload limit
  if(!is.null(maxFileSize)){
    options(shiny.maxRequestSize=(maxFileSize*1024^2))
  }

  # run the custom settings file (if it exists)
  customSettingsScript<-file.path(settingsLocation, customSettings) #,sep="/")

  if(file.exists(customSettingsScript)){
    source(customSettingsScript)
  }

  chartsMetaPath <- file.path(settingsLocation,"chartsMetadata.Rds") #,sep="/")
  if(file.exists(chartsMetaPath)){
    options(sg_chartsMetadata=TRUE)
    options(sg_chartsMetadata_df=readRDS(chartsMetaPath))

  } else {
    options(sg_chartsMetadata=FALSE)
    options(sg_chartsMetadata_df=NULL)

  }

  settingsMetaPath <- file.path(settingsLocation,"settingsMetadata.Rds") #,sep="/")
  if(file.exists(settingsMetaPath)){
    options(sg_settingsMetadata=TRUE)
    options(sg_settingsMetadata_df=readRDS(settingsMetaPath))
  } else {
    options(sg_settingsMetadata=FALSE)
    options(sg_settingsMetadata_df=NULL)
  }

  standardsMetaPath <- file.path(settingsLocation,"standardsMetadata.Rds") #,sep="/")
  if(file.exists(standardsMetaPath)){
    options(sg_standardsMetadata=TRUE)
    options(sg_standardsMetadata_df=readRDS(standardsMetaPath))
  } else {
    options(sg_standardsMetadata=FALSE)
    options(sg_standardsMetadata_df=NULL)
  }
  
  # pre-load data into app
  if (loadData){
    shiny::shinyOptions(sg_loadData=TRUE)
  } else {
    shiny::shinyOptions(sg_loadData=FALSE)
  }

  path <- system.file("safetyGraphics_app", package = "safetyGraphics")
  shiny::runApp(path, launch.browser = TRUE)
}
