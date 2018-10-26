getSettingKeys<-function(patterns, settings, parents=NULL){
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
      if(typeof(value) == "list"){
        nestedMatches <- getSettingKeys(patterns=patterns, settings=value, parents=keys)
        matches <- do.call(c, list(matches,nestedMatches)) 
      } else {
        #if the paramter isn't a list, check to see if the key matches the specified patterns.
        if(any(str_detect(key,patterns))){
          nextItem<-length(matches)+1
          matches[[nextItem]]<-keys
        }
      } 
    }    
  }
  
  return(matches)
}

