#' @title   mappingColumnUI 
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param meta metadata for the column (and related fields)
#' @param data current data file for the domain
#' @param mapping current data mapping for the column (and related fields)
 
#' @export

mappingColumnUI <- function(id, meta, data, mapping=NULL){  
    ns <- NS(id)
    col_ui <- list()
    
    # todo pass value from mapping (if any)
    for(i in 1:nrow(meta)) {
        row <- meta[i,]
        if(row$type=="column"){
          col_ui[[i]] <- mappingSelectUI(row$text_key, row$label, names(data))  
        }else{
          col_ui[[i]] <- div(class="field-wrap",mappingSelectUI(row$text_key, row$label))
        }
    }
    col_ui
}

#' @title  mappingColumn
#' @description  server function that facilitates the mapping of a single data element (column of field) with a simple select UI
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' 
#' @return A reactive containing the selected column
#'
#' @export

mappingColumn <- function(input, output, session, meta, data){
  col_meta <- meta %>% filter(type=="column")
  field_meta <- meta %>% filter(type=="field")
  
  # change the options in the field selects when the column select changes 
  col_val <- callModule(mappingSelect, col_meta$text_key)
  observeEvent( col_val, {
    print(col_val())
  })
  
  
  # return the values for all fields as a df or list 
  
#   print(head(meta))
#   #return a dataframe containing the current mapping
#   allSelects <- unique(meta$col_key) %>% map(callModule,module=mappingSelect, id=.)
#   browser()
  
#   mapping <- eventReactive(
#     allSelects,
#     {}
#   )

#   mapping
}
