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
        all_meta <- NULL
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
            )%>%
            mutate(source = paste0(packagePath, ":meta_", chart$name))
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
                ) %>% 
                mutate(source = paste0(packagePath, ":meta_", domain))    
            }else{
                this_meta <- tibble()
            }
            domain_meta <- rbind(domain_meta, this_meta)
        }
        

        all_meta <- rbind(chart_meta, domain_meta) 

        # Remove duplicate meta data
        dupes <- duplicated(all_meta%>%select(domain, text_key))
        if(any(dupes)){
            dup_meta <- all_meta[dupes,] 
            message("Removed ",sum(dupes)," duplicate metadata records for ", chart$name,".")
            all_meta <- all_meta[!dupes,]
        }
    }

    return(all_meta)
}