#' Get a list of required settings
#'
#' Get a list of required settings for a given chart
#'
#' @param charts The chart for which required settings should be returned ("eDish" only for now) .  Default: \code{NULL} (uses all available charts).
#' @param metadata The metadata file to be used
#' @return List of lists specifying the position of matching named elements in the format \code{list("filters",2,"value_col")}, which would correspond to \code{settings[["filters"]][[2]][["value_col"]]}.
#'
#' @examples
#' safetyGraphics:::getRequiredSettings(charts=c("edish","safetyHistogram"))
#'
#' @importFrom stringr str_split
#' @importFrom magrittr "%>%"
#' @importFrom purrr map
#' @importFrom rlang .data
#'
#' @export


getRequiredSettings<-function(charts=NULL, metadata=safetyGraphics::settingsMetadata){
  required_settings <- safetyGraphics::getSettingsMetadata(
    charts = charts,
    cols="text_key",
    filter_expr=.data$setting_required==TRUE,
    metadata=metadata
  ) %>% textKeysToList()
  if(!is.null(required_settings) & length(required_settings) > 0){
    return(required_settings)
  }else{
    return(NULL)
  }

}
