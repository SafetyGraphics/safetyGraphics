#' Convert mapping data.frame to a list
#'
#' @param mappingDF data frame containing current mapping
#' @param domain mapping domain to return (returns all domains as a named list by default)
#' 
#' @importFrom stringr str_split 
#' @export

generateMappingList <- function(settingsDF, domain=NULL){
  settingsList <- list()
  
  settingsDF$domain_key <- paste0(settingsDF$domain, "--", settingsDF$text_key)
  domain_keys <- settingsDF$domain_key %>% textKeysToList()
  
  settingsList<-list()
  for (i in 1:length(domain_keys) ) {
    settingsList<-setMappingListValue(
      key=domain_keys[[i]],
      value=settingsDF[i,"current"],#%>%pull(), 
      settings=settingsList,
      forceCreate=TRUE
    )
  }
  
  if(!is.null(domain)){
    return(settingsList[[domain]])
  }else{
    return(settingsList)
  }
}