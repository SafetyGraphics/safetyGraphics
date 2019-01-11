labelSetting<-function(ns, name, label, description){
  
  label_id <- paste0("lbl_", name)
  shinyjs::html(id =  label_id,
                html = label,
                add = FALSE)
  
  tooltip_id <- paste0("tt_lbl_", name)

  shinyjs::runjs(paste0('$("#',ns(tooltip_id), '").attr("title", "', description, '")'))
}