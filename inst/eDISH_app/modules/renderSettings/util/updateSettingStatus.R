#' Update setting validation status
#' 
#' Workflow:
#' (1) Update abbreviated status for a given setting using green (valid) or red (invalid) text
#' (2) Update long status message for a given setting to be displayed upon mouseover
#' 
#' @param ns The namespace of the current module
#' @param key A character key representing the setting of interest 
#' @param status_short Abbreviated validation message  
#' @param status_long Detailed validation message  

updateSettingStatus<-function(ns, key, status_short, status_long){
  
  msg_id <- paste0("msg_", key)
  tooltip_id <- paste0("tt_msg_", key)
  
  if (status_short=="OK"){
    shinyjs::html(id = msg_id,
                  html = paste("   <em style='color:green; font-size:12px;'>", status_short,"</em>",
                                "<i class='fa fa-ellipsis-h' style='color:green'></i>"))
    
    shinyjs::runjs(paste0('$("#',ns(tooltip_id), '").attr("title", "Selection is valid")'))
    
  } else {
    shinyjs::html(id = msg_id,
                  html = paste("   <em style='color:red; font-size:12px;'>", status_short,"</em>",
                                "<i class='fa fa-ellipsis-h' style='color:red'></i>"))
    
    shinyjs::runjs(paste0('$("#',ns(tooltip_id), '").attr("title", "', status_long, '")'))
  }

}
