#' Create a metadata object table for a set of charts
#' 
#' Generates metadata object for a list of charts. makeMeta() looks in chart$package namespace for files called meta_{chart$name} and meta_{chart$domain} for all charts, and then stacks all files. If duplicate metadata rows (domain + text_key) are found an error is thrown. 
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
#' @importFrom tidyr replace_na starts_with
#' @export

makeMeta <- function(charts){
    message(paste0("-Generating meta data for ",length(charts), " charts."))
    # Check each chart to see if {package}::meta_{domain} or {package}::meta_{name} exists
    sources <- charts %>% map(function(chart){
        pkg<-ifelse(is.null(chart$package), 'safetyCharts',chart$package)
        files<-paste0('meta_',c(chart$name, chart$domain)) %>% map(~list(file=.x, pkg=pkg))
        return(files)
    }) %>% 
    flatten %>%
    unique

    pkg_dfs<-sources %>% map(function(src){
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
                    mutate(source = paste0(src$pkg, "::",src$file))
                return(this_meta) 
            } 
        }
    })

    ## check for meta bound directly to the charts
    chart_dfs <- charts %>% map(function(chart){
        if(is.data.frame(chart$meta)){
            this_meta <- chart$meta %>% mutate(source = paste0('charts$', chart$name, "$meta"))
            return(this_meta)
        }else{
            if(!is.null(chart$meta)) warning(paste0("Ignoring non-data.frame object found in charts$", chart$name, "$meta"))
        }
    })

    ## make sure dfs have required columns
    dfs<-c(pkg_dfs,chart_dfs)
    required_cols <- c("domain","text_key","col_key","type")
    dfs <- dfs%>%
        keep(is.data.frame)%>%
        keep(function(df){
            has_cols <- all(required_cols %in% names(df))
            if(!has_cols) warning(paste(df[1,'source'],"dropped from meta because of missing required columns.")) 
            return(has_cols)
        })

    ## combine list of dfs into single df
    if(length(dfs)>0){
        meta<-bind_rows(dfs) 
        #%>% mutate_at(vars(tidyr::starts_with('standard_')), ~tidyr::replace_na(., ""))
        
        # Throw error if duplicate records are found
        dupes <- duplicated(meta%>%select(.data$domain, .data$text_key))
        if(any(dupes)){
            dupeIDs <- meta[dupes,]%>%
                mutate(domain_text_key=paste(.data$domain,.data$text_key,sep="-"))%>%
                pull(.data$domain_text_key)%>%
                unique%>%
                paste(collapse="\n")
            stop(paste("Duplicate rows in metadata for:\n",dupeIDs))
        } 
        
        sources <- meta %>% pull(source) %>% unique %>% paste(collapse=" ")
        message(paste0("-Meta object created using the following source(s): ",sources))
        return(meta)
    } else {
        stop("No metadata found. ")
    }
    
}

