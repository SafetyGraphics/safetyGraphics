#' Compare a settings object with a specified data set
#'
#' This function returns a list describing the validation status of a data set for a specified data standard
#'
#' @param data A data frame to check against the settings object
#' @param settings The settings list to compare with the data frame. 
#' @return A list containing the appropriate settings for the selected chart

validateSettings <- function(data, settings, chart="eDish"){
  settingStatus<-list()
  names<-names(data)  
  
  settingsShell <- generateSettings(standard="None")
  options <- names(shellSettings)
  dataOptions <- c(options[grep("_col",options)],"filters")
  settingStatus[["dataColumns"]] <- dataOptions %>% 
  map(function(option){
    return(list(
      option = option,
      value = settings[[option]],
      type = typeof(settings[[option]])
    ))
  })%>%
  map_if(
    function(optionList){
      return(optionList$type=="character")
    },
    function(optionList){
      optionList[["valid"]] <-optionList[["value"]] %in% names
      return(optionList)
    }
  )
  
  
    
  # Check that all columns in the setting object are found in the data frame
  allColumnsFound <- TRUE
  dataMappingSettings <- c("id_col","value_col","measure_col","normal_col_low","normal_col_high","study_day_col","") 
  columnsFromSettings <- c()
      
  # Check that field level data specified in the setting object is found in the data frame
  allFieldsFound <- TRUE
  dataFieldSettings <- c()
  fieldsFromSettings <- c()
  
  
  
  return (settingStatus)
}