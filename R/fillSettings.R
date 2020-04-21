######################################################################
# Fill settings object based on selections
#
# update is triggered by any of the input selections changing
######################################################################

settings_new <- reactive({
  
  getValues <- function(x){
    if (is.null(input[[x]])){
      return(NULL)
    } else{
      return(input[[x]])
    }
  }
  
  req(input_names())
  keys <- input_names()
  values<- keys %>% map(~getValues(.x))
  
  inputDF <- tibble(text_key=keys, customValue=values)%>%
    rowwise %>%
    filter(!is.null(customValue[[1]]))
  
  if(nrow(inputDF)>0){
    settings <- generateSettings(custom_settings=inputDF, charts=input$charts)
  }else{
    settings<- generateSettings(charts=input$charts)
  }
  
  return(settings)
})