#' Data upload module - UI code
#'
#' This module creates the Data tab for the Shiny app.
#'
#' The UI contains:
#' - a file upload control
#' - radio buttons for selecting from the available datasets
#' - raw data preview.
#'
#' @param id The module-specific ID that will get pre-pended to all element IDs
#'
#' @return The UI for the Data tab
#'
dataUploadUI <- function(id){

  ns <- NS(id)

  tagList(
    fluidRow(
      column(3,
             wellPanel(
               h3("Data upload"),
               fileInput(ns("datafile"), "Upload a csv or sas7bdat file",accept = c(".sas7bdat", ".csv"), multiple = TRUE),
               radioButtons(ns("select_file"),"Select file for safetyGraphics charts",
                            choiceNames = preload_data_list$display,
                            choiceValues = names(preload_data_list$data))
               # radioButtons(ns("select_file"),"Select file for safetyGraphics charts",
               #              choiceNames = list(HTML("<p>Example data - <em style='color:green; font-size:12px;'>ADaM</em></p>")),
               #              choiceValues = "Example data")
             )
      ),
      column(6,
             fluidRow(
               wellPanel(
                 uiOutput(ns("datapreview_header")),
                 div(DT::dataTableOutput(ns("data_preview")), style = "font-size: 75%")
               )
             )
      )
    )
  )

}
