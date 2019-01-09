updateSettingStatus<-function(ns, name, status){
  
  msg_id <- paste0("msg_", name)
  tooltip_id <- paste0("tt_msg_", name)
  
  if (status=="OK"){
    shinyjs::html(id = msg_id,
                  html = paste0("   <em style='color:green; font-size:12px;'>", status,"</em>"))
    
    shinyjs::runjs(paste0('$("#',ns(tooltip_id), '").attr("title", "Selection is valid")'))
    
  } else {
    shinyjs::html(id = msg_id,
                  html = paste0("   <em style='color:red; font-size:12px;'>", status,"</em>"))
    
    shinyjs::runjs(paste0('$("#',ns(tooltip_id), '").attr("title", "', status, '")'))
  }

}
