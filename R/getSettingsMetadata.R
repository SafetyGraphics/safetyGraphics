#' Get metadata about chart settings
#'
#' Retrieve specified metadata about chart settings from the data/settingsMetadata.Rda file. 
#' 
#' @param charts optional vector of chart names used to filter the metadata. Exact matches only (case-insensitive). All rows returned by default.
#' @param text_keys optional vector of keys used to filter the metadata. Partial matches for any of the strings are returned (case-insensitive). All rows returned by default.
#' @param metadata_columns optional vector of columns to return from the metadata. All columns returned by default. 
#' 
#' @return dataframe with the requested metadata or single metadata value
#' 
#' @examples 
#' safetyGraphics:::getSettingsMetadata() # Returns a full copy of settingsMetadata.Rda
#' safetyGraphics:::getSettingsMetadata(text_keys=c("id_col")) # returns a dataframe with a single row with metadata for the id_col setting
#' safetyGraphics:::getSettingsMetadata(text_keys=c("id_col"), columns=c("label")) # returns the character value for the specified row. 

getSettingsMetadata<-function(charts, text_keys, metadata_columns){

  subsetMetadata <-settingsMetadata
  all_columns <- names(settingsMetadata)
  if(charts){ #Don't do anything if charts isn't specified
    stopifnot(typeof(charts) == "character")
    
    subsetMetadata$chartFlag<-FALSE; #all records false by default when charts is specified
    for(chartName in charts){
       
      chartColumn <-paste0("chart_",chartName)
      subsetMetadata$chartFlag%>%mutate(chartFlag = case_when(
        !(chartName in all_columns) ~ chartFlag, 
        !!as.name(chartColumn) == FALSE ~ chartFlag,
        !!as.name(chartColumn) == TRUE ~ TRUE
      )) 
    }
  }
  
  if(text_keys){
    stopifnot(typeof(text_keys) == "character")
    
  }
  
  if(metadata_columns){
    stopifnot(typeof(metadata_columns) =="character")
    
  }
  return(subsetMetadata)
  
}
