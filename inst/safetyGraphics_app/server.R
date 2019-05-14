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
    valid <- settings_new$status()$charts[[chart]]

    ## code to toggle css for chart-specific tab here
    toggleClass(selector= paste0("#nav_id li.dropdown ul.dropdown-menu li a[data-value='", chart, "']"), class="valid", condition=valid==TRUE)
    toggleClass(selector= paste0("#nav_id li.dropdown ul.dropdown-menu li a[data-value='", chart, "']"), class="invalid", condition=valid==FALSE)
  }
})


# hide charts tab if no chart selected
observeEvent(settings_new$charts(),{
  if (is.null(settings_new$charts())){
    hideTab(inputId = "nav_id", target = "Charts")
    hideTab(inputId = "nav_id", target = "Reports")
  } 
}, 
ignoreNULL = FALSE, 
ignoreInit = TRUE)  # so there's no hiding when the app first loads

  ##############################################################
  # Initialize Charts Modules
  ##############################################################

labeledCharts <- list()
for (row in 1:nrow(filter(chartsMetadata, chart %in% all_charts))){
  labeledCharts[row]<-filter(chartsMetadata, chart %in% all_charts)[row,"chart"]
  names(labeledCharts)[row]<-filter(chartsMetadata, chart %in% all_charts)[row,"label"]
}

# set up all chart tabs from the start (all_charts defined in global.R)
  for (chartnum in 1:length(labeledCharts)){
    chart<-labeledCharts[[chartnum]]
    chartLabel<-names(labeledCharts)[[chartnum]]
    tabid <- paste0(chart, "_tab_title")

    appendTab(
      inputId = "nav_id",
      tab = tabPanel(
        title = chartLabel,
        value = chart,
        renderChartUI(paste0("chart", chart))
      ),
      menuName = "Charts"
    )
  }

  # hide/show chart tabs in response to user selections
  observe({
    
    # show charts and reports tabs if any charts are selected
    showTab(inputId = "nav_id", target = "Charts")
    showTab(inputId = "nav_id", target = "Reports")   
    
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

for(chart in all_charts){
  callModule(
    module = renderChart,
    id = paste0("chart", chart),
    data = reactive(dataUpload_out$data_selected()),
    settings = reactive(settings_new$settings()),
    valid = reactive(settings_new$status()$charts[[chart]]),
    chart = chart,
    type = "htmlwidget"
  )
  
}
  
  
  callModule(
    module = renderReports,
    id = "reportsUI",
    data = reactive(dataUpload_out$data_selected()),
    settings = reactive(settings_new$settings()),
    charts = reactive(labeledCharts[labeledCharts %in% settings_new$charts()])
  )
  
  session$onSessionEnded(stopApp)
}
