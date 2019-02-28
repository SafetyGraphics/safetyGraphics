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

updateSettingStatus<-function(ns, key, status_short, status_long, icon){
  
  ctl_id<-paste0("ctl_", key)  
  #TODO: get msg_ and tooltip_ selectors using relative position to control id
  msg_id <- paste0("msg_", key)
  tooltip_id <- paste0("tt_msg_", key)
  if(status_short=="OK"){
    shinyjs::addClass(id=ctl_id, class="valid")
    shinyjs::removeClass(id=ctl_id, class="invalid")
  }else{
    shinyjs::removeClass(id=ctl_id, class="valid")
    shinyjs::addClass(id=ctl_id, class="invalid") 
  }
  shinyjs::html(id = msg_id, html = paste(icon))
  if(nchar(status_long)>0){
    shinyjs::runjs(paste0('$("#',ns(tooltip_id), '").attr("title", "',status_long,'").addClass("details")'))    
  }
}
