
renderSettingsUI <- function(id){
  
  ns <- NS(id)
  
  tagList(
    verticalLayout(
      wellPanel(
        class="chartSelect section",
        h2("Select Chart(s):"),
        checkboxGroupInput(
          ns("charts"),
          "", 
          choices = c("e-DISH" = "edish"), 
          selected="edish"
        )
      ),
      wellPanel(
        class="dataMapping section",
        h3("Data Mapping"),
        materialSwitch(
            ns("show_data_mapping"),
            label = "",
            right=TRUE,
            value = TRUE,
            status = "primary"
        ),
        conditionalPanel(
          condition="input.show_data_mapping", 
          ns=ns, 
          uiOutput(ns("data_mapping_ui"))
        )
      ),
      wellPanel(
        class="measureSettings section",
        h3(
          materialSwitch(
            ns("show_measure_settings"),
            label = "Measure Settings",
            right=TRUE,
            value = TRUE,
            status = "primary"
          )
        ),
        conditionalPanel(
          condition="input.show_measure_settings", 
          ns=ns, 
          uiOutput(ns("measure_settings_ui"))
        )
      ),
      wellPanel(
        class="appearanceSettings section",
        h3(
          materialSwitch(
            ns("show_appearance_settings"),
            label = "Appearance Settings",
            right=TRUE,
            value = TRUE,
            status = "primary"
          )
        ),
        conditionalPanel(
          condition="input.show_appearance_settings", 
          ns=ns, 
          uiOutput(ns("appearance_settings_ui"))
        )
      )
    )
  )
}
