
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
                                  div(
                                    span(id = ns("tt_lbl_id_col"), title = "",
                                         tags$label(id = ns("lbl_id_col"), "")),
                                    span(id = ns("tt_msg_id_col"), title = "",
                                         tags$label(id = ns("msg_id_col"), "")),
                                    selectizeInput(ns("id_col"),NULL, choices = NULL)
                                    
                                  ),
                                  
                                  div(
                                    span(id = ns("tt_lbl_value_col"), title = "",
                                         tags$label(id = ns("lbl_value_col"), "")),
                                    span(id = ns("tt_msg_value_col"), title = "",
                                         tags$label(id = ns("msg_value_col"), "")),
                                    selectizeInput(ns("value_col"),NULL, choices = NULL)
                                    
                                  ),
                                  
                                  div(
                                    span(id = ns("tt_lbl_measure_col"), title = "",
                                         tags$label(id = ns("lbl_measure_col"), "")),
                                    span(id = ns("tt_msg_measure_col"), title = "",
                                         tags$label(id = ns("msg_measure_col"), "")),
                                    selectizeInput(ns("measure_col"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_measure_values--ALT"), title = "",
                                         tags$label(id = ns("lbl_measure_values--ALT"), "")),
                                    span(id = ns("tt_msg_measure_values--ALT"), title = "",
                                         tags$label(id = ns("msg_measure_values--ALT"), "")),
                                    selectizeInput(ns("measure_values--ALT"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_measure_values--AST"), title = "",
                                         tags$label(id = ns("lbl_measure_values--AST"), "")),
                                    span(id = ns("tt_msg_measure_values--AST"), title = "",
                                         tags$label(id = ns("msg_measure_values--AST"), "")),
                                    selectizeInput(ns("measure_values--AST"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_measure_values--TB"), title = "",
                                         tags$label(id = ns("lbl_measure_values--TB"), "")),
                                    span(id = ns("tt_msg_measure_values--TB"), title = "",
                                         tags$label(id = ns("msg_measure_values--TB"), "")),
                                    selectizeInput(ns("measure_values--TB"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_measure_values--ALP"), title = "",
                                         tags$label(id = ns("lbl_measure_values--ALP"), "")),
                                    span(id = ns("tt_msg_measure_values--ALP"), title = "",
                                         tags$label(id = ns("msg_measure_values--ALP"), "")),
                                    selectizeInput(ns("measure_values--ALP"),NULL, choices = NULL)
                                  ),
                                  #  ),
                                  div(
                                    span(id = ns("tt_lbl_normal_col_low"), title = "",
                                         tags$label(id = ns("lbl_normal_col_low"), "")),
                                    span(id = ns("tt_msg_normal_col_low"), title = "",
                                         tags$label(id = ns("msg_normal_col_low"), "")),
                                    selectizeInput(ns("normal_col_low"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_normal_col_high"), title = "",
                                         tags$label(id = ns("lbl_normal_col_high"), "")),
                                    span(id = ns("tt_msg_normal_col_high"), title = "",
                                         tags$label(id = ns("msg_normal_col_high"), "")),
                                    selectizeInput(ns("normal_col_high"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_visit_col"), title = "",
                                         tags$label(id = ns("lbl_visit_col"), "")),
                                    span(id = ns("tt_msg_visit_col"), title = "",
                                         tags$label(id = ns("msg_visit_col"), "")),
                                    selectizeInput(ns("visit_col"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_visitn_col"), title = "",
                                         tags$label(id = ns("lbl_visitn_col"), "")),
                                    span(id = ns("tt_msg_visitn_col"), title = "",
                                         tags$label(id = ns("msg_visitn_col"), "")),
                                    selectizeInput(ns("visitn_col"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_studyday_col"), title = "",
                                         tags$label(id = ns("lbl_studyday_col"), "")),
                                    span(id = ns("tt_msg_studyday_col"), title = "",
                                         tags$label(id = ns("msg_studyday_col"), "")),
                                    selectizeInput(ns("studyday_col"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_baseline--value_col"), title = "",
                                         tags$label(id = ns("lbl_baseline--value_col"), "")),
                                    span(id = ns("tt_msg_baseline--value_col"), title = "",
                                         tags$label(id = ns("msg_baseline--value_col"), "")),
                                    selectizeInput(ns("baseline--value_col"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_baseline--values"), title = "",
                                         tags$label(id = ns("lbl_baseline--values"), "")),
                                    span(id = ns("tt_msg_baseline--values"), title = "",
                                         tags$label(id = ns("msg_baseline--values"), "")),
                                    selectizeInput(ns("baseline--values"),NULL, choices = NULL, multiple = TRUE)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_filters"), title = "",
                                         tags$label(id = ns("lbl_filters"), "")),
                                    span(id = ns("tt_msg_filters"), title = "",
                                         tags$label(id = ns("msg_filters"), "")),
                                    selectInput(ns("filters"),NULL, choices = NULL, selected = NULL, multiple = TRUE)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_group_cols"), title = "",
                                         tags$label(id = ns("lbl_group_cols"), "")),
                                    span(id = ns("tt_msg_group_cols"), title = "",
                                         tags$label(id = ns("msg_group_cols"), "")),
                                    selectInput(ns("group_cols"),NULL, choices = NULL, selected = NULL, multiple = TRUE)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_analysisFlag--value_col"), title = "",
                                         tags$label(id = ns("lbl_analysisFlag--value_col"), "")),
                                    span(id = ns("tt_msg_analysisFlag--value_col"), title = "",
                                         tags$label(id = ns("msg_analysisFlag--value_col"), "")),
                                    selectizeInput(ns("analysisFlag--value_col"),NULL, choices = NULL)
                                  ),
                                  div(
                                    span(id = ns("tt_lbl_analysisFlag--values"), title = "",
                                         tags$label(id = ns("lbl_analysisFlag--values"), "")),
                                    span(id = ns("tt_msg_analysisFlag--values"), title = "",
                                         tags$label(id = ns("msg_analysisFlag--values"), "")),
                                    selectizeInput(ns("analysisFlag--values"),NULL, choices = NULL, multiple = TRUE)
                                  )
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
                                  div(
                                    div(id = ns("tt_lbl_x_options"), title = "",
                                        tags$label(id = ns("lbl_x_options"), "")),
                                    selectizeInput(ns("x_options"),NULL, choices = c("ALT", "AST", "ALP","TB"), selected = c("ALT", "AST", "ALP"), multiple=TRUE)
                                  ),
                                  div(
                                    div(id = ns("tt_lbl_y_options"), title = "",
                                        tags$label(id = ns("lbl_y_options"), "")),
                                    selectizeInput(ns("y_options"),NULL, choices = c("ALT", "AST", "ALP","TB"), selected = c("TB"), multiple = TRUE)
                                  )
                                  
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
                                  div(
                                    div(id = ns("tt_lbl_visit_window"), title = "",
                                        tags$label(id = ns("lbl_visit_window"), "")),
                                    sliderInput(ns("visit_window"),NULL, value = 30, min=0, max=50)
                                  ),
                                  div(
                                    div(id = ns("tt_lbl_r_ratio_filter"), title = "",
                                        tags$label(id = ns("lbl_r_ratio_filter"), "")),
                                    checkboxInput(ns("r_ratio_filter"),NULL, value = TRUE)
                                  ),
                                  conditionalPanel(
                                    condition="input.r_ratio_filter==true", ns=ns,
                                    div(
                                      div(id = ns("tt_lbl_r_ratio_cut"), title = "",
                                          tags$label(id = ns("lbl_r_ratio_cut"), "")),
                                      sliderInput(ns("r_ratio_cut"),NULL, value = 0, min=0, max =1)
                                    )
                                  ),
                                  div(
                                    div(id = ns("tt_lbl_showTitle"), title = "",
                                        tags$label(id = ns("lbl_showTitle"), "")),
                                    checkboxInput(ns("showTitle"),NULL, value = TRUE)
                                  ),
                                  div(
                                    div(id = ns("tt_lbl_warningText"), title = "",
                                        tags$label(id = ns("lbl_warningText"), "")),
                                    textAreaInput (ns("warningText"),NULL, rows =4,
                                                   value = "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures.")
                                  )
                                )
                         )
                       )
      )
    ))
}
