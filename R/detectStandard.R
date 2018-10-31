#' Detect the CDISC data standard used for a data set
#'
#' This function attempts to detect the data standard used for a given R data frame. 
#'
#' @param data A data frame in which to detect the data standard 
#' @param domain The data domain for the data set provided. Currently, only "labs" is supported. Default: \code{"labs"}.
#' @return A list with the standard ("ADaM", "SDTM" or "None") and a description of the matching results

detectStandard <- function(data, domain="labs"){
  # Create placeholder list, with Standard = None.
  standard_list <- list()
  standard_list[["details"]] = list()
  data_cols<-colnames(data)
  
  # Check to see if data columns match the standards
  standard_list[["details"]][["ADaM"]]<-compare_cols(data_cols,getRequiredColumns(standard="ADaM"))
  standard_list[["details"]][["SDTM"]]<-compare_cols(data_cols,getRequiredColumns(standard="SDTM"))
  
  # Determine the final standard
  if(standard_list[["details"]][["SDTM"]][["match"]]){
    standard_list[["standard"]]<- "SDTM"
  }else if(standard_list[["details"]][["ADaM"]][["match"]]){
    standard_list[["standard"]]<- "ADaM"
  }else{
    standard_list[["standard"]]<-"None"
  }
  
  return(standard_list)
}