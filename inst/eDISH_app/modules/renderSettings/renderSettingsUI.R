
renderSettingsUI <- function(id){
  ns <- NS(id)
  #TODO - make this a loop based on metadata
  fluidRow(
    createSettingsSection("charts_wrap", "Charts",12,ns),
    createSettingsSection("data_mapping", "Data Mappings",6,ns),
    createSettingsSection("measure_settings", "Measure Settings",6,ns),
    createSettingsSection("appearance_settings", "Appearance Settings",6,ns)
  )
}
