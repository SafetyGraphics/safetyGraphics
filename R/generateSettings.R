#' Generate a settings object based on a data standard
#'
#' This function returns a settings object for the eDish chart based on the specified data standard. 
#'
#' The function is designed to work with the SDTM and AdAM CDISC(<https://www.cdisc.org/>) standards for clinical trial data. Currently, eDish is the only chart supported.
#'
#' @param standard The data standard for which to create settings. Valid options are "SDTM", "AdAM" or "None". Default: \code{"SDTM"}
#' @param chart The chart for which standards should be generated ("eDish" only for now) . Default: \code{"eDish"}.
#' @param partial Boolean for whether or not the standard is a partial standard. Default: \code{FALSE}.
#' @param partial_keys Optional character vector of the matched settings if partial is TRUE. Settings should be identified using the text_key format described in ?settingsMetadata. Setting is ignored when partial is FALSE. Default: \code{NULL}.
#' @return A list containing the appropriate settings for the selected chart
#' 
#' @examples 
#' 
#' generateSettings(standard="SDTM") 
#' generateSettings(standard="SdTm") #also ok
#' generateSettings(standard="SDTM", partial=TRUE, partial_keys = c("id_col","measure_col","value_col"))
#' generateSettings(standard="ADaM")
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

generateSettings <- function(standard="None", chart="eDish", partial=FALSE, partial_keys=NULL){
  if(tolower(chart)!="edish"){
    stop(paste0("Can't generate settings for the specified chart ('",chart,"'). Only the 'eDish' chart is supported for now."))
  }
  
  # Check that partial_keys is supplied if partial is true
  if  (is.null(partial_keys) & partial ) {
    stop("partial_keys must be supplied if the standard is partial")
  }
  
  # Coerce options to lowercase
  standard<-tolower(standard)
  chart<-tolower(chart)
  
  # Build a table of data mappings for the selected standard and partial settings
  if(standard != "none"){
    dataMappings <- safetyGraphics::getSettingsMetadata(
      charts = chart, 
      cols=c("text_key",standard,"setting_required")
    ) %>% 
    filter(.data$setting_required)%>%
    rename("column_name" = standard)%>%
    filter(.data$column_name != '')
    
    if(partial){
      dataMappings<-dataMappings%>%filter(.data$text_key %in% partial_keys) 
    }
  }
  
  # build shell settings for each chart (move these to /data eventually?)
  shells<-list()
  shells[["edish"]]<-list(
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
  
  # loop through dataMappings and apply them to the shell
  if(standard != "none"){
    for(row in 1:nrow(dataMappings)){
      shells[[chart]]<-setSettingsValue(settings = shells[[chart]], key = textKeysToList(dataMappings[row,"text_key"])[[1]], value = dataMappings[row, "column_name"])
    }    
  }

  return(shells[[chart]])
}