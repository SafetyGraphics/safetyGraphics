#' Check that settings for mapping numeric data are associated with numeric columns
#'
#' Check that settings for mapping numeric data are associated with numeric columns
#'
#' @param key a list (like those provided by \code{getSettingKeys())} defining the position of parameter in the settings object.
#' @param settings The settings list used to generate a chart like \code{eDISH()}
#' @param data A data frame to check for the specified numeric column
#' @return A list containing the results of the check following the format specified in \code{validateSettings()[["checkList"]]}
#'
#' @examples
#' testSettings<-generateSettings(standard="AdAM")
#' #pass ($valid == FALSE)
#' safetyGraphics:::checkNumeric(key=list("id_col"),settings=testSettings, data=adlbc)
#'
#' #pass ($valid == TRUE)
#' safetyGraphics:::checkNumeric(key=list("value_col"),settings=testSettings, data=adlbc)
#'
#' @keywords internal

checkNumeric <- function(key, settings, data){
  stopifnot(typeof(key)=="list",typeof(settings)=="list")

  current <- list(key=key)
  current$text_key <-  paste( unlist(current$key), collapse='--')
  current$type <- "numeric"
  current$description <- "specified column is numeric?"
  current$value <- getSettingValue(key=key,settings=settings)
  if(is.null(current$value)){
    current$value <- "--No Value Given--"
    current$valid <- TRUE
    current$message <- ""
  }else if(!hasColumn(current$value,data)){
    current$value <- "--Column not found--"
    current$valid <- TRUE
    current$message <- ""
  }else{
    #check to see if the specified column contains numeric values
    values<- data[[current$value]]
    characterValues<- as.character(values)
    numericValues<- suppressWarnings(as.numeric(characterValues))
    nonNumericCount <- sum(is.na(numericValues))
    totalCount <- length(values)
    percentNonNumeric<-nonNumericCount/totalCount
    current$valid <- percentNonNumeric < 0.5
    current$message <- paste0(nonNumericCount," of ", totalCount," values were not numeric.")
    if(nonNumericCount>0){current$message<-paste0(current$message, " Records with non-numeric values may not appear in the graphic.")}
  }
  return(current)
}
