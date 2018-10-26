getSettingValue <- function(key,settings){
  stopifnot(typeof(settings)=="list")
  
  # Get the value for the first key
  firstKey <- key[[1]]
  value <- settings[[firstKey]]
  
  
  if(length(key)>1 ){
    #If there are more keys and the value is a list, iterate
    if(typeof(value)=="list"){
      value<-getSettingValue(key[2:length(key)],value)  
    }else{
      #If there are more keys, but the value is not a list, return NULL
      value<-NULL
    }
  }
  return(value)
}