

#' @title filter module checks
#' @description function that checks whether the current data and settings are appropriate for the filter tab
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param domainData list of data files for each domain
#' @param filterDomain domain to use for filtering (typically "dm")
#' @param current_mapping current data mapping (REACTIVE)
#' 
#' @return reactive that returns a boolean indicating whether the checks passed and filtering can be initiailized
#' 
#' @export

filterTabChecks <- function(domainData, filterDomain, current_mapping){

    # Check to see if data can be filtered using current settings.
    filterCheck<-reactive({
        currentStatus <- TRUE
        filterCheckNote<-"ok"
        if(is.null(filterDomain)){
            # Make sure filterDomain exists.
            currentStatus <- FALSE
            filterCheckNote <- "Filter Domain Not specified."
        }else if(!(filterDomain %in% names(domainData))){
            # Make sure the filterDomain is found in the data
            currentStatus <- FALSE
            filterCheckNote <- "Specified Filter Domain not found in provided data."
        }else{
            # Make sure id_col is specified in all domains.
            id_col <- reactive({
                filter_data <- current_mapping() %>% filter(.data$domain==filterDomain)   
                id<- filter_data %>% filter(.data$text_key=="id_col")%>%pull(.data$current)
                return(id)
            })
            id_check <- all(domainData %>% purrr::map_lgl(~{id_col() %in% colnames(.x)}))
            if(!id_check){
                currentStatus <- FALSE
                filterCheckNote <- "ID_col is not found in one or more data domain."
            }else if(FALSE){
                # Warn if id_col is non-unique in filter domain.
            }else if(FALSE){
                # Warn if id_col differs across domains.
            }
        }
        print(filterCheckNote)
        return(currentStatus)
    })

    return(filterCheck)
}
