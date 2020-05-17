#' @title   mappingDomainUI 
#' @description  UI that facilitates the mapping of a full data domain
#'
#' @param meta metadata for the domain
#' @param data data file for the domain
#' @param mapping current data mapping
#' 
#' @export

mappingDomainUI <- function(id, meta, data, mapping=NULL){  
    ns <- NS(id)
    
    if(is.null(mapping)){
      keys<-unique(meta$text_key)
      mapping<-data.frame(
        text_key=keys, 
        current=rep("",length(keys)),
        stringsAsFactors=FALSE
      )
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
      current_meta <- meta %>% filter(col_key == col)
      ids<- unique(current_meta$text_key)
      current_mapping <- mapping %>% filter(text_key %in% ids)
      domain_ui[[i]] <- mappingColumnUI(ns(col), current_meta, data, current_mapping)
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
#' @return A reactive data frame containing the mapping for the domain
#'
#' @export

mappingDomain <- function(input, output, session, meta, data){
  col_ids <- unique(meta$col_key)
  names(col_ids)<-col_ids # so that lapply() creates a named list below
  col_modules <- col_ids %>% lapply(function(col){
    callModule(mappingColumn, col, meta%>%filter(col_key==col) ,data)
  })
 
 reactive({
    data<-data.frame()
    for(col in col_ids){
      data<-rbind(data, col_modules[[col]]())
    }
   return(data)
  })
}
  