#' Compare a settings object with a specified data set
#'
#' This function returns a list describing the validation status of a data set for a specified data standard
#'
#' @param data A data frame to check against the settings object
#' @param settings The settings list to compare with the data frame. 
#' @return A list containing the appropriate settings for the selected chart

validateSettings <- function(data, settings, chart="eDish"){
  
  settingStatus<-list()
  
  #Check that non-null setting columns are found in the data
  columnChecks <- getSettingKeys(patterns="_col",settings=settings) %>% map(checkColumnSetting, settings=settings, data=data)
  
  #Check that specified field/column combinations are found in the data
  fieldChecks <- getSettingKeys(patterns="_values",settings=settings, matchLists=TRUE) %>% map(checkFieldSettings, settings=settings, data=data )
  fieldChecks_flat <- unlist(fieldChecks, recursive=FALSE)
  
  #Combine different check types in to a master list
  settingStatus$checkList<-c(columnChecks, fieldChecks_flat)
  
  #valid=true if all checks pass, false otherwise 
  settingStatus$valid <- settingStatus$checkList%>%map_lgl(~.x[["valid"]])%>%all 
  
  #create summary string
  failCount <- settingStatus$checkList%>%map_dbl(~!.x[["valid"]])%>%sum
  checkCount <- length(settingStatus$checkList)
  settingStatus$status <- paste0(failCount," of ",checkCount," checks failed.")
  return (settingStatus)
}

