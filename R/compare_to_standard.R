compare_to_standard <- function(data, standard, includeFields, domain="labs"){
  compare_summary<-list()

  # Get metadata for settings using the specified standard and see if required data elements are found
  standardChecks <- getSettingsMetadata(
    cols=c("text_key", "column_mapping", "field_mapping", "column_field_key", "setting_required", standard),
  ) %>%
  filter(column_mapping == TRUE || field_mapping ==TRUE) %>%
  filter(setting_required==TRUE) %>%
  mutate(type = ifelse(column_mapping), "column", "field") %>%
  mutate(valid = ifelse(column_mapping,
    hasColumn(data=data, colName=standard),
    hasField(data=data, colName=column_field_key, fieldValue=standard)
  )) %>%
  select(text_key, standard, type, valid)

  compare_summary[["checks"]] <- as.list(standardChecks)

  # How many valid data elements
  comare_summary[["valid_count"]] <- standardChecks %>% filter(valid==TRUE) %>% n()
  compare_summary[["invalid_count"]] <- standardChecks %>% filter(valid==FALSE) %>% n()


  if (compare_summary[["invalid_count"]]==0) {
    compare_summary[["match"]] <- "Full"
  } else if(compare_summary[["valid_count"]]>0) {
    compare_summary[["match"]] <- "Partial"
  } else {
    compare_summary[["match"]] <- "None"
  }
