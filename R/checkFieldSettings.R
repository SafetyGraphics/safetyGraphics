#' Check that a setting parameter has a matching data field
#'
#' Checks that a single parameter from the settings list matches a field value in a specified data set
#'
#' This function compares settings with field values as part of the \code{validateSettings()} function. More specifically, the function checks whether the \code{fieldKey} in a \code{settings} object matches a column/field combination in \code{"data"}. The function makes 2 major assumptions about the structure of the settings object. First, it assumes that the first value in fieldKey is "settingName_values" and there is a corresponding "settingName_col" setting that defines the column to search for field-level data. Second, it expects that the value specified by key/settings is a list, and that each value in the list is a field of the variable above.
#'
#' @param fieldKey a list (like those provided by \code{getSettingKeys())} defining the position of parameter in the settings object.
#' @param settings The settings list used to generate a chart like \code{eDISH()}
#' @param data A data frame to check for the specified field
#' @return A list containing the results of the check following the format specified in \code{validateSettings()[["checkList"]]}
#'
#'
#' #' @examples
#' testSettings<-generateSettings(standard="AdAM")
#' checkFieldSettings(fieldKey=list("measure_values"),settings=testSettings, adlbc) #list of 4 checks. all pass ($valid ==TRUE)
#' @importFrom stringr str_split
#' @importFrom magrittr "%>%"
#' @importFrom purrr map 
#'
checkFieldSettings <- function(fieldKey, settings, data){

  # compare the fields in the settings to the fields in the data.
  fieldCheck <- function(key){
    function(key){
      current <- list()
      current$key<-fieldKey
      nextKey<-length(current$key)+1
      current$key[[nextKey]]<-key

      current$text_key <-  paste( unlist(current$key), collapse='--')
      current$check <- "'_values' field from setting found in data?"
      current$value <- getSettingValue(key=current$key,settings=settings)
      if(is.null(current$value)){
        current$value <- "--No Value Given--"
        current$valid <- TRUE
        current$message <- ""
        return(current)
      }else if(!columnSpecified){
        current$valid<-FALSE
        current$message<-paste0("No column for ",columnKey," found in settings.")
      }else{
        current$valid <- current$value %in% validFields
        current$message <- ifelse(current$valid,"",paste0(current$value," field not found in the ",columnName," column"))
        return(current)
      }
    }
  }


  stopifnot(typeof(fieldKey)=="list", typeof(settings)=="list")

   # get a list of all of the column's values from the data
  key_base<-stringr::str_split(fieldKey, "_")[[1]][1]   # get the name of the column containing the fields(e.g. fields = "measure_values" -> column = "measure_col")
  columnKey<-getSettingKeys(patterns=paste0(key_base,"_col") ,settings=settings)[[1]]
  columnName<-getSettingValue(key=columnKey, settings=settings) # get the name of the column from the value associated with columnKey
  columnSpecified <- is.character(columnName)
  if(columnSpecified){
    validFields <- unique(data[[columnName]])
  } else{
    validFields <- c()
  }

  # get a list of fields from the settings object
  fieldList<-getSettingValue(key=fieldKey, settings=settings)

  if(typeof(fieldList)=="list"){
    fieldChecks <- fieldList %>% names %>% purrr::map(fieldCheck(key))
  } else {
    current <- list()
    current$key<-fieldKey
    current$check <- "'_values' field from setting found in data?"
    current$text_key <-  paste( unlist(current$key), collapse='--')
    current$value <- NULL
    current$valid <- FALSE
    current$message <- "No list of values found in settings."
    fieldChecks <- list(current)
  }
  return(fieldChecks)
}
