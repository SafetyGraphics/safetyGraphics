#' Generate a default settings shell based on settings metadata
#'
#' This function returns a default settings objectbased on the chart(s) specified. 
#'
#' The function is designed to work with valid safetyGraphics charts.
#'
#' @param charts The chart or chart(s) for which shells should be generated ("eDish" only for now) . Default: \code{"eDish"}.
#' @return A list containing the appropriate settings for the selected chart
#' 
#' @examples 
#' 
#' generateShell(chart = "eDish") 
#'  
#' @keywords internal

generateShell <- function(charts=NULL){ 
  
  defaultMappings <- safetyGraphics::getSettingsMetadata(
    charts = charts, 
    cols=c("text_key","default","col_mapping")
  )  

  hierarchical_metadata <- str_split(defaultMappings$text_key, "--") 
  
  shell <- list()
  for (i in 1:length(hierarchical_metadata) ) {
    shell<-safetyGraphics:::setSettingsValue(
      key=hierarchical_metadata[[i]], 
      value=NA, #NA is prefered here since NULL deletes the element in the list
      settings=shell, 
      forceCreate=TRUE
    )
  }

  return(shell)
}
