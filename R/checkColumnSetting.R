checkColumnSetting <- function(key, settings, data){
  validCols <- names(data)
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
