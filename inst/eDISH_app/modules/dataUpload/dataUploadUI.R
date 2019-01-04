dataUploadUI <- function(id){
  
  ns <- NS(id)
  
  tagList(                    
    fluidRow(
      column(3,
             wellPanel(
               h3("Data upload"), 
               fileInput(ns("datafile"), "Upload a csv or sas7bdat file",accept = c(".sas7bdat", ".csv"), multiple = TRUE),
               radioButtons(ns("select_file"),"Select file for eDISH chart", 
                            choiceNames = list(HTML("<p>Example data - <em style='color:green; font-size:12px;'>ADaM</em></p>")), 
                            choiceValues = "Example data")
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