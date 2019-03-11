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

generateShell <- function(charts="eDish"){ 
  
  
  #chart="eDish" # expand too multiple charts
  
  defaultMappings <- safetyGraphics::getSettingsMetadata(
    charts = charts, 
    cols=c("text_key","default")
  )  
  
  shell <- defaultMappings$default
  names(shell) <- defaultMappings$text_key
  
  return(shell)
}
