#' Retrieve the value for a given named parameter
#'
#' Returns the value for a named parameter (\code{key}) in a list \code{settings} 
#'
#' @param key a list (like those provided by \code{getSettingKeys()}) defining the position of parameter in the settings object.
#' @param settings The settings list used to generate a chart like \code{eDISH()}
#' @return the value of the key/settings combo
#' 
#' 
#' #' @examples 
#' getSettingValue(list("a","b"),list(a=list(b="myValue"))) #returns "myValue"
#' 
#' testSettings<-generateSettings(standard="AdAM")
#' getSettingValue(list("id_col"),testSettings) 
#' getSettingsValue(list("measure_values","ALP"),testSettings)
#' getSettingValue(list("NotASetting"),testSettings) #returns NULL

getSettingValue <- function(key,settings){
  stopifnot(typeof(settings)=="list")
  
  # Get the value for the first key
  firstKey <- key[[1]]
  value <- settings[[firstKey]]
  
  
  if(length(key)>1 ){
    #If there are more keys and the value is a list, iterate
    if(typeof(value)=="list"){
      value<-getSettingValue(key[2:length(key)],value)  
    }else{
      #If there are more keys, but the value is not a list, return NULL
      value<-NULL
    }
  }
  return(value)
}