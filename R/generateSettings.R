#' Generate a settings object based on a data standard
#'
#' This function returns a settings object for the eDish chart based on the specified data standard.
#'
#' The function is designed to work with the SDTM and AdAM CDISC(<https://www.cdisc.org/>) standards for clinical trial data. Currently, eDish is the only chart supported.
#'
#' @param standard The data standard for which to create settings. Valid options are "SDTM", "AdAM" or "None". Default: \code{"None"}.
#' @param charts The chart or charts for which settings should be generated. Default: \code{NULL} (uses all available charts).
#' @param useDefaults Specifies whether default values from settingsMetadata should be included in the settings object. Default: \code{TRUE}.
#' @param partial Boolean for whether or not the standard is a partial standard. Default: \code{FALSE}.
#' @param partial_keys Optional character vector of the matched settings if partial is TRUE. Settings should be identified using the text_key format described in ?settingsMetadata. Setting is ignored when partial is FALSE. Default: \code{NULL}.
#' @param custom_settings a tibble with text_key and customValue columns specifiying customizations to be applied to the settings object. Default: \code{NULL}.
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
#' @importFrom dplyr "filter" full_join
#' @importFrom stringr str_split
#' @importFrom rlang .data
#'
#' @export

generateSettings <- function(standard="None", charts=NULL, useDefaults=TRUE, partial=FALSE, partial_keys=NULL, custom_settings=NULL){

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
  # get keys & default values for settings using a data standard (data and field mappings)
  ############################################################################
  # Build a table of data mappings for the selected standard and partial settings
  standardList<-safetyGraphics::standardsMetadata%>%select(-.data$text_key)%>%names

  if(standard %in% standardList){
    dataDefaults <- safetyGraphics::getSettingsMetadata(
      charts = charts,
      cols=c("text_key",standard,"setting_required")
    ) %>%
    filter(.data$setting_required)%>%
    select(-.data$setting_required)%>%
    rename("dataDefault" = standard)%>%
    filter(.data$dataDefault != '') %>%
    as_tibble
  }else{
    dataDefaults<-tibble(text_key=character(),dataDefault=character(), .rows=0)
  }

  if(partial){
    dataDefaults <-dataDefaults%>%filter(.data$text_key %in% partial_keys)
  }
  #############################################################################
  # get keys & default values for settings not using a data standard
  #############################################################################
  if(useDefaults){
    otherDefaults <- safetyGraphics::getSettingsMetadata(
      charts = charts) %>% 
      filter(!.data$column_mapping & !.data$field_mapping) %>% 
      select(.data$text_key, .data$default)%>% 
      rename("otherDefault"="default")
  }else{
    otherDefaults <- tibble(text_key=character(),otherDefault=character(), .rows=0)
  }

  #############################################################################
  # merge all keys & default values
  #############################################################################
  key_values <- full_join(dataDefaults, otherDefaults, by="text_key")
  key_values <- key_values %>% mutate(default=ifelse(is.na(.data$dataDefault),.data$otherDefault,.data$dataDefault))

  #############################################################################
  # Apply custom settings (if any)
  #############################################################################
    if(!is.null(custom_settings)){
      key_values<-full_join(key_values, custom_settings, by="text_key")
    } else if (nrow(key_values)>0){
      key_values$customValue<-NA
    }
    
  if (nrow(key_values)>0){
    key_values<- key_values %>% mutate(value=ifelse(is.na(.data$customValue),.data$default,.data$customValue))
    
  }
  

  #############################################################################
  # create shell settings object
  #############################################################################
  shell<-generateShell(charts=charts)

  #########################################################################################
  # populate the shell settings by looping through key_values and apply them to the shell
  #########################################################################################
  if (nrow(key_values)>0){
    for(row in 1:nrow(key_values)){
      text_key<-key_values[row,]%>%pull("text_key")
      key<- textKeysToList(text_key)[[1]]
      type <- safetyGraphics::getSettingsMetadata(text_keys=text_key,cols="setting_type")
      value <- key_values[row,"value"][[1]]
      finalValue <- value[[1]]
      
      shell<-setSettingsValue(
        settings = shell,
        key = key,
        value = finalValue
      )
    } 
  }

  #Coerce empty string to NULL for data mappings

  data_mappings <- safetyGraphics::getSettingsMetadata(
    charts = charts,
    cols="text_key",
    filter_expr=column_mapping
  )
  for(text_key in data_mappings){ 
    key <- textKeysToList(text_key)[[1]]
    current <- getSettingValue(key,shell) 
    if (!is.null(current)){
      if(current == ""){
        shell<-setSettingsValue(key=key, value=NULL, settings=shell)
      } 
    }
  }
  return(shell)
}
