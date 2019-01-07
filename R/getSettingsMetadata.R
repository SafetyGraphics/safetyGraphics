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

getSettingsMetadata<-function(charts=NULL, text_keys=NULL, metadata_columns=NULL, metadata = settingsMetadata){

  md <- metadata
  all_columns <- names(md)
  
  #filter the metadata based on the charts option (if any)
  if(!is.null(charts)){ #Don't do anything if charts isn't specified
    stopifnot(typeof(charts) == "character")
    
    # get list of all chart flags in the data
    chart_columns <- str_subset(all_columns, "^chart_");
    
    # get a list of chart flags matching the request
    matched_chart_columns <- intersect(chart_columns, paste0("chart_",charts))
    #filter based 
    if(length(matched_chart_columns)==0){
      return(NULL)
    }else{
      # see if any of the matched chart flags are TRUE
      md<-md%>%filter_at(vars(matched_chart_columns),any_vars(.==TRUE))
    }
  }
  
  #filter the metadata based on the text_keys option (if any) 
  if(!is.null(text_keys)){
    stopifnot(typeof(text_keys) == "character")
    query<-ifelse(length(text_keys)==1,text_keys,str_c(text_keys,collapse="|"))
    md<-md%>%filter(str_detect(text_keys,query))
  }
  
  #subset the metadata columnbs returned based on the metadata_columns option (if any)
  if(!is.null(metadata_columns)){
    stopifnot(typeof(metadata_columns) =="character")
    md<-md%>%select(metadata_columns)
  }
  
  return(md)
}
