#' Get a list of required columns
#'
#' Get a list of required columns for a chart in a given data standard 
#' 
#' @param standard The data standard for which to fetch required columns Valid options are "SDTM", "AdAM".
#' @param chart The chart for which standards should be generated ("eDish" only for now) . Default: \code{"eDish"}.
#' @return A character vector of required data columns
#' 
#' @examples 
#' getRequiredColumns(standard="ADAM")
#' getRequiredColumns(standard="SDTM")

getRequiredColumns<-function(standard,chart="eDish"){
  stopifnot(
    typeof(standard)=="character",
    typeof(chart)=="character",
    tolower(chart)=="edish"
  )
  
  if(tolower(chart)=="edish"){
    if(tolower(standard)=="adam"){
      return(c("USUBJID","AVAL","PARAM","VISIT","VISITNUM","ADY","A1LO","A1HI"))
    }else if(tolower(standard)=="sdtm"){
     return(c("USUBJID","STRESN","TEST","VISIT","VISITNUM","DY","STNRLO","STNRHI")) 
    }else{
      return(NULL)
    }
  }else{
    return(NULL)
  }
}
