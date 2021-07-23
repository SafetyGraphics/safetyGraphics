#' Convert mapping data.frame to a list
#'
#' @param settingsDF data frame containing current mapping
#' @param domain mapping domain to return (returns all domains as a named list by default) 
#' @param pull call pull() the value for each parameter - needed for testing only. default: FALSE
#' 
#' @importFrom stringr str_split 
#' @export

generateMappingList <- function(settingsDF, domain=NULL, pull=FALSE){
  settingsList <- list()
  
  settingsDF$domain_key <- paste0(settingsDF$domain, "--", settingsDF$text_key)
  domain_keys <- settingsDF$domain_key %>% textKeysToList()
  
  settingsList<-list()
  for (i in 1:length(domain_keys) ) {
    settingsList<-setMappingListValue(
      key=domain_keys[[i]],
      value=ifelse(pull, settingsDF[i,"current"]%>%pull(), settingsDF[i,"current"]), 
      settings=settingsList,
      forceCreate=TRUE
    )
  }

  if(is.null(domain)){
    return(settingsList)
  }else{
    return(settingsList[[domain]])
  }
}