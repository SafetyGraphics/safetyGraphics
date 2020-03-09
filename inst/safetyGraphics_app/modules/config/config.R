# Data and settings configuration module - UI code
#'
#' Workflow:
#'   (1) For a given domain, this module populates a new selection in the Config dropdown. The selection results in a domain-specific
#'     configuration panel with a Data tab (`dataLoad` module) and a Settings tab (`renderSettings` module). 
#'   (2) The initial user-selected dataset and its associated settings and validation statuses are passed to the settings module.
#'   (3) The settings module passes the configured settings, selected charts, and final validation status back to the config module server.
#'   (4) A list of the selected/configured data and settings, along with validation statuses are passed back to the main app.
#'     
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace 
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param metadata A list configured in `global.R` containing the charts, settings, and standards metadata:
#'    `metadata_list <- list(chartsMetadata = chartsMetadata,
#'                      settingsMetadata = settingsMetadata,
#'                      standardsMetadata = standardsMetadata)`
#' @param domain Which data domain should the module be customized for? Example: "labs"
#' @param preload_data_list Named list of data.frames configured in `global.R` to be pre-loaded into the app. 
#'   Named according to data domain. Contains information about associated data standard and display specifications.
#'
#' @return List of reactives containing the user-selected dataset (a data.frame), 
#'     customized settings (a list), and selected charts/validation statuses (a named logical vector).
config <- function(input, output, session, metadata, domain, preload_data_list){

  ns <- session$ns
  
  # filter the metadata
  metadata <- metadata 
  settingsMetadata <- filter(metadata$settingsMetadata, domain==!!domain)
  chartsMetadata <- filter(metadata$chartsMetadata, domain==!!domain)
  standardsMetadata <- filter(metadata$standardsMetadata, domain==!!domain)
  domain_charts <- chartsMetadata$chart
  names(domain_charts) <- chartsMetadata$label
  

  ##############################################################
  # initialize dataUpload module
  #
  #  returns selected dataset, settings, and validation status
  ##############################################################
  dataUpload_out <- callModule(dataUpload, "datatab", domain=domain, 
                               preload_data_list = preload_data_list[[domain]])

  ##############################################################
  # Initialize Settings Module
  #
  # generate settings page based on selected data set & generated/selected settings obj
  #
  #  NOTE:  module is being triggered when selected dataset changes OR when settings list changes
  #   this could cause the module to trigger twice unecessarily in some cases because the settings are generated
  #   AFTER the data is changed.
  #
  # returns updated settings and validation status
  ##############################################################

settings_new <-   callModule(
    renderSettings,
    "settingsUI",
    data = reactive(dataUpload_out$data_selected()),
    settings = reactive(dataUpload_out$settings()),
    status = reactive(dataUpload_out$status()),
    metadata=settingsMetadata,
    charts = domain_charts
  )
  
  
  
  return(list(data = reactive(dataUpload_out$data_selected()),
              settings = reactive(settings_new$settings()),
              charts = reactive(settings_new$charts())))
  
}

