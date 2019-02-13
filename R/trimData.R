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
#' trimData(data=adlbc, settings=testSettings) 
#' 
#' @importFrom dplyr filter_at
#' @importFrom purrr map 
#' @importFrom magrittr "%<>%"
#' 
#' @keywords internal


trimData <- function(data, settings){
  
  #remove columns not in settings

  col_names <- colnames(data)
  settings_keys  <- safetyGraphics::getSettingsMetadata(cols="text_key", filter_expr=column_mapping==TRUE)
  
  settings_values <- map(settings_keys, function(x) {return(safetyGraphics:::getSettingValue(x, settings))})
   
  common_cols <- intersect(col_names,settings_values)
  
  data_subset <- select(data, unlist(common_cols))
   
  #remove rows if baseline or analysisFlag is specified
  
  if (!is.null(settings[['baseline']][['value_col']])) {
    data_subset %<>%
    filter_at(settings[['baseline']][['value_col']], all_vars(. %in% settings[['baseline']][['values']]))
  }
   
  if (!is.null(settings[['analysisFlag']][['value_col']])) {
    data_subset %<>%
    filter_at(settings[['analysisFlag']][['value_col']], all_vars(. %in% settings[['analysisFlag']][['values']]))
  }
  
  return(data_subset)
}
