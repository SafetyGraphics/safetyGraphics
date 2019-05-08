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
#' @param data A data frame
#' @param valid A logical indicating whether data/settings combination is valid for chart

render_hepexplorer_chart <- function(input, output, session, data, settings, valid){

  ns <- session$ns

  # render eDISH chart if settings pass validation
  output$chart <- renderEDISH({
    req(data())
    req(settings())

      trimmed_data <- safetyGraphics:::trimData(data = data(), settings = settings())
      eDISH(data = trimmed_data, settings = settings())

  })


  # insert export chart button if settings pass validation
  # remove button if validation fails
  observeEvent(valid(), {
    if (is.null(valid())){
      valid <- FALSE
    } else {
      valid <- valid()
    }
    
    removeUI(selector = paste0("#", ns("download")))

    if (valid==TRUE){
      insertUI (
       selector  = "div.container-fluid",
       where = "beforeEnd",
       ui =  div(id=ns("download"), # give the container div an id for easy removal
                 style="float: right;",
                 span(class = "navbar-brand", #using one of the default nav bar classes to get css close
                    style="padding: 8px;",  #then little tweak to ensure vertical alignment
                      downloadButton(ns("reportDL"), "Export Hepatic Explorer Chart")) )
      )
    }
    else {
      removeUI(selector = paste0("#", ns("download")))
    }
  }, ignoreNULL = FALSE)


  # Set up report generation on download button click
  output$reportDL <- downloadHandler(
    filename = "hepaticExplorerReport.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in case we don't
      # have write permissions to the current working dir (which can happen when deployed).
      templateReport <- system.file("eDISH_app/modules/renderChart/eDishReport","eDishReport.Rmd", package = "safetyGraphics")
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy(templateReport, tempReport, overwrite = TRUE)

      params <- list(data = data(), settings = settings())

      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,  ## pass in params
                        envir = new.env(parent = globalenv())  ## eval in child of global env
      )
    }
  )

}
