checkFieldSettings <- function(fieldKey, settings, data){
  stopifnot(typeof(fieldKey)=="list", typeof(settings)=="list")
  
   # get a list of all of the column's values from the data 
  key_base<-str_split(fieldKey, "_")[[1]][1]   # get the name of the column containing the fields(e.g. fields = "measure_values" -> column = "measure_col")
  columnKey<-getSettingKeys(patterns=paste0(key_base,"_col") ,settings=settings)[[1]]
  columnName<-getSettingValue(key=columnKey, settings=settings) # get the name of the column from the value associated with columnKey 
  validFields <- unique(data[[columnName]])
  
  # get a list of fields from the settings object
  fieldList<-getSettingValue(key=fieldKey, settings=settings)   # save the value for the  measureKey as measureList 
  stopifnot(typeof(fieldList)=="list")   # save the value for the  measureKey as measureList 

  # compare the fields in the settings to the fields in the data. 
  fieldChecks <- fieldList %>% names %>% map(function(key){
    current <- list()
    current$key<-fieldKey
    nextKey<-length(current$key)+1
    current$key[[nextKey]]<-key

    current$text_key <-  paste( unlist(current$key), collapse='|')
    current$check <- "'_values' field from setting found in data?"
    current$value <- getSettingValue(key=current$key,settings=settings)
    if(is.null(current$value)){
      current$value <- "--No Value Given--"
      current$valid <- TRUE
      current$message <- ""
      return(current)
    }else{
      current$valid <- current$value %in% validFields
      current$message <- ifelse(current$valid,"",paste0(current$value," field not found in the ",columnName," column"))
      return(current)        
    }
  }) 

  return(fieldChecks)        
}