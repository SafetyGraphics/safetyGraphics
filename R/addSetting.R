#' Adds a new setting for use in the safetyGraphics shiny app
#'
#' This function updates settings objects to add a new setting parameter to the safetyGraphics shiny app
#'
#' This function makes it easy for users to adds a new settings to the safetyGraphics shiny app by making updates to the underlying metadata used by the package. Specifically, the function adds a row to settingsMetadata.rda describing the setting.
#'
#' @param domain data domain for the setting
#' @param text_key Text key indicating the setting name. \code{'--'} delimiter indicates a nested setting
#' @param label Label
#' @param description Description
#' @param setting_type Expected type for setting value. Should be "character", "vector", "numeric" or "logical"
#' @param setting_required Flag indicating if the setting is required
#' @param column_mapping Flag indicating if the setting corresponds to a column in the associated data
#' @param column_type Expected type for the data column values. Should be "character","logical" or "numeric"
#' @param field_mapping Flag indicating whether the setting corresponds to a field-level mapping in the data
#' @param field_column_key Key for the column that provides options for the field-level mapping in the data
#' @param setting_cat Setting category (data, measure, appearance)
#' @param default Default value for non-data settings
#' @param charts Character vector of charts using this setting
#' @param metadataLocation Path where the custom settings will be loaded/saved. 
#' @param overwrite Overwrite any existing setting metadata? Note that having settings with the same name is not supported and will cause unexpected results. default = true
#' 
#' @export
#'

addSetting<-function(
  domain,
  text_key,
  label,
  description,
  setting_type,
  setting_required=FALSE,
  column_mapping=FALSE,
  column_type=NA,
  field_mapping=FALSE,
  field_column_key='',
  setting_cat,
  default='',
  charts=c(),
  metadataLocation=getwd(),
  overwrite=TRUE
){

  # check inputs
  stopifnot(
    typeof(domain)=="character",
    typeof(text_key)=="character",
    typeof(label)=="character",
    typeof(description)=="character",
    typeof(setting_type)=="character",
    setting_type %in% c("character","numeric","logical"),
    typeof(setting_required)=="logical",
    typeof(column_mapping)=="logical",
    typeof(field_mapping)=="logical",
    typeof(setting_cat)=="character"
  )

  if(nchar(label)==0){
    label = text_key
  }

  # create object for new setting
  newSetting <- list(
    domain=domain,
    text_key=text_key,
    label=label,
    description=description,
    setting_type=setting_type,
    setting_required=setting_required,
    column_mapping=column_mapping,
    column_type=column_type,
    field_mapping=field_mapping,
    field_column_key=field_column_key,
    setting_cat=setting_cat,
    default=default
  )

  # load metadata
  metadataPath <- paste(settingsLocation,"metadata.Rds",sep="/")
  metadata<- getMetadata(path=metadataPath)
  
  # set chart flags for new setting
  chartVars <-  names(metadata$settings)[substr(names(metadata$settings),0,6)=="chart_"]
  settingCharts <- paste0("chart_",charts)
  for(varName in chartVars){
    newSetting[varName] <- varName %in% settingCharts
  }

  #delete row for the specified chart if overwrite is true
  if(overwrite){
    metadata$settings <- metadata$settings %>% filter(!(.data$text_key == !!text_key & .data$domain== !!domain))
  }

  # add custom chart settings and save
  metadata$settings[nrow(metadata$settings)+1,] <- newSetting
  saveRDS(metadata, metadataPath)
}
