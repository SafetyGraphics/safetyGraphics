#' Generate a settings object based on a data standard
#'
#' This function returns a settings object for the eDish chart based on the specified data standard. 
#'
#' The function is designed to work with the SDTM and AdAM CDISC(<https://www.cdisc.org/>) standards for clinical trial data. Currently, eDish is the only chart supported.
#'
#' @param standard The data standard for which to create settings. Valid options are "SDTM", "AdAM" or "None". Default: \code{"SDTM"}
#' @param charts The chart or chart(s) for which standards should be generated ("eDish" only for now) . Default: \code{"eDish"}.
#' @param partial Boolean for whether or not the standard is a partial standard. Default: \code{FALSE}.
#' @param partial_keys Optional character vector of the matched settings if partial is TRUE. Settings should be identified using the text_key format described in ?settingsMetadata. Setting is ignored when partial is FALSE. Default: \code{NULL}.
#' @return A list containing the appropriate settings for the selected chart
#' 
#' @examples 
#' 
#' generateSettings(standard="SDTM") 
#' generateSettings(standard="SdTm") #also ok
#' generateSettings(standard="ADaM")
#' pkeys<- c("id_col","measure_col","value_col")
#' generateSettings(standard="adam", partial=TRUE, partial_keys=pkeys)
#' 
#' generateSettings(standard="a different standard") 
#' #returns shell settings list with no data mapping
#' 
#' \dontrun{
#' generateSettings(standard="adam",chart="AEExplorer") #Throws error. Only eDish supported so far. 
#' }
#' 
#' @importFrom dplyr "filter"
#' @importFrom stringr str_split
#' @importFrom rlang .data
#' 
#' @export

generateSettings <- function(standard="None", charts=NULL, partial=FALSE, partial_keys=NULL){
  
  # Check that partial_keys is supplied if partial is true
  if  (is.null(partial_keys) & partial ) {
    stop("partial_keys must be supplied if the standard is partial")
  }
  
  # Coerce options to lowercase
  standard<-tolower(standard)
  if(!is.null(charts)){
    charts<-tolower(charts)  
  }
  
  #############################################################################
  # create shell
  #############################################################################
  shell<-safetyGraphics:::generateShell(charts=charts) 
  
  #############################################################################
  # populate defaults settings using a data standard (data and field mappings) 
  #############################################################################
  # Build a table of data mappings for the selected standard and partial settings
  standardList<-c("adam","sdtm") #TODO: automatically generate this from metadata
  if(standard %in% standardList){
    dataMappings <- safetyGraphics::getSettingsMetadata(
      charts = charts, 
      cols=c("text_key",standard,"setting_required")
    ) %>% 
    filter(.data$setting_required)%>%
    rename("column_name" = standard)%>%
    filter(.data$column_name != '')
    
    if(partial){
      dataMappings<-dataMappings%>%filter(.data$text_key %in% partial_keys) 
    }
  }
  
  # loop through dataMappings and apply them to the shell
  if(standard %in% standardList){
    for(row in 1:nrow(dataMappings)){
      shell<-setSettingsValue(settings = shell, key = textKeysToList(dataMappings[row,"text_key"])[[1]], value = dataMappings[row, "column_name"])
    }    
  }
  
  #############################################################################
  # populate defaults settings not using a data standard (non-mappings) 
  #############################################################################
  defaults <- safetyGraphics::getSettingsMetadata(
    charts = charts, 
    filter = !.data$column_mapping & !.data$field_mapping,
    cols=c("text_key","default")
  )
  
  if(partial){
    defaults<-defaults%>%filter(.data$text_key %in% partial_keys) 
  }
  
  for(row in 1:nrow(defaults)){
    shell<-setSettingsValue(settings = shell, key = textKeysToList(defaults[row,"text_key"])[[1]], value = defaults[row, "default"])
  }    
  
  return(shell)
}
