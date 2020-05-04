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
          col_ui[[i]] <- mappingSelectUI(ns(row$text_key), row$label, names(data))  
        }else{
          col_ui[[i]] <- div(class="field-wrap",mappingSelectUI(ns(row$text_key), row$label))
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
  ns <- session$ns
  
  col_meta <- meta %>% filter(type=="column")
  field_meta <- meta %>% filter(type=="field")
  col_val <- callModule(mappingSelect, col_meta$text_key)
  field_options <- reactive(
    ifelse(col_val()=="", list(""), unique(data[,col_val()]))
  )
  # change the options in the field selects when the column select changes 
  if(nrow(field_meta)>0){
    field_ids <- unique(field_meta$text_key)
    names(field_ids)<-field_ids # so that lapply() creates a named list below
    field_vals<-lapply(field_ids, function(field_id){
      callModule(mappingSelect,field_id)
    })
    print(field_vals)
    observe({
      for(field_id in field_ids){
        updateSelectizeInput(
          session,
          inputId = paste0(field_id,"-colSelect"),
          choices = field_options()[[1]]
        )      
      }    
    })
  }
  

  # return the values for all fields as a list   
  meta <- reactive({
    shell<-list()
    shell[col_meta$text_key]<- col_val()
    if(nrow(field_meta)>0){
      for(field_id in field_ids){
        shell[field_id] <- field_vals[[field_id]]()
      }
    }
    return(shell)
  })
  
  return(meta)
  
}
