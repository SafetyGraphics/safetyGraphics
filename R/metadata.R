#' Metadata 
#'
#' Metadata data frame containing informationabout the data mapping used to configure safetyGraphics charts. One record per unique data mapping
#'
#' @format A data frame with 31 rows and 7 columns
#' \describe{
#'    \item{domain}{Data domain}
#'    \item{text_key}{Text key indicating the setting name. \code{'--'} delimiter indicates a field level data mapping}
#'    \item{label}{Label}
#'    \item{description}{Description}
#'    \item{multiple}{Mapping supports multiple columns/fields }
#'    \item{standard_adam}{Default values for the ADaM data standard}
#'    \item{standard_sdtm}{Default values for the SDTM data standard}
#' }    
#' 
#' @source Created for this package
"metadata"
