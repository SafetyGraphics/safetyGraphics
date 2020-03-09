# UI Code for safetyGraphics App Config pane
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

