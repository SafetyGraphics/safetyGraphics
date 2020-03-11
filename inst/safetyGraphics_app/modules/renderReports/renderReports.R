#' Render Reports Tab - server code
#'
#' This module creates the Reports tab for the Shiny app, which contains the interactive eDISH graphic.
#'
#' Workflow:
#' (1) A change in `charts` invalidates the report options
#' (2) Upon a change in `charts`, the chart list for export is updated
#' (3) If "Export Chart(s)" button is pressed, data, settings, and the selected charts are passed to the parameterized report, knitted using
#'     Rmarkdown, and downloaded to user computer.
#'
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param configVals The output from the config modules - user selected data, settings, and charts - captured in a reactiveValues object. One sublist per domain.[REACTIVE VALUES]
#' @param chartsMetadata A filtered instance of the original charts metadata, containing only details needed for the reports module. [REACTIVE]

renderReports <- function(input, output, session, configVals, chartsMetadata){
  
  ns <- session$ns
  
  
  data_list <- reactive({
    out <- list()
    for (i in names(configVals)){
      data <- configVals[[i]]$data()
      out <- c(out, list(data))
    }
    names(out) <- names(configVals)
    return(out)    
  })
  

  settings_list <- reactive({
    out <- list()
    for (i in names(configVals)){
      settings <- configVals[[i]]$settings()
      out <- c(out, list(settings))
    }
    names(out) <- names(configVals)
    return(out)    
  })  
  
  observeEvent(chartsMetadata(), {
    
    charts_vec <- chartsMetadata()$chart
    names(charts_vec) <- chartsMetadata()$label
    checkboxes <- checkboxGroupInput(ns('chk'), choices = charts_vec, selected = charts_vec, label = "Select Charts for Export")

    output$checkboxes <- renderUI(checkboxes)

  }, ignoreNULL=FALSE)
  
  
  # subset metadata based on user selections
  charts_sub <- reactive({
    req(input$chk)
    req(chartsMetadata())
    md <- chartsMetadata()
    md[md$chart %in% input$chk,]
  })

  # insert export chart(s) button if there are charts selected
  
  observeEvent(chartsMetadata(), {
    removeUI(selector = paste0("#", ns("download")))
    if (!is.null(chartsMetadata())){
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
      templateReport <- system.file("safetyGraphics_app/modules/renderReports","safetyGraphicsReport.Rmd", package = "safetyGraphics")
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy(templateReport, tempReport, overwrite = TRUE)
      params <- list(data = data_list(), 
                     settings = settings_list(), 
                     charts=charts_sub() )

      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,  ## pass in params
                        envir = new.env(parent = globalenv())  ## eval in child of global env
      )
    }
  )

  
}
