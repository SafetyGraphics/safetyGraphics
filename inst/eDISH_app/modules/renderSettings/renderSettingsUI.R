
renderSettingsUI <- function(id){
  makeSection <- function(class, label){
    section <- 
      column(6,
        wellPanel(
         class=paste0(class," section"),
         h3(
            label,
            materialSwitch(
              ns(paste0("show_",class)),
             label = "",
              right=TRUE,
              value = TRUE,
              status = "primary"
            )
          ),
          conditionalPanel(
            condition=paste0("input.show_",class), 
            ns=ns, 
            uiOutput(ns(paste0(class,"_ui")))
          )
        )
      )
    return(section)
  }
  ns <- NS(id)
  fluidPage(
    fluidRow(
      column(12,
        class="chartSelect section",
        checkboxGroupInput(
          ns("charts"),
          "Select Chart(s):", 
          choices = c("e-DISH" = "edish"), 
          selected="edish"
        )
      )
    ),
    fluidRow(
      makeSection("data_mapping", "Data Mappings"),
      makeSection("measure_settings", "Measure Settings"),
      makeSection("appearance_settings", "Appearance Settings")
    )
  )
}
