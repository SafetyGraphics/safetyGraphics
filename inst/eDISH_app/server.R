function(input, output, session){


  # run dataUpload module
  #
  #  returns selected dataset, settings, and validation status
  dataUpload_out <- callModule(dataUpload, "datatab")

  
  # based on selected data set & generated/selected settings obj, generate settings page.
  #
  #  NOTE:  module is being triggered when selected dataset changes OR when settings list changes
  #   this could cause the module to trigger twice unecessarily in some cases because the settings are generated
  #   AFTER the data is changed.
  #
  # reutrns updated settings and validation status
    settings_new <-   callModule(renderSettings, "settingsUI",
                                 data = reactive(dataUpload_out$data_selected()),
                                 settings = reactive(dataUpload_out$settings()),
                                 status = reactive(dataUpload_out$status()))

  # module to render eDish chart
  callModule(renderEDishChart, "chart--eDish",
             data = reactive(dataUpload_out$data_selected()),
             settings = reactive(settings_new$settings()),
             valid = reactive(settings_new$status()$valid))


  observeEvent(settings_new$status(), {
    removeUI(selector = "#download")
    if (settings_new$status()$valid==FALSE) {
      removeUI(selector = "#download")
    } else{
      insertUI (

      selector  = "div.container-fluid",
      where = "beforeEnd",
      ui =  div(id="download", # give the container div an id for easy removal
                style="float: right;",
                span(class = "navbar-brand", #using one of the default nav bar classes to get css close
                     style="padding: 8px;",  #then little tweak to ensure vertical alignment
                     downloadButton("reportDL", "Export Chart")))
    )
    }
  })


  # Set up report generation on download button click
  output$reportDL <- downloadHandler(
    filename = "safety_report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in case we don't
      # have write permissions to the current working dir (which can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("template/safetyGraphicReport.Rmd", tempReport, overwrite = TRUE)

    #  params <- list(data = data_selected(), settings = settings_new$settings())
    params <- list(data = dataUpload_out$data_selected(), settings = settings_new$settings())

      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,  ## pass in params
                        envir = new.env(parent = globalenv())  ## eval in child of global env
      )
    }
  )


    
  

  session$onSessionEnded(stopApp)

}
