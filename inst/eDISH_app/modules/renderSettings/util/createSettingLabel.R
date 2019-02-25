createSettingLabel <- function(key){
  sm <- getSettingsMetadata(text_keys=key)
  setting_label <- sm$label
  required <- sm$setting_required
  
  if (required){
    paste0("<i class='fa fa-info-circle' style='color:gray'></i> ", setting_label, "<strong>*</strong>")
  } else {
    paste0("<i class='fa fa-info-circle' style='color:gray'></i> ", setting_label)
  }
}
