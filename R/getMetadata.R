#' Get combined safetyGraphics metadata environment
#'
#' Create a list containing all metadata (settings, charts and standards) needed for creating charts in safetyGraphics
#'
#' @param meta Starting metadata object. Defaults to safetyGraphics::metadata
#' @param path Optional location a custom metadata file. Data loaded from path will overwrite data loaded via meta. 
#' @param domain Optional string (or vector of strings) used to filter metadata to one or more data domains. All domains returned by default.
#' 
#' @return list with metdata following the format specified in safetyGraphics:::metadata
#'
#' @examples
#' all <- getMetadata() #returns safetygraphics:::metadata
#' labs <- getMetadata(domian="labs") #returns lab domain only
#' custom <- file.path(getwd(), 'metadata.rds')  #attempt to load `metadata.rds` saved in the working directory
#' 
#' @importFrom stringr str_subset
#' @importFrom magrittr "%>%"
#' @import dplyr
#' @importFrom rlang .data
#'
#' @export
#' 
#' 
getMetadata  <- function(meta = safetyGraphics::metadata, path=NULL, domain=NULL){
    stopifnot(typeof(meta)=="list", typeof(path) %in% c("character","NULL"), typeof(domain) %in% c("character", "NULL"))
   
    if(!is.null(path)){
        stopifnot(file.exists(path))
        meta <- readRDS(path)
    }

    if(!is.null(domain)){
        meta$settings <- meta$settings %>% filter(domain %in% tolower(!!domain))
        meta$standards <- meta$standards %>% filter(domain %in% tolower(!!domain))
        meta$charts <- meta$charts %>% filter(domain %in% tolower(!!domain))
    }
    
return(meta)
}