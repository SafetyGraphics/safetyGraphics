#' Settings Metadata 
#'
#' Metadata about the settings used to configure safetyGraphics charts. One record per unique setting
#'
#' @format A data frame with 25 rows and 10 columns
#' \describe{
#'    \item{chart_edish}{Flag indicating if the settings apply to the eDish Chart}
#'    \item{text_key}{Text key indicating the setting name. '--' delimiter indicates a nested setting}
#'    \item{label}{Label}
#'    \item{description}{Description}
#'    \item{setting_type}{Expected type for setting value. Should be "character", "vector", "numeric" or "logical"}
#'    \item{setting_required}{Flag indicating if the setting is required}
#'    \item{column_mapping}{Flag indicating if the setting corresponds to a column in the associated data}
#'    \item{column_type}{Expected type for the data column values. Should be "character","logical" or "numeric"}
#'    \item{column_required}{Flag indicating whether the associated data column should be considered required}
#'    \item{field_mapping}{Flag indicating whether the setting corresponds to a field-level mapping in the data}
#'    \item{field_column_key}{Key for the column that provides options for the field-level mapping in the data}
#'    \item{adam}{Settings values for the ADaM standard}
#'    \item{sdtm}{Settings values for the SDTM standard}
#' }    
#' 
#' @source Created for this package
"settingsMetadata"