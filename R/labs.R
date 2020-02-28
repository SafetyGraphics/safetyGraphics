#' Safety measures sample data
#'
#' A dataset containing anonymized lab data from a clinical trial in the CDISC ADaM format. The structure is 1 record per measure per visit per participant. See a full description of the ADaM data standard \href{https://www.cdisc.org/standards/foundational/adam/adam-implementation-guide-v11}{here}.
#'
#' @format A data frame with 10288 rows and 46 variables.
#' \describe{
#'    \item{STUDYID}{Study Identifier}
#'    \item{SUBJID}{Subject Identifier for the Study}
#'    \item{USUBJID}{Unique Subject Identifier}
#'    \item{TRTP}{Planned Treatment}
#'    \item{TRTPN}{Planned Treatment (N)}
#'    \item{TRTA}{Actual Treatment}
#'    \item{TRTAN}{Actual Treatment (N)}
#'    \item{TRTSDT}{Date of First Exposure to Treatment}
#'    \item{TRTEDT}{Date of Last Exposure to Treatment}
#'    \item{AGE}{Age}
#'    \item{AGEGR1}{Age Group}
#'    \item{AGEGR1N}{Age Group (N)}
#'    \item{RACE}{Race}
#'    \item{RACEN}{Race (N)}
#'    \item{SEX}{Sex}
#'    \item{COMP24FL}{Completers Flag}
#'    \item{DSRAEFL}{Discontinued due to AE?}
#'    \item{SAFFL}{Safety Population Flag}
#'    \item{AVISIT}{Analysis Visit}
#'    \item{AVISITN}{Analysis Visit (N)}
#'    \item{ADY}{Analysis Relative Day}
#'    \item{ADT}{Analysis Relative Date}
#'    \item{VISIT}{Visit}
#'    \item{VISITNUM}{Visit (N)}
#'    \item{PARAM}{Parameter}
#'    \item{PARAMCD}{Parameter Code}
#'    \item{PARAMN}{Parameter (N)}
#'    \item{PARCAT1}{Parameter Category}
#'    \item{AVAL}{Analysis Value}
#'    \item{BASE}{Baseline Value}
#'    \item{CHG}{Change from Baseline}
#'    \item{A1LO}{Analysis Normal Range Lower Limit}
#'    \item{A1HI}{Analysis Normal Range Upper Limit}
#'    \item{R2A1LO}{Ratio to Low limit of Analysis Range}
#'    \item{R2A1HI}{Ratio to High limit of Analysis Range}
#'    \item{BR2A1LO}{Base Ratio to Analysis Range 1 Lower Lim}
#'    \item{BR2A1HI}{Base Ratio to Analysis Range 1 Upper Lim}
#'    \item{ANL01FL}{Analysis Population Flag}
#'    \item{ALBTRVAL}{Amount Threshold Range}
#'    \item{ANRIND}{Analysis Reference Range Indicator}
#'    \item{BNRIND}{Baseline Reference Range Indicator}
#'    \item{ABLFL}{Baseline Record Flag}
#'    \item{AENTMTFL}{Analysis End Date Flag}
#'    \item{LBSEQ}{Lab Sequence Number }
#'    \item{LBNRIND}{Reference Range Indicator}
#'    \item{LBSTRESN}{Numeric Result/Finding in Std Units}
#' }    
#' @source \url{https://github.com/RhoInc/data-library}
"labs"