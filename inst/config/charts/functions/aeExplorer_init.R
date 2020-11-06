library(dplyr)

aeExplorer_init<- function(data, settings){
    print(data)
    print(settings)
    dm_sub <- data$dm %>% select(settings[["dm"]][["id_col"]], settings[["dm"]][["treatment_col"]])
    anly <- dm_sub %>% left_join(data$aes)

    print(head(anly))

    settings<-c(settings$aes, settings$labs)
    
    settings$variables<-list(
        major=settings[["bodsys_col"]],
        minor=settings[["term_col"]],
        group=settings[["trt_col"]],
        id=paste0(settings[["id_col"]]),
        filters=list(),
        details=list()
    )

    settings$variableOptions<-list(
        group=c(
            settings[["treatment_values--group1"]],
            settings[["treatment_values--group2"]]
        )
    )

    settings$defaults = list(
        placeholderFlag = list(
            valueCol = settings[["bodsys_col"]],
            values = c("", NA, NULL)
        )
    )
    return(list(data=anly,settings=settings))
}