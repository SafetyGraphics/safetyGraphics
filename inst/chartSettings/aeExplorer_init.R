aeExplorer_init<- function(data, settings){
    settings$variables=list(
        major=settings[["bodsys_col"]],
        minor=settings[["term_col"]],
        group="STUDYID",
        id=settings[["id_col"]],
        filters=list(),
        details=list()
    )
    return(list(data=data,settings=settings))
}