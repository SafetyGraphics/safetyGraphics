flagSetting<-function(session, name, originalLabel){
  
  originalLabel <- paste("<i class='fa fa-info-circle' style='color:gray'></i>", originalLabel)
  
  shinyjs::html(id = paste0("lbl_", name),
                html = paste0(originalLabel, "<strong>*</strong>"),
                add = FALSE)
}
