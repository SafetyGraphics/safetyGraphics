#' Removes unnecessary rows and columns
#'
#' Removes unnecessary rows and columns from data based on current settings
#'
#' @param data a data frame to trim
#' @param settings the settings list used to determine which rows and columns to drop
#' @return A dataframe with unnecessary columns and rows removed
#'
#' @examples
#' testSettings <- generateSettings(standard="adam")
#' safetyGraphics:::trimData(data=adlbc, settings=testSettings) 
#' 
#' @importFrom dplyr filter
#' @importFrom purrr map 
#' @importFrom rlang parse_expr
#' 
#' @keywords internal


trimData <- function(data, settings){
  
  ## Remove columns not in settings ##
  
  col_names <- colnames(data)
  settings_keys  <- safetyGraphics::getSettingsMetadata(cols="text_key", filter_expr=column_mapping==TRUE) %>%
    str_split("--")
  
  settings_values <- map(settings_keys, function(x) {return(safetyGraphics:::getSettingValue(x, settings))})
   
  common_cols <- intersect(col_names,settings_values)
  
  data_subset <- select(data, unlist(common_cols))
   
  ## Remove rows if baseline or analysisFlag is specified ##
  
  if(!is.null(settings[['baseline']][['value_col']]) | !is.null(settings[['analysisFlag']][['value_col']])) {
    
    # Create Baseline String
    baseline_string <- ifelse(!is.null(settings[['baseline']][['value_col']]),
     paste(settings[['baseline']][['value_col']], "%in% settings[['baseline']][['values']]"),
     "")

    # Create AnalysisFlag String
    analysis_string <- ifelse(!is.null(settings[['analysisFlag']][['value_col']]),
      paste(settings[['analysisFlag']][['value_col']], "%in% settings[['analysisFlag']][['values']]"),
    "")
    
    # Include OR operator if both are specified 
    operator <- ifelse(!is.null(settings[['baseline']][['value_col']]) & !is.null(settings[['analysisFlag']][['value_col']]),
                        "|","")
  
    # Create filter string and make it an expression
    filter_string <- paste(baseline_string, operator, analysis_string)
    filter_expression <- parse_expr(filter_string)
    
    #Filter on baseline and analysisFlag
    data_subset <-  filter(data_subset, !!filter_expression) 
    
  } 
    
  return(data_subset)
}
