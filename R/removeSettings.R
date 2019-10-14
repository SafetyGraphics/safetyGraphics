#' Remove a setting from the safetyGraphics shiny app
#'
#' This function updates settings objects to remove a setting parameter from the safetyGraphics shiny app
#'
#' This function makes it easy for remove a setting from the safetyGraphics shiny app by making updates to the underlying metadata used by the package. 
#'
#' @param settingsLocation path where the custom settings will be loaded/saved. If metadata is not found in that location, it will be read from the package (e.g. safetyGraphics::settingsMetadata), and then written to the specified location once the setting has been removed.
#' @param text_keys Text keys indicating the setting names to be removed.
#'
#' @export

removeSettings <- function(text_keys, settingsLocation=getwd()){
  settingsMetaPath <- paste(settingsLocation,"settingsMetadata.Rds",sep="/")
  if(file.exists(settingsMetaPath)){
    settingsMeta <- readRDS(settingsMetaPath)
  }else{
    settingsMeta <- safetyGraphics::settingsMetadata
  }
  
  #delete rows for the specified chart
  settingsMeta <- settingsMeta %>% filter(!(.data$text_key %in% !!text_keys))
  
  #save updated metadata file
  saveRDS(settingsMeta, settingsMetaPath)
}