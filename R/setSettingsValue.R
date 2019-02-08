#' Set the value for a given named parameter
#'
#' Sets the value for a named parameter (\code{key}) to given \code{value} in a list (\code{settings})
#'
#' @param key a list (like those provided by \code{getSettingKeys()}) defining the position of parameter in the settings object. 
#' @param value the value to set
#' @param settings The settings list used to generate a chart like \code{eDISH()}
#' @return the updated settings object
#' 
#' @examples 
#' testSet<-list(a=list(b="myValue"))
#' safetyGraphics:::setSettingsValue(key=list("a","b"), value="notMyValue", settings=testSet) 
#' #returns list(a=list(b="notMyValue")))
#' 
#' adamSettings<-generateSettings(standard="AdAM")
#' safetyGraphics:::setSettingsValue(list("id_col"),"customID",adamSettings) 
#' safetyGraphics:::setSettingsValue(list("measure_values","ALP"),"Alanine Aminotrans",adamSettings)
#' safetyGraphics:::setSettingsValue(list("myCustomSetting"),"customized",adamSettings) 
#' #adds myCustomSetting to adamSettings
#' 
#' @keywords internal


setSettingsValue <- function(key, value, settings){
  stopifnot(
    typeof(settings)=="list"
  )
  
  firstKey <- key[[1]]
  if(length(key)==1){
    settings[[firstKey]]<-value
    return(settings)
  }else{
    settings[[firstKey]]<-setSettingsValue(settings = settings[[firstKey]],key = key[2:length(key)], value)
    return(settings)
  }
}