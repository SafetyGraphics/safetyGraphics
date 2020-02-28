#' Create UI for specified section of settings tab
#'
#' @param data A data frame to be used to populate control options
#' @param settings A settings list to be used to populate control options
#' @param setting_cat_val Settings category. One of "data","measure","appearance"
#' @param charts A character vector containing names of charts of interest
#' @param ns The namespace of the current module
#'
#' @return A list containing the UI code for all selectors in the specified settings category.
createSettingsUI <- function(data, settings, setting_cat_val, charts, metadata, ns){
  
  #filter the metadata based on the charts option (if any)
  sm <- getSettingsMetadata(charts=charts, metadata=metadata) %>% 
       filter(setting_cat==setting_cat_val)
    
  lapply(sm$text_key, function(key){
    createControl(key, metadata = sm, data, settings, ns) 
  })
}




