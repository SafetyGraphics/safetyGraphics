#' @title  UI that facilitates the mapping of a full data domain
#'
#' @param id module id
#' @param meta metadata for the domain
#' @param data data file for the domain
#' @param mapping current data mapping
#' 
#' @export

mappingDomainUI <- function(id, meta, data, mapping=NULL){
    ns <- NS(id)
    if(is.null(mapping)){
      mapping<-unique(meta[,c('text_key')]) %>% mutate(current="")
    }
    
    #all inputs should be data frames  
    stopifnot(
      is.data.frame(meta), 
      is.data.frame(data), 
      is.data.frame(mapping),
      is.character(mapping$text_key),
      is.character(meta$text_key)
    )

    #make a select for each row in the metadata
    domain_ui <- list()
    cols <- unique(meta$col_key)
    for(i in 1:length(cols)){
      col <- cols[i]
      current_meta <- meta %>% filter(.data$col_key == col)
      ids<- unique(current_meta$text_key)
      current_mapping <- mapping %>% filter(.data$text_key %in% ids)
      domain_ui[[i]] <- mappingColumnUI(ns(col), current_meta, data, current_mapping)
    }
    return(domain_ui)
}


#' @title  Server that facilitates the mapping of a full data domain
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param meta metadata for the domain
#' @param data clinical data for the domain
#' 
#' @return A reactive data frame containing the mapping for the domain
#'
#' @export

mappingDomain <- function(input, output, session, meta, data){
  col_ids <- unique(meta$col_key)
  names(col_ids)<-col_ids # so that lapply() creates a named list below
  col_modules <- col_ids %>% lapply(function(col){
    callModule(mappingColumn, col, meta%>%filter(.data$col_key==col) ,data)
  })
 
  reactive({
    data<-data.frame()
    for(col in col_ids){
      data<-rbind(data, col_modules[[col]]())
    }
    return(data)
  })
}
  