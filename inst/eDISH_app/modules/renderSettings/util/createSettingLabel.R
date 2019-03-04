#' Create label for chart setting selector
#'
#' @param key A character key representing the setting of interest.
#'
#' @return A character string containing full HTML text to be used for input label. Contains info icon to 
#' indicate that description is available upon mouseover, setting label, and asterisk if setting is required.
#' 
createSettingLabel <- function(key){
  sm <- getSettingsMetadata(text_keys=key)
  setting_label <- sm$label
  required <- sm$setting_required
  paste0(setting_label)#, " <i class='fa fa-info-circle' style='color:gray'></i>" )
}
