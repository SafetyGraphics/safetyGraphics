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
#' @import rlang
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
  
  #Might be worth while to have an error message if they supply a standard and its not supported
  metadata <- safetyGraphics::getSettingsMetadata(
    charts = chart, 
    cols=c("text_key","default","adam","sdtm")
  )

  # Split on -- for two level handling 
  hierarchical_metadata <- str_split(metadata$text_key, "--") 
  
  standard_low <- tolower(standard)
  
  if (standard == "None") {
    standard_low <- "default"
  }
  
  # Build empty settings list
  potential_settings <- list()
  for ( i in 1:length(hierarchical_metadata) ) {
    
    # Handle settings with one level
    if (length(hierarchical_metadata[[i]]) == 1) {

      #Handle Nulls
       if (is.null(parse_expr(metadata[[standard_low]][i]))) {
         potential_settings[metadata$text_key[i]] = list(parse_expr(metadata[[standard_low]][i]))
         
        # Handle C()  - not implemented for level two yet
       } else if (typeof(parse_expr(metadata[[standard_low]][i])) == "language") {
         potential_settings[[metadata$text_key[i]]] = as.character(parse_expr(metadata[[standard_low]][i]))[-1]  #Need the -1 to remove the unwelcome "c" that comes with this method
         
       } else {
        potential_settings[metadata$text_key[[i]]] = parse_expr( metadata[[standard_low]][i])
      }
            
      # Handle settings with two levels
    } else if (length(hierarchical_metadata[[i]]) == 2){
      
      #Create list if it does not exist
      if (!is.list(potential_settings[[hierarchical_metadata[[i]][1]]])) { potential_settings[[hierarchical_metadata[[i]][1]]] = list() } #Need to make list if it doesnt exist since its two-level
      
      #Handle Nulls
       if (is.null(parse_expr(metadata[[standard_low]][i]))) {
         potential_settings[[hierarchical_metadata[[i]][1]]][hierarchical_metadata[[i]][2]] = list(parse_expr(metadata[[standard_low]][i]))
         
       } else {
        potential_settings[[hierarchical_metadata[[i]][1]]][[hierarchical_metadata[[i]][2]]] = parse_expr( metadata[[standard_low]][i])
      }
            
    } else{
      stop("Three level setting nests are not currently supported")
    }
    
  }
  
  
  # if(partial) {
  #   
  #   settings <- list()
  #   
  #   settings_names <- names(potential_settings)
  #   
  #   for(i in 1:length(potential_settings)) {
  #     if (potential_settings[i] %in% partial_cols) {
  #           settings[[which(settings_names == potential_names[i])]] <- potential_settings[[i]]
  #         }
  #   }
  #   
  # } else {
    
    settings <- potential_settings
    
  #}
  
  return(settings)
}