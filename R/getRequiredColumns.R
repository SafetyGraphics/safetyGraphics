getRequiredColumns<-function(standard,chart="eDish"){
  stopifnot(
    typeof(standard)=="character",
    typeof(chart)=="character",
    tolower(chart)=="edish"
  )
  
  if(tolower(chart)=="edish"){
    if(tolower(standard)=="adam"){
      return(c("USUBJID","AVAL","PARAM","VISIT","VISITNUM","ADY","A1LO","A1HI"))
    }else if(tolower(standard)=="sdtm"){
     return(c("USUBJID","STRESN","TEST","VISIT","VISITNUM","DY","STNRLO","STNRHI")) 
    }
  }
}