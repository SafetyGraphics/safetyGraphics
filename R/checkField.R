#' Check that a setting parameter has a matching data field
#'
#' Checks that a single parameter from the settings list matches a field value in a specified data set
#'
#' This function compares settings with field values as part of the \code{validateSettings()} function. More specifically, the function checks whether the \code{fieldKey} in a \code{settings} object matches a column/field combination in \code{"data"}. The function makes 2 major assumptions about the structure of the settings object. First, it assumes that the first value in fieldKey is "settingName_values" and there is a corresponding "settingName_col" setting that defines the column to search for field-level data. Second, it expects that the value specified by key/settings is a list, and that each value in the list is a field of the variable above.
#'
#' @param fieldKey a list (like those provided by \code{getSettingKeys())} defining the position of parameter in the settings object.
#' @param settings The settings list used to generate a chart like \code{eDISH()}
#' @param data A data frame to check for the specified field
#' @return A list containing the results of the check following the format specified in \code{validateSettings()[["checkList"]]}
#'
#'
#' @examples
#' testSettings<-generateSettings(standard="AdAM")
#' fields<-list("measure_values","TB")
#' safetyGraphics:::checkFieldSettings(fieldKey=fields,settings=testSettings, data=adlbc) 
#' 
#' @keywords internal

checkFieldSettings <- function(fieldKey, settings, data){
  stopifnot(typeof(fieldKey)=="list", typeof(settings)=="list")
  
  # Check to see that the field data specified in the seetings is found in the data
  fieldCheck <- list()
  fieldCheck$key<-fieldKey
  fieldCheck$text_key<- paste( unlist(fieldKey), collapse='--')
  fieldCheck$type <- "field value from setting found in data"
  fieldCheck$description <- "field value from setting found in data"
  fieldCheck$value <-  getSettingValue(key=fieldCheck$key,settings=settings)
  
  #get the name of the column containing the field 
  columnTextKey<-getSettingsMetadata(cols="field_column_key",text_keys=fieldCheck$text_key)
  columnKey<-textKeysToList(columnTextKey)[[1]]
  columnName<-getSettingValue(key=columnKey,settings=settings)

  if(length(fieldCheck$value)>0){
    fieldCheck$valid <-  hasField(fieldValue=fieldCheck$value, columnName=columnName,data=data)     
  }else{
    fieldCheck$value <-  "--No Value Given--"
    fieldCheck$valid <- TRUE #null values are ok
  }
  fieldCheck$message <- ifelse(!fieldCheck$valid,  paste0("Value of ",fieldCheck$value, " for '",fieldCheck$text_key,"' not found in ",columnName),"")
  
  return(fieldCheck)
}
