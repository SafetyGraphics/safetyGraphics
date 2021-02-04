#' start new project with an instance of safetyGraphicsApp()
#' @param path location for new safetyGraphicsApp
#' @param init_default_configs copy over `safetyCharts` default configs?
#' @param open open new rstudio project?
#'
#' @return Used for side effect
#' 
#' @importFrom rstudioapi isAvailable openProject
#' @importFrom fs path_abs  path dir_copy 
#' @importFrom usethis create_project 
#' 
#' 
#' @export
#' 

create_new_safetyGraphics_app <- function(
  path, 
  init_default_configs,
  open = TRUE,
  gui = FALSE
) {
  
  path <- fs::path_abs(path)
  
  if(init_default_configs){
    from_path <- system.file("config", package = "safetyCharts")
    fs::dir_copy(path=from_path, new_path = file.path(path, "config"), overwrite = TRUE)
  }
  
  # write start_app.R
  cat(
    '
    # load required libraries
    library(safetyCharts)
    library(safetyGraphics)
    
    # Start default App
    safetyGraphics::safetyGraphicsApp()
    
    # Run the RStudio app initialization Addin
    
    ## Option 1: run the following line of code
    safetyGraphics::app_init_addin()
    
    ## Option 2: open through RStudo Addin button above
    
    
    # You can scaffold a new chart by calling the add_chart function. see ?add_chart for details
    safetyGraphics::add_chart("newChart", "my new chart")
    
    # That is it for now!
    ',
    file= file.path(path, "start_app.R")
  )


  if (gui == FALSE) {
    # create rstudio project
    usethis::create_project(path = path, open = open)
  }  
  
  return(invisible(path))
}

# to be used in RStudio "new project" GUI
create_new_safetyGraphics_app_gui <- function(path,...){
  dots <- list(...)
  create_new_safetyGraphics_app(path, dots$check_default_configs, open = FALSE, gui=TRUE)
}