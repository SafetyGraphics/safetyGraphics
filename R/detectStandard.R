#' Detect the data standard used for a data set
#'
#' This function attempts to detect the data CDISC clinical standard used in a given R data frame.
#'
#' This function compares the columns in the provided \code{"data"} with the required columns for a given data standard/domain combination. The function is designed to work with the SDTM and AdAM CDISC(<https://www.cdisc.org/>) standards for clinical trial data. Currently, only "labs" is the only domain supported.
#'
#' @param data A data frame in which to detect the data standard
#' @param domain The data domain for the data set provided.  Default: \code{"labs"}.
#' @return A list containing the matching \code{"standard"} ("ADaM", "SDTM" or "None") and a list of  \code{"details"} describing each standard considered. #'
#' @examples
#' detectStandard(adlbc)[["standard"]] #AdAM
#' detectStandard(iris)[["standard"]] #none
#'
#' \dontrun{
#'   detectStandard(adlbc,domain="AE") #throws error. AE domain not supported in this release.
#' }
#'
#' @export

detectStandard <- function(data, includeFields=TRUE, domain="labs"){
  stopifnot(
    domain=="labs",
    typeof(domain)=="character"
  )


  # Create placeholder list, with Standard = None.
  standard_list <- list()
  standard_list[["details"]] = list()
  standard_list[["details"]][["ADaM"]]<-compare_to_standard(data,standard="ADaM", includeFields=includeFields, domain=domain)
  standard_list[["details"]][["SDTM"]]<-compare_to_standard(data,standard="SDTM", includeFields=includeFields, domain=domain)

  # Determine the final standard
  if(standard_list[["details"]][["SDTM"]][["match"]] == "Full"){
    standard_list[["standard"]]<- "SDTM"
  } else if(standard_list[["details"]][["ADaM"]][["match"]] == "Full"){
    standard_list[["standard"]]<- "ADaM"
  } else if(standard_list[["details"]][["SDTM"]][["match"]] == "Partial" |
           standard_list[["details"]][["ADaM"]][["match"]] == "Partial"){
  standard_list[["standard"]] <- ifelse(
    length(standard_list[["details"]][["ADaM"]][["valid_count"]]) >
      length(standard_list[["details"]][["SDTM"]][["valid_count"]]),
      "ADaM" , "SDTM" #SDTM if they are equal
    )

  } else {
    standard_list[["standard"]]<-"None"
  }

  return(standard_list)
}
