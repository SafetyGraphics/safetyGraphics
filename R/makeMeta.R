#' Create a metadata object based on the selected charts
#' 
#' @param charts list of charts for which metadata is needed 
#' @param package package containing needed metadata
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

makeMeta <- function(charts, package="safetyCharts"){
    meta<-tibble()
    # get a list of domains from the charts
    domains <- charts %>% map(~.x$domain) %>% unlist %>% unique()
    packagePath <- paste0('package:',package)

    # Find matching metadata files in safetyCharts (or safetyData?)
    meta<-tibble()
    for(domain in domains){
        domain_name <- paste0('meta_',domain)
        domain_meta_found <- exists(
            domain_name,
            where=packagePath,
            inherits=FALSE
        )
        if(domain_meta_found){
            meta<-rbind(meta, get(domain_name,pos=packagePath, inherits=FALSE))
        }
    }

    return(meta)
}