#' Create a metadata object table for a chart
#' 
#' @param chart safetyGraphics chart object for which to create metadata
#' 
#' @return tibble of metadata with the following columns:
#' \describe{
#'    \item{domain}{Data domain}
#'    \item{text_key}{Text key indicating the setting name. \code{'--'} delimiter indicates a field level data mapping}
#'    \item{col_key}{Key for the column mapping}
#'    \item{field_key}{Key for the field mapping (if any)}
#'    \item{type}{type of mapping - "field" or "column"}
#'    \item{label}{Label}
#'    \item{description}{Description}
#'    \item{multiple}{Mapping supports multiple columns/fields }
#'    \item{standard_adam}{Default values for the ADaM data standard}
#'    \item{standard_sdtm}{Default values for the SDTM data standard}
#' }   
#' 
#' @export

makeMeta <- function(chart){
    stopifnot(typeof(chart$domain) %in% c('list','character'))
    if(hasName(chart, 'meta')){
        message(chart$name, " already has `meta` defined. Skipping makeMeta() processing.")
    }else{
        packagePath <- paste0('package:',chart$package)
        if(typeof(chart$domain) == "character"){
            domains <- chart$domain
        }else if(typeof(chart$domain) == "list"){
            domains <- names(chart$domain)
        } 
        
        # check for chart level metadata
        chart_meta_found <- exists(
            paste0("meta_",chart$name),
            where=packagePath,
            inherits=FALSE
        )
        if(chart_meta_found) {
            chart_meta <-  get(
                paste0("meta_",chart$name),
                pos=packagePath, 
                inherits=FALSE
            )
        }else{
            chart_meta <- tibble()
        }

        # check for domain-level metadata
        domain_meta <- tibble()
        for(domain in domains){
            # get domains level meta
            domain_meta_found <- exists(
                paste0("meta_",domain),
                where=packagePath,
                inherits=FALSE
            )
            if(domain_meta_found) {
                this_meta <-  get(
                    paste0("meta_",domain),
                    pos=packagePath, 
                    inherits=FALSE
                )
            }else{
                this_meta <- tibble()
            }
            domain_meta <- rbind(domain_meta, this_meta)
        }
        
        # Drop domain-level metadata found in charts
        chart_ids <- paste0(chart_meta$domain,"-",chart_meta$text_key)
        domain_meta <- domain_meta %>% 
            filter(!(paste0(domain_meta$domain,"-",domain_meta$text_key) %in% chart_ids))
        all_meta <- rbind(chart_meta, domain_meta)
    }

    return(all_meta)
}