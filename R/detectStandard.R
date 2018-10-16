#' Detect the CDISC data standard used for a data set
#'
#' This function attempts to detect the data standard used for a given R data frame. 
#'
#' @param data A data frame in which to detect the data standard 
#' @param domain The data domain for the data set provided. Currently, only "labs" is supported. Default: \code{"labs"}.
#' @return A list with the standard ("ADaM", "SDTM" or "None") and a description of the matching results

detectStandard <- function(data, domain="labs", details=FALSE){
  # Create placeholder list, with Standard = None.
  standard_list <- list()
  standard_list[["details"]] = list()
  data_cols<-colnames(data)
  # Define Required Columns for the data standards
  # TODO: Move to a more robust comparison, possibly with JSON Schema. 
  
  ADaM_cols <- c("USUBJID","AVAL","PARAM","VISIT","VISITNUM","ADY","A1LO","A1HI")
  SDTM_cols <- c("USUBJID","STRESN","TEST","VISIT","VISITNUM","DY","STNRLO","STNRHI")
  
  #helper function that returns a summary of which data columns are found in a given standard
  compare_cols<-function(data_cols, standard_cols){
    compare_summary <- list()
    compare_summary[["matched_columns"]]<-intersect(data_cols, standard_cols)
    compare_summary[["extra_columns"]]<-setdiff(data_cols,standard_cols)
    compare_summary[["missing_columns"]]<-setdiff(standard_cols,data_cols)
    
    #if there are no missing columns then call this a match
    compare_summary[["match"]]<- length(compare_summary[["missing_columns"]])==0
    
    return(compare_summary)
  }

  # Check to see if data columns match the standards
  standard_list[["details"]][["ADaM"]]<-compare_cols(data_cols,ADaM_cols)
  standard_list[["details"]][["SDTM"]]<-compare_cols(data_cols,SDTM_cols)
  
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