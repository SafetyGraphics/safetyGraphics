#' Get a list of required settings
#'
#' Get a list of required settings for a given chart 
#' 
#' @param chart The chart for which required settings should be returned ("eDish" only for now) . Default: \code{"eDish"}.
#' @param metadata The metadata file to be used
#' @return List of lists specifying the position of matching named elements in the format \code{list("filters",2,"value_col")}, which would correspond to \code{settings[["filters"]][[2]][["value_col"]]}.
#' 
#' @examples 
#' safetyGraphics:::getRequiredSettings(chart="eDish")
#'
#' @importFrom stringr str_split
#' @importFrom magrittr "%>%"
#' @importFrom purrr map 
#'       
#' @export


getRequiredSettings<-function(chart="eDish", metadata=settingsMetadata){
  stopifnot(typeof(chart)=="character")
  
  #Get the metadata for the specified charts
  all_settings <- safetyGraphics:::getSettingsMetadata(charts = chart, cols=c("text_key","setting_required"), metadata=metadata) 
  if(is.null(all_settings)){
    return(NULL)
  }else{
    #get the required setting keys for the chart and then convert it to a list of lists
    required_settings <- all_settings %>% filter(setting_required) #get required settings 
    settings_list <- as.list(required_settings[[1]]) %>% map(~as.list(str_split(.x,"--")[[1]]))  #parse to list of lists
  }

  if(length(settings_list)>0){
    return(settings_list)  
  }else{
    return(NULL)
  }
  
}
