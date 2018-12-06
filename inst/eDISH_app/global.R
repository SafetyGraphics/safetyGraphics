# temporarily load deps
library(tidyverse)
library(safetyGraphics)

# # temporarily source the functions
source('../../R/checkColumnSetting.R')
source('../../R/checkFieldSettings.R')
source('../../R/detectStandard.R')
source('../../R/generateSettings.R')
source('../../R/getSettingKeys.R')
source('../../R/getSettingValue.R')
source('../../R/validateSettings.R')
source('../../R/compare_cols.R')
source('../../R/getRequiredColumns.R')
source('../../R/getRequiredSettings.R')
source('../../R/checkSettingProvided.R')

## source modules
 source('modules/renderSettings.R')   



validateSettings2 <- function(data, settings, chart="eDish"){
  
  settingStatus<-list()
  
  # Check that all required parameters are not null
  requiredChecks <- getRequiredSettings(chart = chart) %>% map(checkSettingProvided, settings = settings)
  
  #Check that non-null setting columns are found in the data
  columnChecks <- getSettingKeys(patterns="_col",settings=settings) %>% map(checkColumnSetting, settings=settings, data=data)
  
  #Check that specified field/column combinations are found in the data
  # fieldChecks <- getSettingKeys(patterns="_values",settings=settings, matchLists=TRUE) %>% map(checkFieldSettings, settings=settings, data=data )
  # fieldChecks_flat <- unlist(fieldChecks, recursive=FALSE)
  
  #Combine different check types in to a master list
  settingStatus$checkList<-c(requiredChecks, columnChecks) #, fieldChecks_flat)
  
  #valid=true if all checks pass, false otherwise 
  settingStatus$valid <- settingStatus$checkList%>%map_lgl(~.x[["valid"]])%>%all 
  
  #create summary string
  failCount <- settingStatus$checkList%>%map_dbl(~!.x[["valid"]])%>%sum
  checkCount <- length(settingStatus$checkList)
  settingStatus$status <- paste0(failCount," of ",checkCount," checks failed.")
  return (settingStatus)
}