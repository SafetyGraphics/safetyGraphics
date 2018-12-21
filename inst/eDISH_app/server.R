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
                                 data = isolate(reactive(dataUpload_out$data_selected())),
                                 settings = reactive(dataUpload_out$settings()),
                                 status = reactive(dataUpload_out$status()))


    
  # module to render eDish chart
  callModule(renderEDishChart, "chartEDish",
             data = reactive(dataUpload_out$data_selected()),
             settings = reactive(settings_new$settings()),
             valid = reactive(settings_new$status()$valid))


  
  session$onSessionEnded(stopApp)

}
