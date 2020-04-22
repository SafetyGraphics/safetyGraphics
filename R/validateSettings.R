######################################################################
# validate new settings
#  the validation is run every time there is a change in data and/or settings.
#
######################################################################

status_new <- reactive({
  req(data())
  req(settings_new())
  
  name <- rev(isolate(input_names()))[1]
  settings_new <- settings_new()
  charts <- isolate(input$charts)
  out<-validateSettings(data(), settings_new, charts=charts)
  
  return(out)
})


######################################################################
# Setting validation status information
######################################################################
status_df <- reactive({
  req(status_new())
  status_new()[["checks"]] %>%
    group_by(text_key) %>%
    mutate(num_fail = sum(valid==FALSE)) %>%
    mutate(icon = ifelse(num_fail==0, "<i class='fa fa-check'></i>","<i class='fa fa-times'></i>"))%>%
    mutate(
      message_long = paste(message, collapse = " ") %>% trimws(),
      message_short = case_when(
        num_fail==0 ~ "OK",
        num_fail==1 ~ "1 failed check.",
        TRUE ~ paste(num_fail, "failed checks.")
      )
    ) %>%
    select(text_key, icon, message_long, message_short, num_fail) %>%
    unique
})

# for shiny tests
exportTestValues(status_df = { status_df() })

######################################################################
# print validation messages
######################################################################
observeEvent(status_df(), {
  for (key in isolate(input_names())){
    if(key %in% status_df()$text_key){
      status_short <- status_df()[status_df()$text_key==key, "message_short"]
      status_long <- status_df()[status_df()$text_key==key, "message_long"]
      icon <- status_df()[status_df()$text_key==key, "icon"]
      updateSettingStatus(
        ns=ns,
        key=key,
        status_short=status_short,
        status_long=status_long,
        icon=icon
      )
    }
  }
})