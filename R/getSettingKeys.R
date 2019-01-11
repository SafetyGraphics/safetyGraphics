#' Get setting keys matching a pattern 
#'
#' Recursive function to find all keys matching a given text pattern in a settings list
#'
#' This function loops through all named elements (or "keys") in a \code{settings} list and returns items that match \code{patterns}. If \code{matchLists==FALSE} (the default), the function iteratively looks through the named elements in nested lists using the built-in \code{parents} parameter. The function returns a array of keys for all matches using a list of lists. Each key is defines the postition of a matching key using an unnamed list. For example, \code{list("filters",2,"value_col")} would correspond to \code{settings[["filters"]][[2]][["value_col"]]}.
#' 
#' @param patterns List  of text patterns to match with named elements in \code{settings}.
#' @param settings List of settings used to generate a chart like \code{eDISH()}.
#' @param parents List containing the position of the parent list using recusive matches.
#' @param matchLists Boolean indicating whether keys containing lists should be returned as matches.
#' @return List of lists specifying the position of matching named elements in the format \code{list("filters",2,"value_col")}, which would correspond to \code{settings[["filters"]][[2]][["value_col"]]}.
#' 
#' @examples 
#' testSettings<-generateSettings(standard="AdAM")
#' 
#' # returns list of all matching values
#' safetyGraphics:::getSettingKeys(patterns=c("_col"),
#'                                 settings=testSettings)
#' 
#' #finds the matching nested setting 
#' safetyGraphics:::getSettingKeys(patterns=c("ALP"),
#'                                 settings=testSettings) 
#' 
#' #returns an empty list, since the only matching item is a list
#' safetyGraphics:::getSettingKeys(patterns=c("measure_values"),
#'                                 settings=testSettings) 
#' 
#' #finds the matching key associated with a list
#' safetyGraphics:::getSettingKeys(patterns=c("measure_values"),
#'                                 settings=testSettings, 
#'                                 matchLists=TRUE) 
#' 
#' @importFrom stringr str_detect 
#' 



getSettingKeys<-function(patterns, settings, parents=NULL, matchLists=FALSE){
  stopifnot(typeof(patterns)=="character", typeof(settings)=="list", is.null(parents)||typeof(parents)=="list")
  matches<-list()
  
  if(is.null(names(settings)) & length(settings) >0){
    #Loop through unnamed lists and capture keys from nested lists
    i<-0
    for(item in settings){
      i<-i+1
      keys<-parents
      nextKey<-length(keys)+1
      keys[[nextKey]]<-i
      nestedMatches <- getSettingKeys(patterns=patterns, settings=item, parents=keys)
      matches <- do.call(c, list(matches,nestedMatches)) 
    }
  }else{
    #Check each parameter in named lists
    for(key in names(settings)){
      value<-settings[[key]]
      
      #update the keys (needed to handle nesting)
      if(is.null(parents)){
        keys<-list(key)
      }else{
        keys<-parents
        nextKey<-length(keys)+1
        keys[[nextKey]]<-key
      }
      
      #if the parameter is a list, iterate
      if(typeof(value) == "list" & !matchLists){
        nestedMatches <- getSettingKeys(patterns=patterns, settings=value, parents=keys)
        matches <- do.call(c, list(matches,nestedMatches)) 
      } else {
        #if the paramter isn't a list, check to see if the key matches the specified patterns.
        if(any(stringr::str_detect(key,patterns))){
          nextItem<-length(matches)+1
          matches[[nextItem]]<-keys
        }
      } 
    }    
  }
  
  return(matches)
}

