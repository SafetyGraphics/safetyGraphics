updateSettingStatus<-function(session, name, originalLabel, status){
  if (status=="OK"){
    shinyjs::html(id = paste0("label_", name),
                  html = paste0(originalLabel, "   <em style='color:green; font-size:12px;'>", status,"</em>"))
  } else {
    shinyjs::html(id = paste0("label_", name),
                  html = paste0(originalLabel, "   <em style='color:red; font-size:12px;'>", status,"</em>"))
  }

}
