# UI Code for safetyGraphics App
mainUI <- function(id){
  
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
      ),
      navbarMenu(ns("Charts")),
      tabPanel(
        title = "Reports",
        fluidPage(
          renderReportsUI(ns("reportsUI"))
        )
      )
    )
 # )
  )
}
#)
