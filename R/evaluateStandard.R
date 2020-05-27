#' Evaluate a data set against a data standard
#'
#' Determines whether the required data elements in a data standard are found in a given data frame
#'
#' @param data A data frame in which to detect the data standard
#' @param meta the metadata containing the data standards. 
#' @param domain the domain to evaluate - should match a value of \code{meta$domain}
#' @param standard standard to evaluate
#' 
#' @return a list describing to what degree the data set matches the data standard. The "match" property describes compliance with the standard as "full", "partial" or "none". The "checks" property is a list of the data elements expected for the standard and whether they are "valid" in the given data set. "total_checks", "valid_checks" and "invalid_checks" provide counts of the specified checks. "match_percent" is calculated as valid_checks/total_checks.  "mapping" is a data frame describing the detected standard for each \code{"text_key"} in the provided metadata. Columns are \code{"text_key"}, \code{"current"} containing the name of the matched column or field value in the data and \code{"match"} a boolean indicating whether the data matches the standard. 
#'  
#' @examples
#' safetyGraphics:::evaluateStandard(data=adlbc, domain="labs" standard="adam") # Match is TRUE
#' safetyGraphics:::evaluateStandard(data=adlbc, domain="labs", standard="sdtm") # Match is FALSE
#'
#' @import dplyr
#' @importFrom purrr map 
#' @importFrom rlang .data
#' 
#' @export

evaluateStandard <- function(data, meta, domain, standard){
  
  stopifnot(
    is.data.frame(data),
    is.data.frame(meta),
    is.character(domain),
    is.character(standard)
  )
  
  standard<-tolower(standard)
  domain<-tolower(domain)
  compare_summary<-list()
  compare_summary[["standard"]]<-standard
  
  domainMeta<-meta %>% filter(domain==!!domain)
  standardMap <- domainMeta%>%pull(paste0("standard_",!!standard))
  names(standardMap)<-domainMeta%>%pull(text_key)
  compare_summary[["mapping"]] <- domainMeta %>% 
    mutate(standard_col = standardMap[col_key] ) %>%
    mutate(standard_field = ifelse(type=="field", standardMap[text_key], NA)) %>%
    filter(!is.na(standard_col)) %>%
    rowwise %>%
    mutate(
      valid = ifelse(
        type=="field",
        safetyGraphics:::hasField(data=data, columnName=standard_col, fieldValue=standard_field),
        safetyGraphics:::hasColumn(data=data, columnName=standard_col)
      )
     )%>%
    mutate(
      current = ifelse(
        valid,
        ifelse(
          type=="field",
          standard_field,
          standard_col
        ),
        NA
      )
    )%>%
    select(text_key, current, valid)
  
  stopifnot(nrow(compare_summary[["mapping"]])>0)
  
  # count valid/invalid data elements
  compare_summary[["total_count"]] <- compare_summary[["mapping"]] %>% nrow()
  compare_summary[["valid_count"]] <- compare_summary[["mapping"]] %>% filter(.data$valid) %>% nrow()
  compare_summary[["invalid_count"]] <- compare_summary[["mapping"]] %>% filter(!.data$valid) %>% nrow()
  compare_summary[["match_percent"]] <- compare_summary[["valid_count"]] / compare_summary[["total_count"]]
  
  if (compare_summary[["invalid_count"]]==0) {
     compare_summary[["match"]] <- "full"
     compare_summary[["label"]] <- standard
  } else if(compare_summary[["valid_count"]]>0) {
    compare_summary[["match"]] <- "partial"
    compare_summary[["label"]] <- current_label <- paste0("Partial ",standard, " (", compare_summary[["valid_count"]], "/" ,compare_summary[["total_count"]], " cols/fields matched)")
    
  } else {
    compare_summary[["match"]] <- "none"
    compare_summary[["label"]] <- "No Match"
  }

  return(compare_summary)
}