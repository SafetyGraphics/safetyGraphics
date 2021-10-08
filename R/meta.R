#' Metadata data frame containing information about the data mapping used to configure safetyGraphics charts. One record per unique data mapping
#'
#' @format A data frame with 31 rows and 7 columns
#' \describe{
#'    \item{domain}{Data domain}
#'    \item{text_key}{Text key indicating the setting name. \code{'--'} delimiter indicates a field level data mapping}
#'    \item{col_key}{Key for the column mapping}
#'    \item{field_key}{Key for the field mapping (if any)}
#'    \item{type}{type of mapping - "field" or "column"}
#'    \item{label}{Label}
#'    \item{description}{Description}
#'    \item{multiple}{Mapping supports multiple columns/fields }
#'    \item{standard_adam}{Default values for the ADaM data standard}
#'    \item{standard_sdtm}{Default values for the SDTM data standard}
#' }    
#' 
#' @source Created for this package


"meta"
