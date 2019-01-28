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
#' @importFrom dplyr "filter"
#' @importFrom stringr str_split
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
  
  metadata <- safetyGraphics::getSettingsMetadata(
    charts = chart, 
    cols=c("text_key","adam","sdtm"),
    filter_expr = adam != '' & sdtm != '' 
  )

  # Split on -- for multi-level handling 
  hierarchical_metadata <- str_split(metadata$text_key, "--") 
  
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
    measure_values = list(alt = NULL,
                          ast = NULL,
                          tb = NULL,
                          alp = NULL),
    baseline = list(value_col=NULL,
                    values=list()),
    analysisFlag = list(value_col=NULL,
                        values=list()),
    
    x_options = c("LT", "AST", "ALP"),
    y_options = c("TB", "ALP"),
    visit_window = 30,
    r_ratio_filter = TRUE,
    r_ratio_cut = 0,
    showTitle = TRUE,
    warningText = "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures."
  )
  
  potential_settings <- settings
  
  standard_low <- tolower(standard)
  
  if (standard_low == "adam" | standard_low == "sdtm") {
    
  for (row in hierarchical_metadata)  {
    if (length(row) == 1) {
      potential_settings[row] <- filter(metadata,text_key == !!row)[[standard_low]]
    } else if (length(row) == 2) {
      potential_settings[row[[1]]][[1]][row[[2]]] <- filter(metadata, grepl(!!row[[2]],text_key))[[standard_low]]
    } else{
      stop("Three level setting nests are not currently supported")
    }
    
  }
  
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