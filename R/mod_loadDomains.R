#' @title   loadDataUI 
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param id module id
#' @param domains character vector with domains to be loaded
#' 
#' @export

loadDomainsUI <- function(id, domains){ 
  ns <- NS(id)
  ui <- domains %>% map(~loadDataUI(ns(.x), domain=.x))
}

#' @title   loadDataServer
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param domains List of data domains to be loaded

#' @export
loadDomains <- function(input, output, session, domains) {
  names(domains) <-domains #so that lapply will create a named list
  domainModules <- domains %>% lapply(function(domain){
      callModule(loadData,domain, domain=domain)
  })
  reactive({
    domainData <- list()
    for(domain in domains){
      domainData[[domain]] <- domainModules[[domain]]()
    }
    return(domainData)
  })
}
