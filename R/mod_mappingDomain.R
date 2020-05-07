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
    domain_ui <- list()
    cols <- unique(meta$col_key)
    for(i in 1:length(cols)){
      col <- cols[i]
      current_meta <- meta %>% filter(col_key == col)
      domain_ui[[i]] <- mappingColumnUI(ns(col), current_meta, data)
    }
    return(domain_ui)
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
  col_ids <- unique(meta$col_key)
  names(col_ids)<-col_ids # so that lapply() creates a named list below
  col_modules <- col_ids %>% lapply(function(col){
    callModule(mappingColumn, col, meta%>%filter(col_key==col) ,data)
  })
 
 reactive({
   shell <- list()
    for(col in col_ids){
      shell<-c(shell, col_modules[[col]]())
    }
   return(shell)
  })
}
  