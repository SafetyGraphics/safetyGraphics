#' Create data mapping based on data standards and user input
#' 
#' @param domainData named list of data.frames to be loaded in to the app. Sample AdAM data from the safetyData package used by default
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param customMapping optional list specifying initial mapping values within each data mapping (e.g. list(aes= list(id_col='USUBJID', seq_col='AESEQ')). 
#' @param autoMapping boolean indicating whether the app should use `safetyGraphics::detectStandard()` to detect data standards and automatically generate mappings for the data provided. Values specified in the `customMapping` parameter overwrite auto-generated mappings when both are found. Defaults to true.
#' 
#' @return List containing data standard information and mapping
#'  \itemize{
#'  \item{"mapping"}{ Initial Data Mapping }
#'  \item{"standards"}{ List of domain level data standards (or NULL if autoMapping is false) }
#' }
#' 
#' @export

makeMapping <- function(domainData, meta, autoMapping, customMapping ){
    if(autoMapping){
        # if autoMapping is true generate a mapping based on the data standard
        standards <- names(domainData) %>% lapply(function(domain){
            return(detectStandard(domain=domain, data = domainData[[domain]], meta=meta))
        })
        names(standards)<-names(domainData)
        
        auto_mapping_list <- standards %>% map(function(standard){
            if(standard$standard=="none"){
                return(data.frame(domain=character(), text_key=character(), current=character(), valid=logical()))
            }else{
                return(standard$mapping)
            }
        })        auto_mapping_df<-bind_rows(auto_mapping_list, .id = "domain") %>% select(-.data$valid)
    }else{
        # otherwise initialize NULL standards/mapping
        standards<-NULL 
        auto_mapping_df<-data.frame(domain=character(), text_key=character(), current=character())
    }

    # convert user mappings to data frame
    user_mapping_df <- data.frame(domain=character(), text_key=character(), current=character())
    for(dom in names(customMapping)){
        domainMap <- customMapping[[dom]]
        for(key in names(domainMap)){
            val <- domainMap[[key]]
            # TODO - make this recursive at some point
            if(typeof(val)=="list"){
                new_rows <- data.frame(domain=dom, text_key=paste0(key,"--",names(val)), current=unlist(val))
                user_mapping_df <- rbind(user_mapping_df,new_rows)
            }else{
                new_row <- data.frame(domain=dom, text_key=key, current=val)
                user_mapping_df<- rbind(user_mapping_df,new_row)
            }
        }        
    }

    # merge auto_mapping on to user_mapping - if both are provided, keep user mapping
    combined_mapping_df <- full_join(user_mapping_df, auto_mapping_df, by=c("domain","text_key")) %>%
        mutate(current = ifelse(is.na(.data$current.x),.data$current.y,.data$current.x)) %>%
        select(-.data$current.x,-.data$current.y)
    
    return(list(standard=standards, mapping=combined_mapping_df))
}
