createSettingsSection <- function(class, label,cols,ns){
  section <- 
    column(cols,
           wellPanel(
             class=paste0(class," section"),
             h3(
               label,
               materialSwitch(
                 ns(paste0("show_",class)),
                 label = "",
                 right=TRUE,
                 value = TRUE,
                 status = "primary"
               )
             ),
             conditionalPanel(
               condition=paste0("input.show_",class), 
               ns=ns, 
               uiOutput(ns(paste0(class,"_ui")))
             )
           )
    )
  return(section)
}