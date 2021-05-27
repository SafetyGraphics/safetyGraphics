#' @title   loadDataUI 
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param id module id
#' @param domains character vector with initial domains to be loaded
#' 
#' @export

loadDomainsUI <- function(id){ 
  ns <- NS(id)
  uiOutput(ns("loader"))
}

#' @title   loadDataServer
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param domains List of data domains to be loaded {reactive}

#' @export
loadDomains <- function(input, output, session, domains) {
  ns <- session$ns
  
  # Hack to avoid multiple modal triggers   
  domainIDs <- reactive({
    ids<-domains() %>% map_chr(~paste0(.x,floor(runif(1,.1,1)*10e6)))
    names(ids)<-domains()
    return(ids)
  })

  output[["loader"]] <- renderUI({
    domainIDs() %>% map(~loadDataUI(session$ns(.x), domain=substr(.x,0,nchar(.x)-7)))
  })

  domainData <- reactive({  
    domainIDs() %>% map(function(domainID){
      domain <- substr(domainID,0,nchar(domainID)-7)
      imported<-callModule(loadData, domainID, domain=domain)
      return(imported$data)
    })
  })

  return(domainData)
}
