#' Render eDISH chart - server code
#'
#' This module creates the Chart tab for the Shiny app, which contains the interactive eDISH graphic.
#'
#' Workflow:
#' (1) A change in `data`, `settings`, or `valid` invalidates the eDISH chart output
#' (2) Upon a change in `valid`, the export chart functionality is conditionally made available or unavailable to user
#' (3) If "export chart" button is pressed, data and settings are passed to the parameterized report, knitted using
#'     Rmarkdown, and downloaded to user computer.
#'
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param data A data frame  [REACTIVE]
#' @param settings list of settings arguments for chart [REACTIVE]
#' @param charts vector of charts to be subset from [REACTIVE]

renderReports <- function(input, output, session, data, settings, charts){
  
  ns <- session$ns

  observeEvent(charts(), {
    
    checkboxes <- checkboxGroupInput(ns('chk'), choices = charts(), selected = charts(), label = "Select Charts for Export")

    output$checkboxes <- renderUI(checkboxes)

  }, ignoreNULL=FALSE)
  
  
  
  

  # insert export chart(s) button if there are charts selected
  
  observeEvent(charts(), {
    removeUI(selector = paste0("#", ns("download")))
    if (!is.null(charts())){
      insertUI (
        selector  = "div.reportPanel",
        where = "afterEnd",
        ui =  div(id=ns("download"), # give the container div an id for easy removal
                  style="float: left;",
                  span(       downloadButton(ns("reportDL"), "Export Chart(s)")) )
      )
    }
  }, ignoreNULL=FALSE)


  # Set up report generation on download button click
  output$reportDL <- downloadHandler(
    filename = "safetyGraphicsReport.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in case we don't
      # have write permissions to the current working dir (which can happen when deployed).
      templateReport <- system.file("safetyGraphics_app/modules/renderReports/safetyGraphicsReport","safetyGraphicsReport.Rmd", package = "safetyGraphics")
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy(templateReport, tempReport, overwrite = TRUE)
      params <- list(data = data(), settings = settings(), charts=input$chk )

      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,  ## pass in params
                        envir = new.env(parent = globalenv())  ## eval in child of global env
      )
    }
  )

  
}
