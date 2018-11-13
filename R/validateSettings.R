#' Compare a settings object with a specified data set
#'
#' This function returns a list describing the validation status of a data set for a specified data standard
#'
#' This function returns a list describing the validation status of a settings/data combo for a given chart type. This list can be used to populate status fields and control workflow in the Shiny app. It could also be used to manually QC a buggy chart. The tool checks that all setting properties containing "_col" match columns in the data set via \code{checkColumnSettings},  and all properties contianing "_values" match fields in the data set via \code{checkFieldSettings}. 
#'
#' @param data A data frame to check against the settings object
#' @param settings The settings list to compare with the data frame. 
#' @param chart  The chart type being created ("eDish" only for now)
#' @return 
#' A list describing the validation state for the data/settings combination. The returned list has the following properties:
#'- `valid` - boolean indicating whether the settings/data combo creates a valid chart
#'- `status` - a string summarizing of the validation results
#'- `checkList` - list of lists giving details about checks performed on individual setting specifications. Each embedded item has the following properties: 
#'  - `key` - a list specifying the position of the property being checked. For example, `list("group_cols",1,"value_col")` corresponds to `settings[["group_cols"]][[1]][["value_col"]]`
#'  - `text_key` - list from `key` parsed to character with a "|" separator. 
#'  - `value` - value of the setting
#'  - `check` - description of the check performed.
#'  - `valid` - a boolean indicating whether the check was passed
#'  - `message` - a string describing failed checks (where `valid=FALSE`). returns an empty string when `valid==TRUE`
#'  
#'  @examples 
#'  testSettings <- generateSettings(standard="adam")
#'  validateSettings(data=adlbc, settings=testSettings) # .$valid is TRUE
#'  testSettings$id_col <- "NotAColumn"
#'  validateSettings(data=adlbc, settings=testSettings) # .$valid is now FALSE
#' @export
#' @importFrom purrr map
#' @import dplyr


validateSettings <- function(data, settings, chart="eDish"){
  
  settingStatus<-list()
  
  # Check that all required parameters are not null
  requiredChecks <- getRequiredSettings(chart = chart) %>% map(checkSettingProvided, settings = settings)
  
  #Check that non-null setting columns are found in the data
  columnChecks <- getSettingKeys(patterns="_col",settings=settings) %>% map(checkColumnSetting, settings=settings, data=data)
  
  #Check that specified field/column combinations are found in the data
  fieldChecks <- getSettingKeys(patterns="_values",settings=settings, matchLists=TRUE) %>% map(checkFieldSettings, settings=settings, data=data )
  fieldChecks_flat <- unlist(fieldChecks, recursive=FALSE)
  
  #Combine different check types in to a master list
  settingStatus$checkList<-c(requiredChecks, columnChecks, fieldChecks_flat)
  
  #valid=true if all checks pass, false otherwise 
  settingStatus$valid <- settingStatus$checkList%>%map_lgl(~.x[["valid"]])%>%all 
  
  #create summary string
  failCount <- settingStatus$checkList%>%map_dbl(~!.x[["valid"]])%>%sum
  checkCount <- length(settingStatus$checkList)
  settingStatus$status <- paste0(failCount," of ",checkCount," checks failed.")
  return (settingStatus)
}

