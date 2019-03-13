#' Generate a default settings shell based on settings metadata
#'
#' This function returns a default settings object based on the chart(s) specified. 
#'
#' The function is designed to work with valid safetyGraphics charts.
#'
#' @param charts The chart or chart(s) to include in the shell settings object
#' @return A list containing a setting shell (all values = NA) for the selected chart(s)
#' 
#' @examples 
#' 
#' generateShell(charts = "eDish") 
#'  
#' @keywords internal

generateShell <- function(charts=NULL){ 
  print(charts)
  keys <- safetyGraphics::getSettingsMetadata(
    charts = charts, 
    cols=c("text_key")
  ) %>% safetyGraphics:::textKeysToList()

  print(keys)
  shell <- list()

  for (i in 1:length(keys) ) {
    shell<-safetyGraphics:::setSettingsValue(
      key=keys[[i]], 
      value=NA, #NA is prefered here since NULL deletes the element in the list
      settings=shell, 
      forceCreate=TRUE
    )
  }

  return(shell)
}
