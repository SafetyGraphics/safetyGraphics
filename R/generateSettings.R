#' Generate a settings object based on a data standard
#'
#' This function returns a settings object for the eDish chart based on the specified data standard. 
#'
#' The function is designed to work with the SDTM and AdAM CDISC(<https://www.cdisc.org/>) standards for clinical trial data. Currently, eDish is the only chart supported.
#'
#' @param standard The data standard for which to create settings. Valid options are "SDTM", "AdAM" or "None". Default: \code{"SDTM"}
#' @param chart The chart for which standards should be generated ("eDish" only for now) . Default: \code{"eDish"}.
#' @param partial Boolean for whether or not the standard is a partial standard. Default: \code{"NULL"}.
#' @param partial_cols Optional character vector of the matched cols if partial is TRUE. It will not be used if partial is FALSE Default: \code{"NULL"}.
#' @return A list containing the appropriate settings for the selected chart
#' 
#' @examples 
#' 
#' generateSettings(standard="SDTM") 
#' generateSettings(standard="SdTm") #also ok
#' generateSettings(standard="SDTM", partial=TRUE, partial_cols = c("USUBJID","TEST","STRESN"))
#' generateSettings(standard="AdAM")
#' 
#' generateSettings(standard="a different standard") 
#' #returns shell settings list with no data mapping
#' 
#' \dontrun{
#' generateSettings(standard="adam",chart="AEExplorer") #Throws error. Only eDish supported so far. 
#' }
#' 
#' @export

generateSettings <- function(standard="None", chart="eDish", partial=FALSE, partial_cols=NULL){
  if(tolower(chart)!="edish"){
    stop(paste0("Can't generate settings for the specified chart ('",chart,"'). Only the 'eDish' chart is supported for now."))
  }
  
  # Check that partial_cols is supplied if partial is true
  if  (is.null(partial_cols) & partial ) {
    stop("partial_cols must be supplied if the standard is partial")
  }
  
  
  #A shell setting object without any data mapping completed
  settings<-list(
    id_col = NULL,
    value_col = NULL,
    measure_col = NULL,
    normal_col_low = NULL,
    normal_col_high = NULL,
    studyday_col=NULL,
    visit_col = NULL,
    visitn_col = NULL,
    filters = NULL,
    group_cols = NULL,
    measure_values = list(ALT = NULL,
                          AST = NULL,
                          TB = NULL,
                          ALP = NULL),
    baseline = list(value_col=NULL,
                    values=list()),
    analysisFlag = list(value_col=NULL,
                    values=list()),
    
    x_options = c("ALT", "AST", "ALP"),
    y_options = c("TB", "ALP"),
    visit_window = 30,
    r_ratio_filter = TRUE,
    r_ratio_cut = 0,
    showTitle = TRUE,
    warningText = "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures."
  )
    
  potential_settings <- settings
  
  if(tolower(standard)=="adam"){
    potential_settings[["id_col"]]<-"USUBJID"
    potential_settings[["value_col"]]<-"AVAL"
    potential_settings[["measure_col"]]<-"PARAM"
    potential_settings[["normal_col_low"]]<-"A1LO"
    potential_settings[["normal_col_high"]]<-"A1HI"
    potential_settings[["studyday_col"]]<-"ADY"
    potential_settings[["visit_col"]]<-"VISIT"
    potential_settings[["visitn_col"]]<-"VISITNUM"
    potential_settings[["measure_values"]][["ALT"]]<-"Alanine Aminotransferase (U/L)"
    potential_settings[["measure_values"]][["AST"]]<-"Aspartate Aminotransferase (U/L)"
    potential_settings[["measure_values"]][["TB"]]<-"Bilirubin (umol/L)"
    potential_settings[["measure_values"]][["ALP"]]<-"Alkaline Phosphatase (U/L)"
  }
  
  if(tolower(standard)=="sdtm"){
    potential_settings[["id_col"]]<-"USUBJID"
    potential_settings[["value_col"]]<-"STRESN"
    potential_settings[["measure_col"]]<-"TEST"
    potential_settings[["normal_col_low"]]<-"STNRLO"
    potential_settings[["normal_col_high"]]<-"STNRHI"
    potential_settings[["studyday_col"]]<-"DY"
    potential_settings[["visit_col"]]<-"VISIT"
    potential_settings[["visitn_col"]]<-"VISITNUM"
    potential_settings[["measure_values"]][["ALT"]]<-"Aminotransferase, alanine (ALT)"
    potential_settings[["measure_values"]][["AST"]]<-"Aminotransferase, aspartate (AST)"
    potential_settings[["measure_values"]][["TB"]]<-"Total Bilirubin"
    potential_settings[["measure_values"]][["ALP"]]<-"Alkaline phosphatase (ALP)"
  }
  
  
  if(partial) {
    
    settings_names <- names(settings)
    
    potential_names <- names(potential_settings)
    
    for(i in 1:length(settings)) {
      if (potential_settings[i] %in% partial_cols) {
            settings[[which(settings_names == potential_names[i])]] <- potential_settings[[i]]
          }
    }
    
  } else {
    
    settings <- potential_settings
    
  }
  
  return(settings)
}