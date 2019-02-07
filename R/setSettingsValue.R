#' Set the value for a given named parameter
#'
#' Sets the value for a named parameter (\code{key}) to given \code{value} in a list (\code{settings})
#'
#' @param key a list (like those provided by \code{getSettingKeys()}) defining the position of parameter in the settings object. 
#' @param value the value to set
#' @param settings The settings list used to generate a chart like \code{eDISH()}
#' @return the updated settings object
#' 
#' 
#' @examples 
#' safetyGraphics:::setSettingValue(key=list("a","b"), value="notMyValue", settings=list(a=list(b="myValue"))) #returns list(a=list(b="notMyValue")))
#' 
#' testSettings<-generateSettings(standard="AdAM")
#' safetyGraphics:::setSettingValue(list("id_col"),"customID",testSettings) 
#' safetyGraphics:::setSettingValue(list("measure_values","ALP"),"Alanine Aminotransferase",testSettings)
#' safetyGraphics:::setSettingValue(list("myCustomSetting"),"customized",testSettings) #adds myCustomSetting to testSettings
#' 
#' @keywords internal


setSettingsValue <- function(key, value, settings){
  firstKey <- key[[1]]
  if(length(key)==1){
    settings[[firstKey]]<-value
    return(settings)
  }else{
    settings[[firstKey]]<-setSettingsValue(settings = settings[[firstKey]],key = key[2:length(key)], value)
    return(settings)
  }
}