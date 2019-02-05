#' Check whether a column is found in a data set
#'
#' This checks whether a specified column is found in a specified data set
#'
#' @param columnName The column to look for.
#' @param data the data.frame to search.
#' @return logical scalar. TRUE if the column is found. FALSE otherwise
#' @examples
#''
#' hasColumn(columnName="PARAM",data=adlbc) #TRUE
#' hasColumn(columnName="Not_a_column",data=adlbc) #FALSE
#'
#' @export

hasColumn <- function(columnName, data){
  stopifnot(
    typeof(column)=="character",
    length(columnName)>1,
    typeof(data)=="data.frame"
  )

  return toupper(columnName) %in% toupper(colnames(data))
}
