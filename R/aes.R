#' Adverse Event sample data
#'
#' A dataset containing anonymized AE data from a clinical trial in the CDISC ADaM format. The structure is 1 record per measure per adverse event. See a full description of the ADaM data standard \href{https://www.cdisc.org/standards/foundational/adam/adam-implementation-guide-v11}{here}.
#'
#' @format A data frame with 10288 rows and 46 variables.
#' \describe{
#'    \item{STUDYID}{Study Identifier}
#'    \item{SUBJID}{Subject Identifier for the Study}
#'    \item{USUBJID}{Unique Subject Identifier}
#' }    
#' @source \url{https://github.com/RhoInc/data-library}
#' 
"aes"