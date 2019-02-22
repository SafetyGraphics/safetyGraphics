createControl <- function(key, metadata, data, settings, ns){
  
  sm_key <- filter(metadata, text_key==key)
  
  tt_msg <- paste0("tt_msg_", key)
  msg <- paste0("msg_", key)   
  
  ### get metadata for the input
  setting_key <- as.list(strsplit(key,"\\-\\-"))
  setting_value <- safetyGraphics:::getSettingValue(key=setting_key, settings=settings)
  setting_label <- createSettingLabel(key)
  setting_description <- getSettingsMetadata(text_keys=key, cols="description")
  
  ### if a field-level input, get metadata about the parent column-level input
  field_column <- NULL
  field_column_label <- NULL
  if (!is.null(sm_key$field_column_key)){
    field_column <- safetyGraphics:::getSettingValue(key=list(sm_key$field_column_key), settings=settings)
    field_column_label <- getSettingsMetadata(text_key = sm_key$field_column_key, cols = "label")
  }
  
  
  ### get the choices for the selectors
  value <- NULL
  choices <- NULL
  placeholder <- NULL
  if(sm_key$column_mapping==TRUE){
    if(is.null(setting_value)){
      choices <- colnames(data)
      placeholder <- list(
        onInitialize = I('function() {
                         this.setValue("");}'))
  } else{
    choices <- unique(c(setting_value, colnames(data)))
    placeholder <- list (onInitialize = I('function() { }'))
    }
  } else if (sm_key$field_mapping==TRUE){
    if(is.null(field_column)){   ## if there is NOT a column specified in settings
      placeholder <- list(
        placeholder = paste0("Please select a ", field_column_label),
        onInitialize = I('function() {
                         this.setValue("");}'))
  } else{                      ## if there is a column specified in settings                       
    choices <- unique(c(setting_value, as.character(data[,field_column]))) %>% unlist
    placeholder <- list (onInitialize = I('function() { }'))
    }
  } else if (sm_key$setting_type=="vector"){
    choices <- setting_value   ### this is meant to cover the scenario for x_options/y_options. But we have 
    # nowhere to grab "choices" from.  Here we are just saying that choices=selected=setting_value 
  }  
  
  
  
  ### create code for the UI
  if (sm_key$column_mapping==TRUE | sm_key$field_mapping==TRUE){
    
    multiple <- (sm_key$setting_type=="vector")
    
    div(
      span(title = setting_description, tags$label(HTML(setting_label))),
      span(id = ns(tt_msg), title = "", tags$label(id = ns(msg), "")),
      selectizeInput(inputId = ns(key), label = NULL, choices = choices, options = placeholder, multiple = multiple)
    )  
  } else if (sm_key$setting_type=="vector"){
    
    div(
      span(title = setting_description, tags$label(HTML(setting_label))),
      span(id = ns(tt_msg), title = "", tags$label(id = ns(msg), "")),
      selectizeInput(inputId = ns(key), label = NULL, choices = choices, selected = choices, multiple = TRUE)
    ) 
    
  } else if (sm_key$setting_type=="numeric"){
    div(
      div(title = setting_description, tags$label(HTML(setting_label))),
      sliderInput(inputId = ns(key), label = NULL, value=setting_value, min=0, max=50)
    )
  } else if (sm_key$setting_type=="logical"){
    div(
      div(title = setting_description, tags$label(HTML(setting_label))),
      checkboxInput(inputId = ns(key), label = NULL, value=setting_value)
    )
  } else if (sm_key$setting_type=="character"){
    div(
      div(title = setting_description, tags$label(HTML(setting_label))),
      textAreaInput(inputId = ns(key), label = NULL, value = setting_value)
    )
  }
}