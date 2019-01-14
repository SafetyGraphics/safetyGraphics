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


getRequiredSettings<-function(chart="eDish", metadata=safetyGraphics::settingsMetadata){
  stopifnot(typeof(chart)=="character")
  required_settings <- safetyGraphics::getSettingsMetadata(
    charts = chart, 
    cols="text_key", 
    filter_expr=setting_required==TRUE, 
    metadata=metadata
  ) %>% textKeysToList() 
  if(!is.null(required_settings) & length(required_settings) > 0){
    return(required_settings)
  }else{
    return(NULL)
  }

}
