library(Tplyr)
library(kableExtra)

tplyr_demog_chart <- function(data, settings){
  print(head(data))
  tab<-tplyr_table(data, ARM, cols = SEX) %>% 
    add_layer(
      group_count(RACE, by = "Race")
    ) %>% 
    add_layer(
      group_desc(AGE, by = "Age (Years)")
    ) %>% 
    build()
    
  return(tab)
}