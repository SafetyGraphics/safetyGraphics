#' Render Settings module - UI code
#' 
#' This module creates the Settings tab for the Shiny app. The UI is dynamically populated from the server side. 
#' 
#' The UI contains:
#' - Chart selector 
#' - Settings customizations for the selected charts:
#'      - Data mapping
#'      - Measure settings
#'      - Appearance settings
#'
#' @param id The module-specific ID that will get pre-pended to all element IDs
#'
#' @return The UI for the Settings tab
#'
renderSettingsUI <- function(id){
  
  ns <- NS(id)
  
  tagList(
    verticalLayout(
      fluidRow(
        column(4,
               wellPanel(
                 div(
                   span(h2(tags$strong("Select Chart(s):"))),
                   checkboxGroupInput(ns("charts"),"", 
                                      choices = c("e-DISH" = "edish"), 
                                      selected="edish")) 
               )
        )
      ),
      fluidRow(
        column(4,
               tags$hr()
               )
        ),
      fluidRow(
        column(4,
               h2(tags$strong("Customize Settings:"))
               ) 
        ),
      fluidRow(
        column(4,
               div(
                 div(style="display: inline-block;", h3(tags$i("Data Mapping"))),
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
        column(4,  
               div(
                 div(style="display: inline-block;", h3(tags$i("Measure Settings"))),
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
                 div(style="display: inline-block;", h3(tags$i("Appearance Settings"))),
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
