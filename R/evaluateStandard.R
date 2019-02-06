#' Evaluate a data set against a data standard
#'
#' Determines whether the required data elements in a data standard are found in a given data frame
#'
#' @param data data.frame to evaluate
#' @param standard standard to evaluate
#' @param includeFields should field level data be evaluated? 
#' @param domain data domain. "labs" only for now. 
#' 
#' @return a list describing to what degree the data set matches the data standard. The "match" property specifies describes compliance with the standard as "Full", "Partial" or "None". The "checks" property is a list of the data elements expected for the standard and whether they are "valid" in the given data set. "valid_checks" and "invalid_checks" provide counts of the specified checks. 
#'  
#' @examples
#''
#' hasColumn(columnName="PARAM",data=adlbc) #TRUE
#' hasColumn(columnName="Not_a_column",data=adlbc) #FALSE
#'
#' @import dplyr
#' @importFrom purrr map 
#'
#' @keywords internal


evaluateStandard <- function(data, standard, includeFields=TRUE, domain="labs"){
  
  stopifnot(
    is.data.frame(data),
    is.character(standard),
    is.logical(includeFields),
    is.character(domain),
    tolower(standard) %in% c("adam","sdtm")
  )
  
  standard<-tolower(standard)
  
  compare_summary<-list()
  compare_summary[["standard"]]<-standard

  # Get metadata for settings using the specified standard and see if required data elements are found
  standardChecks <- getSettingsMetadata(cols=c("text_key", "column_mapping", "field_mapping", "field_column_key", "setting_required","standard_val",standard)) %>%
  rename("standard_val"=standard) %>%
  filter(column_mapping == TRUE || field_mapping ==TRUE) %>%
  filter(setting_required==TRUE) %>%
  mutate(type = ifelse(column_mapping, "column", "field")) %>% 
  rowwise %>%
  mutate(field_column_name = ifelse(field_mapping, getSettingsMetadata(cols=standard, text_keys=field_column_key),"")) %>%
  mutate(valid = ifelse(column_mapping,
    safetyGraphics:::hasColumn(data=data, columnName=standard_val),
    safetyGraphics:::hasField(data=data, columnName=field_column_name, fieldValue=standard_val)
  )) %>%
  select(text_key, standard_val, type, valid)

  # filter out the field level checks if includeChecks is false
  if(!includeFields){
    standardChecks <- standardChecks %>% filter(type != "field")
  }
  
 # compare_summary[["checks"]] <- split(standardChecks, seq(nrow(standardChecks)))%>%map(~as.list(.)) #coerce to list of lists?
  compare_summary[["checks"]] <- standardChecks #or just keep the tibble ... 

  # count valid/invalid data elements
  compare_summary[["valid_count"]] <- standardChecks %>% filter(valid) %>% nrow()
  compare_summary[["invalid_count"]] <- standardChecks %>% filter(!valid) %>% nrow()


  if (compare_summary[["invalid_count"]]==0) {
     compare_summary[["match"]] <- "Full"
  } else if(compare_summary[["valid_count"]]>0) {
    compare_summary[["match"]] <- "Partial"
  } else {
    compare_summary[["match"]] <- "None"
  }

  return(compare_summary)
}