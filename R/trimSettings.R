#' Subset a settings object to thsoe relevant for a list of charts
#'
#' This function returns a settings object 
#'
#' This function returns a settings object subsetted to the settings relevant to a vector of charts 
#'
#' @param settings The settings list to subset
#' @param charts  The charts to subset by
#' @return A list containing settings subsetted for the selected charts
#'
#' @examples
#' testSettings <- generateSettings(standard="adam")
#' trimSettings(settings=testSettings, charts = c("safetyhistogram","edish"))
#'
#' @export
#' @importFrom purrr map_chr
#' @importFrom magrittr "%>%"


trimSettings <- function(settings, charts=NULL){

keys <- getSettingsMetadata(charts=charts, cols = c("text_key"))

keys_chr <- keys  %>% safetyGraphics:::textKeysToList() %>% map_chr( ~.x[[1]]) %>% unique() 

settings_names <- names(settings)

for (name in settings_names) {
  if(!(name %in% keys_chr)) {
    settings[[name]] <- NULL   
  }
}

  return(settings)
}