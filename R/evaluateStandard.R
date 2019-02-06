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

  add<-function(val1,val2){return(val1+val2)}
  data.frame(a=1,b=2,c=3)%>%
    mutate(d=add(val1=b,val2=c))
  # Get metadata for settings using the specified standard and see if required data elements are found
  standardChecks <- getSettingsMetadata(cols=c("text_key", "column_mapping", "field_mapping", "field_column_key", "setting_required","standard_val",standard))%>%
  rename("standard_val"=standard)%>%
  filter(column_mapping == TRUE || field_mapping ==TRUE) %>%
  filter(setting_required==TRUE) %>%
  mutate(type = ifelse(column_mapping, "column", "field")) %>% #working to here
  rowwise %>%
  mutate(field_column_name = ifelse(field_mapping, getSettingsMetadata(cols=standard, text_keys=field_column_key),"")) %>%
  mutate(valid = ifelse(column_mapping,
    safetyGraphics:::hasColumn(data=data, columnName=standard_val),
    safetyGraphics:::hasField(data=data, columnName=field_column_name, fieldValue=standard_val)
  ))# %>%
  #select(text_key, standard, type, valid)

  compare_summary[["checks"]] <- standardChecks

  # How many valid data elements
  #comare_summary[["valid_count"]] <- standardChecks %>% filter(valid==TRUE) %>% n()
  #compare_summary[["invalid_count"]] <- standardChecks %>% filter(valid==FALSE) %>% n()


  # if (compare_summary[["invalid_count"]]==0) {
  #   compare_summary[["match"]] <- "Full"
  # } else if(compare_summary[["valid_count"]]>0) {
  #   compare_summary[["match"]] <- "Partial"
  # } else {
  #   compare_summary[["match"]] <- "None"
  # }

  return(compare_summary)
}