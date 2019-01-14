updateSettingStatus<-function(ns, name, status_short, status_long){
  
  msg_id <- paste0("msg_", name)
  tooltip_id <- paste0("tt_msg_", name)
  
  if (status_short=="OK"){
    shinyjs::html(id = msg_id,
                  html = paste0("   <em style='color:green; font-size:12px;'>", status_short,"</em>"))
    
    shinyjs::runjs(paste0('$("#',ns(tooltip_id), '").attr("title", "Selection is valid")'))
    
  } else {
    shinyjs::html(id = msg_id,
                  html = paste0("   <em style='color:red; font-size:12px;'>", status_short,"</em>"))
    
    shinyjs::runjs(paste0('$("#',ns(tooltip_id), '").attr("title", "', status_long, '")'))
  }

}
