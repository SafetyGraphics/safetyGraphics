#' Helper function to trim unneccessary rows and columns from data prior to rendering chart
#'
#' llnkonjklConvert settings keys from text vectors (using the "--" delimiter) to a list of lists
#'
#' @param data a dataframe containing lab data
#' @param settings a list of settings 
#' @return A dataframe with irrelevant columns and rows removed
#'
#' @examples
#' safetyGraphics:::textKeysToList("id_col") 
#' #list(list("id_col"))
#' 
#' #list(list("id_col"),list("measure_col","label"))
#' safetyGraphics:::textKeysToList(c("id_col","measure_col--label")) 
#' 
#' @keywords internal


trimData <- function(data, settings){
  
  #remove columns not in settings
  
  data <- adlbc
   settings<-generateSettings(standard="AdAM")
  
   cols <- colnames(data)
   settings_names  <- c("id_col","value_col","measure_col","normal_col_low","normal_col_high"
                                         ,"studyday_col","visit_col","visitn_col","filters","group_cols")
   
   a <- map(settings_names, function(x) {return(safetyGraphics:::getSettingValue(x, settings))})
   int<- intersect(cols,a)
  
   select(data, unlist(int))
   
   
  #remove rows if analysisflag or baseline specified
  
  return(trimmed_data)
}
