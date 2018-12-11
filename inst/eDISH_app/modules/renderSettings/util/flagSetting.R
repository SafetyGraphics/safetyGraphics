flagSetting<-function(session, name, originalLabel){
  shinyjs::html(id = paste0("label_", name),
                html = paste0(originalLabel, "<strong>*</strong>"),
                add = FALSE)
}
