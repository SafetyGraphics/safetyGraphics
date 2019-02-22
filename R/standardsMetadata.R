#' Standards Metadata 
#'
#' Metadata about the data standards used to configure safetyGraphics charts. SpecificOne record per unique setting
#'
#' @format A data frame with 25 rows and 10 columns
#' \describe{
#'    \item{text_key}{Text key indicating the setting name. \code{'--'} delimiter indicates a nested setting}
#'    \item{--standard names--}{additional columns contain default setting values for clinical data standards, like the CDISC "adam" and "sdtm" standards.}
#' }    
#' 
#' @source Created for this package
"standardsMetadata"