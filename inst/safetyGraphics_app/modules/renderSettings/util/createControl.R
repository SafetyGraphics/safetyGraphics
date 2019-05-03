#' Create setting control 
#'
#' Workflow:
#' (1) Get setting label and description from metadata
#' (2) Get setting value from settings object
#' (3) Get choices and placeholder text for the selectors based on metadata, data, and settings
#' (4) Create HTML code for the selector based on the following metadata:
#'     - whether the option is a column or field-level input
#'     - data type of the setting (e.g. character/numeric/logical, vector of length 1 vs >1) 
#'     - label, description, choices, selected value, placeholder text
#' 
#' @param key A character key representing the setting of interest  
#' @param metadata Metadata data frame to be queried for information about the setting
#' @param data A data frame to be used to populate control options
#' @param settings A settings list to be used to populate control options
#' @param ns  The namespace of the current module
#'
#' @return HTML code for the div containing the setting of interest
createControl <- function(key, metadata, data, settings, ns){
  
  sm_key <- filter(metadata, text_key==key)
  ctl_id <- paste0("ctl_", key)
  tt_msg <- paste0("tt_msg_", key)
  msg <- paste0("msg_", key)   
  
  
  ## of the selected charts, which ones are relevant to the given setting?
  charts_rel <- select(sm_key, starts_with("chart_")) %>% 
    gather(chart, val) %>% 
    filter(val) %>% 
    mutate(chart = stringr::str_remove(chart, "chart_")) %>% 
    left_join(chartsMetadata, by="chart") %>% 
    pull(label)
  
  
  
  ### get metadata for the input
  setting_key <- as.list(strsplit(key,"\\-\\-"))
  setting_value <- safetyGraphics:::getSettingValue(key=setting_key, settings=settings)
  setting_label <- createSettingLabel(key)
  setting_description <- getSettingsMetadata(text_keys=key, cols="description")
  setting_required <- ifelse(getSettingsMetadata(text_keys=key, cols="setting_required"),"\nSetting Required","\nSetting Optional")
  
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
  
  if(sm_key$column_mapping==TRUE & is.null(setting_value)){ #column mapping - no value specified
      choices <- colnames(data)
      placeholder <- list(onInitialize = I('function() {this.setValue("");}'))
  } else if(sm_key$column_mapping==TRUE & !is.null(setting_value)) { #column mapping - value specified
      choices <- unique(c(setting_value, colnames(data)))
      placeholder <- list (onInitialize = I('function() { }'))
  } else if (sm_key$field_mapping==TRUE & is.null(field_column)){ ## if there is NOT a column specified in settings
      placeholder <- list(
        placeholder = paste0("Please select a ", field_column_label),
        onInitialize = I('function() {
                         this.setValue("");}')
      )
  } else if (sm_key$field_mapping==TRUE & !is.null(field_column)){ ## if there is NOT a column specified in settings
    choices <- unique(c(setting_value, sort(as.character(data[,field_column])))) %>% unlist
    placeholder <- list (onInitialize = I('function() { }'))
  } else if (sm_key$setting_type=="vector"){
    choices <- setting_value   ### this is meant to cover the scenario for x_options/y_options 
  }  
  
  ### create code for the UI
  multiple <- (sm_key$setting_type=="vector")
 
  if (sm_key$column_mapping==TRUE | sm_key$field_mapping==TRUE){
    input <- selectizeInput(inputId = ns(key), label = NULL, choices = choices, options = placeholder, multiple = multiple)
  } else if (sm_key$setting_type=="vector"){
    input <- selectizeInput(inputId = ns(key), label = NULL, choices = choices, selected = choices, multiple = TRUE)
  } else if (sm_key$setting_type=="numeric"){
    input <- sliderInput(inputId = ns(key), label = NULL, value=setting_value, min=0, max=50)  
  } else if (sm_key$setting_type=="logical"){
    input <- checkboxInput(inputId = ns(key), label = NULL, value=setting_value)
  } else if (sm_key$setting_type=="character"){
    input <-textAreaInput(inputId = ns(key), label = NULL, value = setting_value)  
  }
  
  div(
    class="control-wrap",
    id=ns(ctl_id),
    span(title = paste0(setting_description," ",setting_required), tags$label(HTML(setting_label))),
    span(class="num_charts", 
         title = HTML(paste0(charts_rel, collapse="\n")), 
         tags$label(paste0("(", length(charts_rel), ")"))),
    div(
      class="select-wrap",
      input,
      div(id = ns(tt_msg), title = "", tags$label(id = ns(msg), ""), class="status")
    )
  )  
}