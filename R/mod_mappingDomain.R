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
   
    selectList <- list()
    i<-1
    
    #make a select for each row in the metadata
    cols <- unique(meta$col_key)
   
    for(col in cols){
      current_df <- meta %>% filter(col_key == col)
      column_df <- current_df %>% filter(type=="column")
      field_df <- current_df %>% filter(type=="field")

      # initialize column select
      # todo - create mappingColumnUI module, that deals with field level mapping for each column
      selectList[[i]]<-mappingSelectUI(column_df$col_key, column_df$label, names(data))
      i<-i+1
   }

   selectList
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

mappingDomain <- function(input, output, session, meta){
  
  print(head(meta))
  #return a dataframe containing the current mapping
  allSelects <- unique(meta$col_key) %>% map(callModule,module=mappingSelect, id=.)
  browser()
  
  mapping <- eventReactive(
    allSelects,
    {}
  )

  mapping
}
