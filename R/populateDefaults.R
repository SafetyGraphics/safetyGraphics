#' Generate a default settings shell based on settings metadata
#'
#' This function returns a default settings objectbased on the chart(s) specified. 
#'
#' The function is designed to work with valid safetyGraphics charts.
#'
#' @param charts The chart or chart(s) for which shells should be generated ("eDish" only for now) . Default: \code{"eDish"}.
#' @return A list containing the appropriate settings for the selected chart
#' 
#' @examples 
#' 
#' generateShell(chart = "eDish") 
#'  
#' @keywords internal

populateDefaults <- function(charts="eDish", settings ){ 
  

  chart="eDish" # expand too multiple charts
  
  defaultMappings <- safetyGraphics::getSettingsMetadata(
    charts = charts, 
    cols=c("text_key","default")
  )  

  hierarchical_metadata <- str_split(defaultMappings$text_key, "--") 
  
  
  shell <- list()
  #replace this !!!!!!!!!!!
  for (i in 1:length(hierarchical_metadata) ) {
    
    # Handle settings with one level
    if (length(hierarchical_metadata[[i]]) == 1) {
      
      shell[defaultMappings$text_key[i]] =  defaultMappings$default[i]
        
      # Handle settings with two levels
    } else if (length(hierarchical_metadata[[i]]) == 2){
      
      #Create list if it does not exist
      if (!is.list(shell[[hierarchical_metadata[[i]][1]]])) { shell[[hierarchical_metadata[[i]][1]]] = list() } #Need to make list if it doesnt exist since its two-level
      
      shell[[hierarchical_metadata[[i]][1]]][hierarchical_metadata[[i]][2]] =  defaultMappings$default[i]
      
    } else{
      stop("Three level setting nests are not currently supported")
    }
    
  }
  
  return(shell)
}
