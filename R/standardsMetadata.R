#' Standards Metadata 
#'
#' Metadata about the data standards used to configure safetyGraphics charts. One record per unique setting. Columns contain default setting values for clinical data standards, like the CDISC "adam" and "sdtm" standards. 
#'
#' @format A data frame with 25 rows and 3 columns
#' \describe{
#'    \item{text_key}{Text key indicating the setting name. \code{'--'} delimiter indicates a nested setting}
#'    \item{adam}{Settings values for the ADaM standard}
#'    \item{sdtm}{Settings values for the SDTM standard}
#' }    
#' 
#' @source Created for this package
"standardsMetadata"