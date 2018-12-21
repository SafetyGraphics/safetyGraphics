#' Compares contents of 2 vectors
#'
#' Function to compare contents of 2 vectors - used to summarize of which data columns are found in a given standard. Used in \code{detectStandard()} and \code{validateSettings()}
#' 
#' @param data_cols A character vector with column names in the data frame
#' @param standard_cols A character vector with column names in the data standard
#' @return A list summarizing the comparison between \code{data_cols} and \code{standard_cols}. List has character vectors for "matched_columns", "extra_columns" and "missing_colimns" parameters, and a boolean "match" parameter indicating that there are no missing columns. 
#' 
#' 
#' @examples 
#' safetyGraphics:::compare_cols(data_cols=c("a","b","c"),standard_cols=c("d","e","f")) #match == FALSE
#' safetyGraphics:::compare_cols(names(adlbc),safetyGraphics:::getRequiredColumns(standard="ADaM")) # match == TRUE
#' 

compare_cols<-function(data_cols, standard_cols){
  compare_summary <- list()
  compare_summary[["matched_columns"]]<-intersect(data_cols, standard_cols)
  compare_summary[["extra_columns"]]<-setdiff(data_cols,standard_cols)
  compare_summary[["missing_columns"]]<-setdiff(standard_cols,data_cols)
  
  #if there are no missing columns then call this a match
  
  compare_summary[["match"]]<- length(compare_summary[["missing_columns"]])==0
  compare_summary[["partial_match"]]<- length(compare_summary[["matched_columns"]])>0
  
  return(compare_summary)
}
