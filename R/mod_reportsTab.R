#' @title Reports tab
#' @description Chart export module
#' 
#' @param id module id
#' 
#' @export

reportsTabUI <- function(id){
  ns <- NS(id)
  
  
  fluidPage(
    fluidRow(
      column(10,
        wellPanel(
          class="reportPanel",
          h3("Export Charts"),
          span("Note: AE Timelines, Hepatic Explorer and Shift plot export is temporarily disabled, but will be included in v2.0. Charts implemented using shiny modules are not currently able to be exported, but may be added at a later date."),
          hr(),
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
#' @importFrom magrittr extract
#' @importFrom shinybusy show_modal_spinner remove_modal_spinner
#' 
#' @export

reportsTab <- function(input, output, session, charts, data, mapping){
  
  ns <- session$ns 
  
  # create checkbox for selecting charts of interest
  output$checkboxes <- renderUI({
    # no support for modules or broken widgets yet
    chart_type <- charts %>% map(., ~.$type) %>% unlist 
    chart_export <- charts %>% map(., ~.$export) %>% unlist 
    charts_keep <- ((! chart_type == "module") & (chart_export))
    
    charts_labels <- charts %>% map(., ~ .$label) %>% unlist
    charts_vec <- names(charts)[charts_keep]
  
    names(charts_vec) <- charts_labels[charts_keep]
    checkboxGroupInput(
      ns('chk'), 
      choices = charts_vec, 
      selected = charts_vec, 
      label = "Select Charts for Export"
    )
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
      params <- list(
        data = data(), 
        mapping = mapping(), 
        charts=charts_keep()
      )
      show_modal_spinner(text="Creating html report. This might take a while for multiple charts/large data sets.") # show the modal window
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,  ## pass in params
                        envir = new.env(parent = globalenv())  ## eval in child of global env
      )
      remove_modal_spinner() # remove it when done
    }
  )
}