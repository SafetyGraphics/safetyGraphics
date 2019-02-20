
renderSettingsUI <- function(id){
  
  ns <- NS(id)
  
  tagList(
    verticalLayout(
      
      fluidRow(
        column(6,
               div(
                 div(style="display: inline-block;", h3("Data Mapping")),
                 div(style="display: inline-block;", checkboxInput(ns("show_data_mapping"), "show", TRUE))
               )
        )
      ),
      conditionalPanel(condition="input.show_data_mapping", ns=ns, 
                       fluidRow(
                         column(4,    
                                wellPanel( 
                                  uiOutput(ns("data_mapping_ui"))
                                ))
                         
                       ) 
      ),
      
      fluidRow(
        column(6,  
               div(
                 div(style="display: inline-block;", h3("Measure Settings")),
                 div(style="display: inline-block;", checkboxInput(ns("show_measure_settings"), "show", TRUE))
               ) 
        )
      ),
      conditionalPanel(condition="input.show_measure_settings", ns=ns, 
                       fluidRow(
                         column(4,    
                                wellPanel( 
                                  uiOutput(ns("measure_settings_ui"))
 
                                )
                         )
                       )
      ),
      fluidRow(
        column(6,  
               div(
                 div(style="display: inline-block;", h3("Appearance Settings")),
                 div(style="display: inline-block;", checkboxInput(ns("show_appearance_settings"), "show", TRUE))
               )  
        )
      ),
      conditionalPanel(condition="input.show_appearance_settings", ns=ns, 
                       fluidRow(
                         column(4, 
                                wellPanel(
                                  uiOutput(ns("appearance_settings_ui"))
                                )
                         )
                       )
      )
    ))
}
