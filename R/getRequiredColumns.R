#' Get a list of required columns
#'
#' Get a list of required columns for a chart in a given data standard 
#' 
#' @param standard The data standard for which to fetch required columns Valid options are "SDTM", "AdAM".
#' @param chart The chart for which standards should be generated ("eDish" only for now) . Default: \code{"eDish"}.
#' @return A character vector of required data columns
#' 
#' @examples 
#' safetyGraphics:::getRequiredColumns(standard="ADAM")
#' safetyGraphics:::getRequiredColumns(standard="SDTM")
#' 
#' @importFrom dplyr "filter"

getRequiredColumns<-function(standard,chart="eDish"){
  stopifnot(
    typeof(standard)=="character",
    typeof(chart)=="character",
    tolower(chart)=="edish"
  )
  
  metadata <- safetyGraphics::getSettingsMetadata(
    charts = chart, 
    cols=c("setting_required","adam","sdtm")
  )
  
  if(tolower(chart)=="edish"){
    
    required <- filter(metadata, setting_required==TRUE)
    if(tolower(standard)=="adam"){
      return(gsub('[\"]', '',required$adam)) #changed csv!
    }else if(tolower(standard)=="sdtm"){
      return(gsub('[\"]', '',required$sdtm)) 
    }else{
      return(NULL)
    }
  }else{
    return(NULL)
  }
}
