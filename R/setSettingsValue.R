#' Set the value for a given named parameter
#'
#' Sets the value for a named parameter (\code{key}) to given \code{value} in a list (\code{settings})
#'
#' @param key a list (like those provided by \code{getSettingKeys()}) defining the position of parameter in the settings object. 
#' @param value the value to set
#' @param settings The settings list used to generate a chart like \code{eDISH()}
#' @param forceCreate Specifies whether the function should create a new list() when none exisits. This most commonly occurs when deeply nested objects.  
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


setSettingsValue <- function(key, value, settings, forceCreate=FALSE){

  if(typeof(settings)!="list"){
    if(forceCreate){
      settings=list()  
    }else{
      stop("Settings is not a valid list object. Set forceCreate to TRUE and re-run if you want to create a new list and continue.")  
    } 
  }
  
  firstKey <- key[[1]]
  if(length(key)==1){
    if(is.null(value)){
      settings[firstKey]<-list(NULL)
    }else{
      settings[[firstKey]]<-value
    }
    return(settings)
  }else{
    settings[[firstKey]]<-setSettingsValue(settings = settings[[firstKey]],key = key[2:length(key)], value=value, forceCreate=forceCreate)
    return(settings)
  }
}