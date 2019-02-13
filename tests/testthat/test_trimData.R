data <- adlbc
settings<-generateSettings(standard="AdAM")

settings[['baseline']][['value_col']] <- 'TRTA'
settings[['baseline']][['values']] <- list("Placebo","Xanomeline High Dose")
