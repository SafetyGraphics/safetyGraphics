#' @title   mappingColumnUI 
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param id module id
#' @param meta metadata for the column (and related fields)
#' @param data current data file for the domain
#' @param mapping current data mapping for the column (and related fields)

#' @export

mappingColumnUI <- function(id, meta, data, mapping=NULL){  
    ns <- NS(id)
    col_ui <- list()
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
    
    #merge default values from mapping on to full metadata
    meta <- meta %>% left_join(mapping, by="text_key")
    col_meta <- meta %>% filter(type=="column")
    
    # Exactly one column mapping provided
    stopifnot(nrow(col_meta)==1)
    
    col_ui[[1]] <- mappingSelectUI(
      ns(col_meta$text_key), 
      col_meta$label, 
      names(data), 
      col_meta$current
    )  
    
    fieldOptions<-NULL
    if(col_meta$current %in% names(data)){
      fieldOptions <-  unique(data%>%pull(col_meta$current))       
    }
    
    field_meta <- meta %>% filter(type=="field")
    if(nrow(field_meta)>0){
      for(i in 1:nrow(field_meta)) {
        row <- field_meta[i,]
        col_ui[[i+1]] <- div(
          class="field-wrap",
          mappingSelectUI(
            ns(row$text_key), 
            row$label,
            fieldOptions,
            row$current
          )
        )
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
#' @param meta metadata data frame for the object
#' @param data current data file for the domain
#' 
#' @return A reactive data.frame providing the current value for text_key associated with the selected column
#'
#' @export

mappingColumn <- function(input, output, session, meta, data){
  ns <- session$ns
  
  col_meta <- meta %>% filter(type=="column")
  field_meta <- meta %>% filter(type=="field")
  col_val <- callModule(mappingSelect, col_meta$text_key)
  
  # change the options in the field selects when the column select changes 
  if(nrow(field_meta)>0){
    field_ids <- unique(field_meta$text_key)
    names(field_ids)<-field_ids # so that lapply() creates a named list below
    field_vals<-lapply(field_ids, function(field_id){
      callModule(mappingSelect,field_id)
    })
    observeEvent(col_val() ,{
      field_options <- ifelse(col_val()=="", list(""), unique(data[,col_val()]))
      for(field_id in field_ids){
        current <- field_vals[[field_id]]()
        updateSelectizeInput(
          session,
          inputId = paste0(field_id,"-colSelect"),
          choices = field_options[[1]],
          selected = current 
        )      
      }    
    })
  }
  
  # return the values for all fields as a data.frame   
  meta <- reactive({
    col_meta <- data.frame(text_key = col_meta$text_key, current=col_val())
    if(nrow(field_meta)>0){
      for(field_id in field_ids){
        field_meta <- data.frame(text_key = field_id,  current=field_vals[[field_id]]())
        col_meta<-rbind(col_meta, field_meta)
      }
    }
    return(col_meta)
  })
  
  return(meta)
  
}
