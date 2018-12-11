
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
                     div(

                         div(tags$label(id=ns("label_id_col"), "Unique subject identifier")),
                         selectizeInput(ns("id_col"),NULL, choices = NULL)

                     ),

                     div(
                       tags$label(id=ns("label_value_col"),"Lab Result"),
                       selectizeInput(ns("value_col"),NULL, choices = NULL)

                       ),

                     div(
                       tags$label(id=ns("label_measure_col"),"Lab measure"),
                       selectizeInput(ns("measure_col"),NULL, choices = NULL)
                     ),
                     h4("Key measures"),
                     div(
                       tags$label(id=ns("label_measure_values|ALT"),"ALT"),
                       selectizeInput(ns("measure_values|ALT"),NULL, choices = NULL)
                     ),
                     div(
                       tags$label(id=ns("label_measure_values|AST"),"AST"),
                       selectizeInput(ns("measure_values|AST"),NULL, choices = NULL)
                     ),
                     div(
                       tags$label(id=ns("label_measure_values|TB"),"TB"),
                       selectizeInput(ns("measure_values|TB"),NULL, choices = NULL)
                     ),
                     div(
                       tags$label(id=ns("label_measure_values|ALP"),"ALP"),
                       selectizeInput(ns("measure_values|ALP"),NULL, choices = NULL)
                     )
              ) ,
              column(6,
                     br(),
                     br(),
                     br(),
                     div(
                       tags$label(id=ns("label_normal_col_low"),"Lower limit of normal"),
                       selectizeInput(ns("normal_col_low"),NULL, choices = NULL)
                     ),
                     div(
                       tags$label(id=ns("label_normal_col_high"),"Upper limit of normal"),
                       selectizeInput(ns("normal_col_high"),NULL, choices = NULL)
                     ),
                     div(
                       tags$label(id=ns("label_visit_col"),"Visit"),
                       selectizeInput(ns("visit_col"),NULL, choices = NULL)
                     ),
                     div(
                       tags$label(id=ns("label_visitn_col"),"Visit number"),
                       selectizeInput(ns("visitn_col"),NULL, choices = NULL)
                     ),
                     div(
                       tags$label(id=ns("label_studyday_col"),"Study day"),
                       selectizeInput(ns("studyday_col"),NULL, choices = NULL)
                     ) #,
                     # div(
                     #   tags$label(id=ns("label_anlyFlag"),"Use flagged analysis pop"),
                     #   selectizeInput(ns("anlyFlag"),NULL, choices = NULL)
                     # )
              ))
          )
        ),
        tagList(
          column(6,
                 wellPanel(
                   h3("Measure Settings"),
                   selectInput(ns("filters"),"Filters", choices = NULL, selected = NULL, multiple = TRUE),
                   selectInput(ns("group_cols"),"Groups", choices = NULL, multiple = TRUE),
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
        )
      ))
  )

  )

}
