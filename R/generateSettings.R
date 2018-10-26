#' Generate a settings object based on a data standard
#'
#' This function returns a settings object for the eDish chart based on the specified data standard. 
#'
#' @param standard The data standard for which to create settings. Valid options are "SDTM", "AdAM" or "None". Default: \code{"SDTM"}
#' @param chart The chart for which standards should be generated ("eDish" only for now) . Default: \code{"eDish"}.
#' @return A list containing the appropriate settings for the selected chart

generateSettings <- function(standard="None", chart="eDish"){
  if(tolower(chart)!="edish"){
    stop(paste0("Can't generate settings for the specified chart ('",chart,"'). Only the 'eDish' chart is supported for now."))
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
    baseline_visitn = 1,
    filters = NULL,
    group_cols = NULL,
    measure_values = list(ALT = NULL,
                          AST = NULL,
                          TB = NULL,
                          ALP = NULL),
    x_options = c("ALT", "AST", "ALP"),
    y_options = c("TB", "ALP"),
    visit_window = 30,
    r_ratio_filter = TRUE,
    r_ratio_cut = 0,
    showTitle = TRUE,
    warningText = "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures."
  )
    
  if(tolower(standard)=="adam"){
    settings[["id_col"]]<-"USUBJID"
    settings[["value_col"]]<-"AVAL"
    settings[["measure_col"]]<-"PARAM"
    settings[["normal_col_low"]]<-"A1LO"
    settings[["normal_col_high"]]<-"A1HI"
    settings[["studyday_col"]]<-"ADY"
    settings[["visit_col"]]<-"VISIT"
    settings[["visitn_col"]]<-"VISITNUM"
    settings[["measure_values"]][["ALT"]]<-"Aminotransferase, alanine (ALT)"
    settings[["measure_values"]][["AST"]]<-"Aminotransferase, aspartate (AST)"
    settings[["measure_values"]][["TB"]]<-"Total Bilirubin"
    settings[["measure_values"]][["ALP"]]<-"Alkaline phosphatase (ALP)"
  }
  
  if(tolower(standard)=="sdtm"){
    settings[["id_col"]]<-"USUBJID"
    settings[["value_col"]]<-"STRESN"
    settings[["measure_col"]]<-"TEST"
    settings[["normal_col_low"]]<-"STNRLO"
    settings[["normal_col_high"]]<-"STNRHI"
    settings[["studyday_col"]]<-"DY"
    settings[["visit_col"]]<-"VISIT"
    settings[["visitn_col"]]<-"VISITNUM"
    settings[["measure_values"]][["ALT"]]<-"Aminotransferase, alanine (ALT)"
    settings[["measure_values"]][["AST"]]<-"Aminotransferase, aspartate (AST)"
    settings[["measure_values"]][["TB"]]<-"Total Bilirubin"
    settings[["measure_values"]][["ALP"]]<-"Alkaline phosphatase (ALP)"
  }
  
  return(settings)
}