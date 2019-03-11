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

generateSettings <- function(standard="None", charts="eDish", partial=FALSE, partial_keys=NULL){
  if(tolower(chart)!="edish"){
    stop(paste0("Can't generate settings for the specified chart ('",chart,"'). Only the 'eDish' chart is supported for now."))
  }
  
  # Check that partial_keys is supplied if partial is true
  if  (is.null(partial_keys) & partial ) {
    stop("partial_keys must be supplied if the standard is partial")
  }
  
  # Coerce options to lowercase
  standard<-tolower(standard)
  chart<-tolower(chart)
  
  # Build a table of data mappings for the selected standard and partial settings
  standardList<-c("adam","sdtm") #TODO: automatically generate this from metadata
  if(standard %in% standardList){
    dataMappings <- safetyGraphics::getSettingsMetadata(
      charts = chart, 
      cols=c("text_key",standard,"setting_required")
    ) %>% 
    filter(.data$setting_required)%>%
    rename("column_name" = standard)%>%
    filter(.data$column_name != '')
    
    if(partial){
      dataMappings<-dataMappings%>%filter(.data$text_key %in% partial_keys) 
    }
  }
  
  #generate the shell setting object for the chart
  shell<-generateShell(chart=chart)
  #populateDefaults(shell) what is this for...
  
  # loop through dataMappings and apply them to the shell
  if(standard %in% standardList){
    for(row in 1:nrow(dataMappings)){
      shells[[chart]]<-setSettingsValue(settings = shells[[chart]], key = textKeysToList(dataMappings[row,"text_key"])[[1]], value = dataMappings[row, "column_name"])
    }    
  }

  #replace defaults with custom values (if any)
  shell[[chart]]<-applyCustomSettings(shell, customSettings)
  for(setting in customSettigns){
    setSettingValue(shell,setting$key, setting$value)
  }
  
  return(shells[[chart]])
}
