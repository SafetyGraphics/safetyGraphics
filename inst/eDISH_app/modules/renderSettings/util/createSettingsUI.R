createSettingsUI <- function(data, settings, setting_cat_val, charts, ns){
  
  sm <- getSettingsMetadata(charts=charts) %>% 
    filter(setting_cat==setting_cat_val)

  lapply(sm$text_key, function(key){
    createControl(key, metadata = sm, data, settings, ns) 
  })
}




