#' @title Reports tab
#' @description Chart export module
#'
#' @export

reportsTabUI <- function(id){
  ns <- NS(id)
  
  
  fluidPage(
    fluidRow(
      column(10,
             wellPanel(
               class="reportPanel",
               h3(
                 "Charts"
               ),
               uiOutput(ns("checkboxes")),
               downloadButton(ns("reportDL"), "Export Chart(s)")
             )
             
      )
    )
  )
  
}

#' @title  Reports tab - server
#' @description server for the chart export module
#' 
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param charts list containing safetyGraphics chart objects. see custom chart vignette for details.  
#' @param data named list of current data sets [reactive]. 
#' @param mapping tibble capturing the current data mappings [reactive].
#' 
#' @export

 reportsTab <- function(input, output, session, charts, data, mapping){
  
  ns <- session$ns 
  
  # create checkbox for selecting charts of interest
  output$checkboxes <- renderUI({
    
    # no support for modules yet
    charts_keep <- charts %>% map(., ~.$type) %>% unlist 
    charts_keep <- ! charts_keep == "module"
    
    charts_labels <- charts %>% map(., ~ .$label) %>% unlist
    charts_vec <- names(charts)[charts_keep]
    names(charts_vec) <- charts_labels[charts_keep]
 
    checkboxGroupInput(ns('chk'), choices = charts_vec, selected = charts_vec, label = "Select Charts for Export")
  })
  
  
  # subset charts based on checkbox selections
  charts_keep <- reactive({
    charts %>% magrittr::extract(input$chk)
  })

  
  # Set up report generation on download button click
  output$reportDL <- downloadHandler(
    filename = "safetyGraphicsReport.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in case we don't
      # have write permissions to the current working dir (which can happen when deployed).
      templateReport <- system.file("report","safetyGraphicsReport.Rmd", package = "safetyGraphics")
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy(templateReport, tempReport, overwrite = TRUE)
      params <- list(data = data(), 
                     mapping = mapping(), 
                     charts=charts_keep())
      
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,  ## pass in params
                        envir = new.env(parent = globalenv())  ## eval in child of global env
      )
    }
  )
 
 
}