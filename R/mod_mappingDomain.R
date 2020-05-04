#' @title   mappingDomainUI 
#' @description  UI that facilitates the mapping of a full data domain
#'
#' @param meta metadata for the domain
#' @param data current data file for the domain
#' @param mapping current data mapping
#' 
#' @export

mappingDomainUI <- function(id, meta, data, mapping=NULL){  
    ns <- NS(id)
    #make a select for each row in the metadata
    unique(meta$col_key) %>% lapply(function(col){
      current_meta <- meta %>% filter(col_key == col)
      #print(current_meta)
      return(mappingColumnUI(ns(col), current_meta, data))
    })
}


#' @title  mappingSelect
#' @description  server function that facilitates the mapping of a single data element (column of field) with a simple select UI
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' 
#' @return A reactive containing the selected column
#'
#' @export

mappingDomain <- function(input, output, session, meta, data){
 reactive({
    unique(meta$col_key)%>%
      lapply(function(col){
        mod<-callModule(mappingColumn, col, meta%>%filter(col_key==col), data)
        return(mod())
      })
  })
}
