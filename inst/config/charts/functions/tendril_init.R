library("Tendril")

#compute tendril data
tendril_init<-function(data, settings){
  print("Init Tendril")
  print(names(data))
  aes_arm <- left_join(
    data$aes, 
    data$dm%>%select(settings$dm$id_col, settings$dm$treatment_col), 
    by=settings$dm$id_col)

  
  #get treatments
  all_treatments <- unique(aes_arm%>%pull(settings$dm$treatment_col))
  treatments <- c(settings[["aes"]][["treatment_values--group1"]],settings[["aes"]][["treatment_values--group2"]])
  
  if(length(treatments)<2){
    treatments<-all_treatments[1:2]
  }

  #subject data
  subj <- data$dm %>%
    count(!!sym(settings$dm$id_col),!!sym(settings$dm$treatment_col)) %>% 
    select(-n) %>%
    as.data.frame()
  
  data.tendril <- Tendril(
    mydata = aes_arm,
    rotations = rep(3,dim(aes_arm)[1]),
    AEfreqThreshold = 5,
    Tag = "Comment",
    Treatments = treatments,
    Unique.Subject.Identifier = settings[["aes"]][["id_col"]],
    Terms = settings[["aes"]][["bodsys_col"]],
    Treat = settings[["dm"]][["treatment_col"]],
    StartDay = settings[["aes"]][["stdy_col"]],
    SubjList = subj,
    SubjList.subject = settings[['dm']][['id_col']],
    SubjList.treatment = settings[['dm']][['treatment_col']],
    filter_double_events = TRUE,
    suppress_warnings = TRUE
  )

  return(list(data=data.tendril, settings=list()))
}

