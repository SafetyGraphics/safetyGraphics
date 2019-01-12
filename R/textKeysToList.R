#' Helper function to convert keys from text to nested lists
#'
#' Convert settings keys from text vectors (using the "--" delimiter) to a list of lists
#'
#' @param textKeys a list (or vector) of character keys using the "--" delimiter to indicate heirarchy
#' @return A list of unnamed lists, with position in the nested list indicating heirarchy
#'
#' @examples
#' safetyGraphics:::textKeysToList("id_col") 
#' #list(list("id_col"))
#' 
#' #list(list("id_col"),list("measure_col","label"))
#' safetyGraphics:::textKeysToList(c("id_col","measure_col--label")) 


textKeysToList <- function(textKeys){
  return(as.list(textKeys) %>% map(~as.list(str_split(.x,"--")[[1]])))
}
