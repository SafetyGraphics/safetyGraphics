getSettingValue <- function(key,settings){
  if(typeof(settings)!="list"){
    stop("Settings parameter for getSettingValue must be a list")
  }
  firstKey <- key[[1]]
  value <- settings[[firstKey]]
  if(length(key)>1 ){
    if(typeof(value)=="list"){
      value<-getSettingValue(key[2:length(key)],value)  
    }else{
      value<-NULL
    }
  }
  return(value)
}