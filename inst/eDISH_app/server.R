# Server code for safetyGraphics App
#   - calls dataUpload module (data tab)
#   - calls renderSettings module (settings tab)
#   - calls chart modules (chart tab)
#   - uses render UI to append a red X or green check on tab title,
#      indicating whether user has satisfied requirements of that tab
source("util/createChartTab.R")


function(input, output, session){


  # run dataUpload module
  #
  #  returns selected dataset, settings, and validation status
  dataUpload_out <- callModule(dataUpload, "datatab")
  output$data_tab_title = renderUI({span(tagList("Data"))})

  # based on selected data set & generated/selected settings obj, generate settings page.
  #
  #  NOTE:  module is being triggered when selected dataset changes OR when settings list changes
  #   this could cause the module to trigger twice unecessarily in some cases because the settings are generated
  #   AFTER the data is changed.
  #
  # reutrns updated settings and validation status
  settings_new <- callModule(
    renderSettings,
    "settingsUI",
    data = reactive(dataUpload_out$data_selected()),
    settings = reactive(dataUpload_out$settings()),
    status = reactive(dataUpload_out$status())
  )

# Create chart tabs when the App is loaded
charts <- isolate(settings_new$charts())
lapply(charts, createChartTab)


# Observer #1 -  When a chart is toggled show/hide it's menu item
# shinyjs::toggleClass(id=tab_id, class="hidden")

# Observer #2 -  When validation re-runs, update chart status symbols
# shinyjs::toggleClass(id=ctl_id, class="valid")
# shinyjs::toggleClass(id=ctl_id, class="invalid")

  # Initialize the chart modules
  for (chart in allcharts){

    modfun <- match.fun(paste0("render_", chart, "_chart"))

    # I'm thinking this code set up (loop + callModule() using reactives) isn't ideal and
    # the value for "valid" doesn't always get passed directly.
    # Moving to renderChart module will hopefully help here
    callModule(
      module = modfun,
      # TODO: move to module = "renderChart", TODO
      id = paste0("chart", chart),
      data = reactive(dataUpload_out$data_selected()),
      settings = reactive(settings_new$settings()),
      valid = reactive(settings_new$status()[[chart]]$valid)) ## bad
    }


  session$onSessionEnded(stopApp)

}
