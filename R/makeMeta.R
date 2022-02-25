#' Create a metadata object table for a set of charts
#' 
#' Generates metadata object for a list charts. makeMeta() looks in chart$package namespace for files called meta_{chart$name} and meta_{chart$domain} for all charts, and then stacks all files. If duplicate metadata rows (domain + text_key) are found an error is thrown. 
#' 
#' @param charts list of safetyGraphics chart objects for which to create metadata
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

makeMeta <- function(charts){
    sources <- charts %>% map(function(chart){
        pkg<-ifelse(is.null(chart$package), 'safetyCharts',chart$package)
        files<-paste0('meta_',c(chart$name, chart$domain)) %>% map(~list(file=.x, pkg=pkg))
        return(files)
    }) %>% 
    flatten %>%
    unique

    dfs<-sources %>% map(function(src){
        packagePath <- paste0('package:',src$pkg)
        file_found <- exists(
            src$file,
            where=packagePath,
            inherits=FALSE
        )
        if(file_found){
            this_meta <-  get(
                src$file,
                pos=packagePath, 
                inherits=FALSE
            )

            if(is.data.frame(this_meta)){
                this_meta <- this_meta%>%            
                    mutate(source = paste0(src$pkg, ":",src$file))
                return(this_meta) 
            } 
        }
    })

    meta<-bind_rows(dfs)
    
    # Throw error if duplicate records are found
    dupes <- duplicated(meta%>%select(.data$domain, .data$text_key))
    if(any(dupes)){
        dupeIDs <- meta[dupes]%>%
            mutate(domain_text_key=paste(.data$domain,.data$text_key,sep="-"))%>%
            pull(.data$domain_text_key)%>%
            paste(collapse="\n")
        stop(paste("Duplicate rows in metadata for:\n",dupeIDs))
    } 

    return(meta)
}

