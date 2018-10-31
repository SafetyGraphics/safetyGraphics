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
