#' Get a list of required settings
#'
#' Get a list of required settings for a given chart 
#' 
#' @param chart The chart for which required settings should be returned ("eDish" only for now) . Default: \code{"eDish"}.
#' @return List of lists specifying the position of matching named elements in the format \code{list("filters",2,"value_col")}, which would correspond to \code{settings[["filters"]][[2]][["value_col"]]}.
#' 
#' @examples 
#' safetyGraphics:::getRequiredSettings(chart="eDish")
#' 



getRequiredSettings<-function(chart="eDish"){
  stopifnot(
    typeof(chart)=="character",
    tolower(chart)=="edish"
  )
  
  if(tolower(chart)=="edish"){
      return(list(
        list("id_col"),
        list("measure_col"),
        list("value_col"),
        list("studyday_col"),
        list("normal_col_high"),
        list("normal_col_low")
      ))
  }else{
    return(NULL)
  }
}
