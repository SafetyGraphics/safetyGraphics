#' Adds a new setting for use in the safetyGraphics shiny app
#'
#' This function updates settings objects to add a new setting parameter to the safetyGraphics shiny app
#'
#' This function makes it easy for users to adds a new settings to the safetyGraphics shiny app by making updates to the underlying metadata used by the package. Specifically, the function adds a row to settingsMetadata.rda describing the setting.
#'
#' @param settings_location path where the custom settings will be loaded/saved. If metadata is not found in that location, it will be read from the package (e.g. safetyGraphics::settingsMetadata), and then written to the specified location once the new setting has been added.
#' @param chart Name of the chart - one word, all lower case
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
#' @param charts character vector of charts using this setting
#' @param settingsLocation folder location of user-defined settings metadata
#' @param overwrite overwrite any existing setting metadata? Note that having settings with the same name is not supported and will cause unexpected results. default = true
#'
#' @export
#'

addSetting<-function(
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
  settingsLocation=getwd(),
  overwrite=TRUE
){

  # check inputs
  stopifnot(
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
    label = chart
  }

  # create object for new setting
  newSetting <- list(
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

  # load settings metadata
  settingsMetaPath <- paste(settingsLocation,"settingsMetadata.Rds",sep="/")
  if(file.exists(settingsMetaPath)){
    settingsMeta <- readRDS(settingsMetaPath)
  }else{
    settingsMeta <- safetyGraphics::settingsMetadata
  }


  # set chart flags for new setting
  chartVars <-  names(settingsMeta)[substr(names(settingsMeta),0,6)=="chart_"]
  settingCharts <- paste0("chart_",charts)
  for(varName in chartVars){
    newSetting[varName] <- varName %in% settingCharts
  }

  #delete row for the specified chart if overwrite is true
  if(overwrite){
    settingsMeta <- settingsMeta %>% filter(.data$text_key != !!text_key)
  }

  # add custom chart settings and save
  settingsMeta[nrow(settingsMeta)+1,] <- newSetting
  saveRDS(settingsMeta, settingsMetaPath)
}
