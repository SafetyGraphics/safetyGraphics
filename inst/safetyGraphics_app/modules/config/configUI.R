# Data and settings configuration module - UI code
#'
#' @param id The module-specific ID that will get pre-pended to all element IDs
#'
#' @return The UI for the data and settings configuration. Generated once per domain and nested within the "Config" dropdown. Contains
#' `dataUpload` and `renderSettings` module UIs nested within.
configUI <- function(id){
  
  ns <- NS(id)
  tagList(
    tabsetPanel(
      tabPanel(
        title = "Data",
        dataUploadUI(ns("datatab"))
      ) ,
      tabPanel(
        title = "Settings",
        fluidPage(
          renderSettingsUI(ns("settingsUI"))
        )
      )
    )

  )
}

