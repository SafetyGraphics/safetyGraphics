#' Generate a settings object based on a data standard
#'
#' This function returns a settings object for the eDish chart based on the specified data standard. 
#'
#' The function is designed to work with the SDTM and AdAM CDISC(<https://www.cdisc.org/>) standards for clinical trial data. Currently, eDish is the only chart supported.
#'
#' @param standard The data standard for which to create settings. Valid options are "SDTM", "AdAM" or "None". Default: \code{"SDTM"}
#' @param charts The chart or chart(s) for which standards should be generated ("eDish" only for now) . Default: \code{"eDish"}.
#' @param partial Boolean for whether or not the standard is a partial standard. Default: \code{FALSE}.
#' @param partial_keys Optional character vector of the matched settings if partial is TRUE. Settings should be identified using the text_key format described in ?settingsMetadata. Setting is ignored when partial is FALSE. Default: \code{NULL}.
#' @return A list containing the appropriate settings for the selected chart
#' 
#' @examples 
#' 
#' generateSettings(standard="SDTM") 
#' generateSettings(standard="SdTm") #also ok
#' generateSettings(standard="ADaM")
#' pkeys<- c("id_col","measure_col","value_col")
#' generateSettings(standard="adam", partial=TRUE, partial_keys=pkeys)
#' 
#' generateSettings(standard="a different standard") 
#' #returns shell settings list with no data mapping
#' 
#' \dontrun{
#' generateSettings(standard="adam",chart="AEExplorer") #Throws error. Only eDish supported so far. 
#' }
#' 
#' @importFrom dplyr "filter"
#' @importFrom stringr str_split
#' @importFrom rlang .data
#' 
#' @export

generateShell <- function(chart="eDish"){

  chart="eDish"
  
  shell <- list()
  
  keys <- safetyGraphics::getSettingsMetadata(
    charts = chart, 
    cols="text_key"
  ) 
  
  
  
  return(shell)
}
