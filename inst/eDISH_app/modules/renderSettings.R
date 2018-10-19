renderSettingsUI <- function(id){
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      splitLayout(
        tagList(
          wellPanel(
            fluidRow(
              column(6,  
                     h3("Data Mapping"),
                     selectInput(ns("id_col"),"Unique subject identifier", choices = NULL),
                     selectInput(ns("value_col"),"Lab result", choices = NULL),
                     selectInput(ns("measure_col"),"Lab measure", choices = NULL),
                     h4("Key measures"),
                     selectInput(ns("ALT"),"ALT", choices = NULL),
                     selectInput(ns("AST"),"AST", choices = NULL),
                     selectInput(ns("TB"),"TB", choices = NULL),
                     selectInput(ns("ALP"),"ALP", choices = NULL)
              ) ,
              column(6,
                     br(),
                     br(),
                     br(),
                     selectInput(ns("normal_col_low"),"Lower limit of normal", choices = NULL),
                     selectInput(ns("normal_col_high"),"Upper limit of normal", choices = NULL),
                     selectInput(ns("visit_col"),"Visit", choices = NULL),
                     selectInput(ns("visitn_col"),"Visit number", choices = NULL),
                     # selectInput("studyday_col","studyday_col", choices = NULL),
                     selectInput(ns("baseline_visitn"),"Baseline visit number", choices = NULL)#,
                     #  selectInput("anlyFlag","anlyFlag", choices = NULL)
                     #,
                     #selectInput("measure_values","Measure values", choices = NULL)
                     
              )))),
        tagList(
          column(6, 
                 wellPanel(
                   h3("Measure Settings"),
                   selectInput(ns("filters"),"Filters", choices = NULL, multiple = TRUE),
                   selectInput(ns("group_cols"),"Group columns", choices = NULL, multiple = TRUE),
                   selectInput(ns("x_options"),"x_options", choices = c("ALT", "AST", "ALP"), selected = c("ALT", "AST", "ALP"), multiple = TRUE),
                   selectInput(ns("y_options"),"y_options", choices = c("ALT", "AST", "ALP"), selected = c("TB","ALP"), multiple = TRUE)
                 )
          ),
          column(6, 
                 wellPanel(
                   h3("Appearance Settings"),
                   sliderInput(ns("visit_window"),"visit_window", value = 30, min=0, max=50),
                   checkboxInput(ns("r_ratio_filter"),"r_ratio_filter", value = TRUE),
                   conditionalPanel(
                     condition="input.r_ratio_filter==true", ns=ns,
                     sliderInput(ns("r_ratio_cut"),"r_ratio_cut", value = 0, min=0, max =1)
                   ),
                   checkboxInput(ns("showTitle"),"showTitle", value = TRUE),
                   textAreaInput (ns("warningText"),"warningText", 
                                  value = "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures.")
                 )
          )))
    )
  )
}


renderSettings <- function(input, output, session, data, standard, settings, gsButton){
  
  ns <- session$ns
  
  colnames <- names(data())
  settings <- settings()
  keys <- unique(data()[,settings$measure_col]) 
  
  updateSelectInput(session, "id_col", choices = unique(c(settings$id_col,colnames)))
  updateSelectInput(session, "value_col", choices = unique(c(settings$value_col,colnames)))
  updateSelectInput(session, "measure_col", choices = unique(c(settings$measure_col,colnames)))
  updateSelectInput(session, "ALT", choices = keys, selected = keys[1])
  updateSelectInput(session, "AST", choices = keys, selected = keys[2])
  updateSelectInput(session, "TB", choices = keys, selected = keys[3])
  updateSelectInput(session, "ALP", choices = keys, selected = keys[4])
  
  updateSelectInput(session, "normal_col_low", choices = unique(c(settings$normal_col_low,colnames)))
  updateSelectInput(session, "normal_col_high", choices = unique(c(settings$normal_col_high,colnames)))
  updateSelectInput(session, "visit_col", choices = unique(c(settings$visit_col,colnames)))
  updateSelectInput(session, "visitn_col", choices = unique(c(settings$visitn_col,colnames)))
  updateSelectInput(session, "studyday_col", selected = NULL)
  updateSelectInput(session, "baseline_visitn", selected = 1, choices = unique(data()$VISITNUM))
  updateSelectInput(session, "anlyFlag", selected = NULL)
  updateSelectInput(session, "measure_values", selected = NULL)
  updateSelectInput(session, "filters", selected = NULL, choices = colnames)
  updateSelectInput(session, "group_cols", selected = NULL, choices = colnames)
   
  ### return all inputs from module to be used in global env.
  return(reactive(input))  
}