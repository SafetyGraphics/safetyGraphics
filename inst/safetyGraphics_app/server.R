# Server code for safetyGraphics App
#   - calls dataUpload module (data tab)
#   - calls renderSettings module (settings tab)
#   - calls chart modules (chart tab)
#   - uses render UI to append a red X or green check on tab title,
#      indicating whether user has satisfied requirements of that tab

function(input, output, session){

  ##############################################################
  # initialize dataUpload module
  #
  #  returns selected dataset, settings, and validation status
  ##############################################################
  dataUpload_out <- callModule(dataUpload, "datatab")

  ##############################################################
  # Initialize Settings Module
  #
  # generate settings page based on selected data set & generated/selected settings obj
  #
  #  NOTE:  module is being triggered when selected dataset changes OR when settings list changes
  #   this could cause the module to trigger twice unecessarily in some cases because the settings are generated
  #   AFTER the data is changed.
  #
  # returns updated settings and validation status
  ##############################################################

settings_new <-   callModule(
    renderSettings,
    "settingsUI",
    data = reactive(dataUpload_out$data_selected()),
    settings = reactive(dataUpload_out$settings()),
    status = reactive(dataUpload_out$status())
  )


#toggle css class of chart tabs
observeEvent(settings_new$status(),{
  for (chart in settings_new$charts()){
    valid <- settings_new$status()[[chart]]$valid

    ## code to toggle css for chart-specific tab here
    toggleClass(selector= paste0("#nav_id li.dropdown ul.dropdown-menu li a[data-value='", chart, "']"), class="valid", condition=valid==TRUE)
    toggleClass(selector= paste0("#nav_id li.dropdown ul.dropdown-menu li a[data-value='", chart, "']"), class="invalid", condition=valid==FALSE)
  }
})

  ##############################################################
  # Initialize Charts Modules
  ##############################################################


# set up all chart tabs from the start (all_charts defined in global.R)
  for (row in 1:nrow(chartsMetadata)){
    chart<-chartsMetadata[row,"chart"]
    chartLabel<-chartsMetadata[row,"label"]
    tabid <- paste0(chart, "_tab_title")

    appendTab(
      inputId = "nav_id",
      tab = tabPanel(
        title = chartLabel,
        renderChartUI(paste0("chart", chart))
      ),
      menuName = "Charts"
    )
  }


  # for (chart in all_charts){
  #
  #   tabfun <- match.fun(paste0("render_", chart, "_chartUI"))  # module UI for given tab
  #   tabid <- paste0(chart, "_tab_title")
  #
  #   appendTab(
  #     inputId = "nav_id",
  #     tab = tabPanel(
  #       title = chart,
  #       tabfun(paste0("chart", chart))
  #     ),
  #     menuName = "Charts"
  #   )
  # }
  #


  # hide/show chart tabs in response to user selections
  observe({
    all_charts <- as.vector(chartsMetadata[["chart"]])
    selected_charts <- settings_new$charts()
    unselected_charts <- all_charts[!all_charts %in% selected_charts]

    for(chart in unselected_charts){
      hideTab(inputId = "nav_id",
              target = chart)
    }
    for(chart in selected_charts){
      showTab(inputId = "nav_id",
              target = chart)
    }
  })




#
#     callModule(
#       module = render_edish_chart,
#       id = paste0("chart", "edish"),
#       data = reactive(dataUpload_out$data_selected()),
#       settings = reactive(settings_new$settings()),
#       valid = reactive(settings_new$status()[["edish"]]$valid)
#     )
#     callModule(
#       module = render_safetyhistogram_chart,
#       id = paste0("chart", "safetyhistogram"),
#       data = reactive(dataUpload_out$data_selected()),
#       settings = reactive(settings_new$settings()),
#       valid = reactive(settings_new$status()[["safetyhistogram"]]$valid)
#     )


  callModule(
    module = renderChart,
    id = paste0("chart", "edish"),
    data = reactive(dataUpload_out$data_selected()),
    settings = reactive(settings_new$settings()),
    valid = reactive(settings_new$status()$valid),
    chart = "edish",
    type = "htmlwidget"
  )


  callModule(
    module = renderChart,
    id = paste0("chart", "safetyhistogram"),
    data = reactive(dataUpload_out$data_selected()),
    settings = reactive(settings_new$settings()),
    valid = reactive(settings_new$status()$valid),
    chart = "safetyhistogram",
    type = "htmlwidget"
  )

  callModule(
    module = renderChart,
    id = paste0("chart", "safetyoutlierexplorer"),
    data = reactive(dataUpload_out$data_selected()),
    settings = reactive(settings_new$settings()),
    valid = reactive(settings_new$status()$valid),
    chart = "safetyoutlierexplorer",
    type = "htmlwidget"
  )
  
  session$onSessionEnded(stopApp)
}
