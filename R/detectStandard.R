#' Detect the data standard used for a data set
#'
#' This function attempts to detect the clinical data standard used in a given R data frame.
#'
#' This function compares the columns in the provided \code{"data"} with the required columns for a given data standard/domain combination. The function is designed to work with the SDTM and ADaM CDISC(<https://www.cdisc.org/>) standards for clinical trial data by default. Additional standards can be added by modifying the \code{"meta"} data set included as part of this package.
#'
#' @param data A data frame in which to detect the data standard - required.
#' @param meta the metadata containing the data standards. - default = safetyGraphics::meta
#' @param domain the domain to evaluate - should match a value of \code{meta$domain}. Uses the first value in \code{meta$domain} if no value is provided. 
#'
#' @return A data frame describing the detected standard for each \code{"text_key"} in the provided metadata. Columns are \code{"domain"}, \code{"text_key"}, \code{"column"} and \code{"standard"}.
#' @examples 
#' detectStandard(data=safetyGraphics::aes)  #aes domain evaluated by default
#' detectStandard(data=safetyGraphics::labs,domain="labs" ) 
#'
#' @importFrom stringr str_detect 
#' 
#' @export

detectStandard <- function(data, domain=NULL, meta=safetyGraphics::meta){
  if(is.null(domain)){
    domain<-unique(meta$domain)[1]
  }
  stopifnot(
    typeof(domain)=="character",
    is.data.frame(data),
    is.data.frame(meta)
  )
  #todo add check for duplicate text ids

  # Create placeholder list, with Standard = none.
  available_standards <- names(meta)[str_detect(names(meta),"standard_")]%>%substring(10)
  
  standard_list <- list()
  standard_list[["details"]] = list()
  standard_list[["standard"]] = "none"
  standard_list[["label"]] = "No standard detected"
  
  standard_list[["mapping"]] = NULL
  standard_list[["standard_percent"]] = 0
  
  for(standard in available_standards){
    # evaluate the current standard and save the result
    standard_list[["details"]][[standard]]<-evaluateStandard(data=data, meta=meta, domain=domain, standard=standard)  
    
    # if the current standard is a better match, use it as the overall standard
    # if there is a tie, don't change the standard - this means the column order in meta breaks ties!
    current<-standard_list[["details"]][[standard]]
    current_percent <- current[["match_percent"]]
    current_mapping <- current[["mapping"]]
    current_label <- current[["label"]]
    
    overall_percent <- standard_list[["standard_percent"]]
    if(current_percent > overall_percent){
      standard_list[["standard"]] <- standard  
      standard_list[["standard_percent"]] <- current_percent
      standard_list[["mapping"]]<-current_mapping
      standard_list[["label"]]<-current_label
    }
  }
  
  return(standard_list)
}
