#' Compare a settings object with a specified data set
#'
#' This function returns a list describing the validation status of a data set for a specified data standard
#'
#' @param data A data frame to check against the settings object
#' @param settings The settings list to compare with the data frame. 
#' @return A list containing the appropriate settings for the selected chart

validateSettings <- function(data, settings, chart="eDish"){
  
  checkColumnSetting <- function(key){
    current <- list(key=key)
    current$text_key <-  paste( unlist(current$key), collapse='|')
    current$check <- "'_col' parameter from setting setting found in data?"
    current$value <- getSettingValue(key=key,settings=settings)
    if(is.null(current$value)){
      current$value <- "--No Value Given--"
      current$valid <- TRUE
      current$message <- ""
      return(current)
    }else{
      current$valid <- current$value %in% validCols
      current$message <- ifelse(current$valid,"",paste0(current$value," column not found in data."))
      return(current)        
    }
  }
  
  
  settingStatus<-list()
  
  #Check that non-null setting columns are found in the data
  validCols <- names(data)
  columnChecks <- getSettingKeys(patterns="_col",settings=settings) %>% map(checkColumnSetting)
  
  #Combine different check types in to a master list
  settingStatus$checkList<-c(columnChecks)
  
  #valid=true if all checks pass, false otherwise 
  settingStatus$valid <- settingStatus$checkList%>%map_lgl(~.x[["valid"]])%>%all 
  
  #create summary string
  failCount <- settingStatus$checkList%>%map_dbl(~!.x[["valid"]])%>%sum
  checkCount <- length(settingStatus$checkList)
  settingStatus$status <- paste0(failCount," of ",checkCount," checks failed.")
  return (settingStatus)
}

