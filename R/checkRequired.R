#' Check that the user has provided a valid for a given settings parameter
#'
#' Checks that a single required parameter from the settings list is provided by the user
#'
#' @param key a list (like those provided by \code{getSettingKeys())} defining the position of parameter in the settings object.
#' @param settings The settings list used to generate a chart like \code{eDISH()}
#' @return A list containing the results of the check following the format specified in \code{validateSettings()[["checkList"]]}
#'
#' @examples
#' testSettings<-generateSettings(standard="AdAM")
#' 
#' #pass ($valid == TRUE)
#' safetyGraphics:::checkRequired(key=list("id_col"),
#'                                       settings=testSettings) 
#' 
#' #fails since filters aren't specified by default
#' safetyGraphics:::checkRequired(key=list("filters"),
#'                                       settings=testSettings) 
#' 
#' #fails since groups aren't specified by default
#' safetyGraphics:::checkRequired(key=list("groups",1,"value_col"),
#'                                       settings=testSettings) 
#' @keywords internal

checkRequired <- function(key, settings){
  stopifnot(typeof(key)=="list",typeof(settings)=="list")

  current <- list(key=key)
  current$text_key <-  paste( unlist(current$key), collapse='--')
  current$type<-"required"
  current$description <- "value for specified key found in settings?"
  current$value <- getSettingValue(key=key,settings=settings)
  if(is.null(current$value)){
    current$value <- "--No Value Given--"
    current$valid <- FALSE
    current$message <- paste0(current$text_key," not specified in settings.")
    return(current)
  }else{
    current$valid <- TRUE
    current$message <- ""
    return(current)
  }
}
