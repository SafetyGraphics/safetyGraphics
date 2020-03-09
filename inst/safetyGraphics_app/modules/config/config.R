# Server code for safetyGraphics App
#   - calls dataUpload module (data tab)
#   - calls renderSettings module (settings tab)
#   - calls chart modules (chart tab)
#   - uses render UI to append a red X or green check on tab title,
#      indicating whether user has satisfied requirements of that tab

config <- function(input, output, session, metadata, domain, preload_data_list){

  ns <- session$ns
  
  # filter the metadata
  metadata <- metadata 
  settingsMetadata <- filter(metadata$settingsMetadata, domain==!!domain)
  chartsMetadata <- filter(metadata$chartsMetadata, domain==!!domain & chart %in% all_charts)
  standardsMetadata <- filter(metadata$standardsMetadata, domain==!!domain)
  domain_charts <- chartsMetadata$chart
  names(domain_charts) <- chartsMetadata$label
  

  ##############################################################
  # initialize dataUpload module
  #
  #  returns selected dataset, settings, and validation status
  ##############################################################
  dataUpload_out <- callModule(dataUpload, "datatab", domain=domain, 
                               preload_data_list = preload_data_list[[domain]])

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
    status = reactive(dataUpload_out$status()),
    metadata=settingsMetadata,
    charts = domain_charts
  )
  
  
  
  return(list(data = reactive(dataUpload_out$data_selected()),
              settings = reactive(settings_new$settings()),
              charts = reactive(settings_new$charts2())))
  
}

