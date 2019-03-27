
renderSettingsUI <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      column(12,
        class="chartSelect section",
        checkboxGroupInput(
          ns("charts"),
          "Select Chart(s):", 
          choices = c("e-DISH" = "edish",
                      "Safety Histogram" = "safetyhistogram"), 
          selected=c("edish", "safetyhistogram")
        )
      )
    ),
    #TODO - make this a loop based on metadata
    fluidRow(
      createSettingsSection("data_mapping", "Data Mappings",6,ns),
      createSettingsSection("measure_settings", "Measure Settings",6,ns),
      createSettingsSection("appearance_settings", "Appearance Settings",6,ns)
    )
  )
}
