library(ggplot2)
library(dplyr)
library(tidyr)

missingdata <- function(data, settings){
  id_col <- settings[["id_col"]]
  value_col <- settings[["value_col"]]
  measure_col <- settings[["measure_col"]]
  visit_col <- settings[["visit_col"]]
  visitn_col <- settings[["visitn_col"]]
  
  
  d <- data %>% 
    select(id_col, measure_col, value_col, visit_col, visitn_col) %>%
    group_by(.data[[measure_col]], .data[[visit_col]], .data[[visitn_col]]) %>% 
    summarise_at(vars(value_col), list(`Missing` = ~100*sum(is.na(.))/n(), 
                                       `Non-Missing` = ~100*sum(!is.na(.))/n())) %>% 
    gather(var, val, `Missing`:`Non-Missing`) %>% 
    na.omit  
  
  ggplot(d, aes_string(y="val", 
                       x=paste0("reorder(",visit_col,",", visitn_col,")"), color="var", fill="var")) +
    geom_bar(stat="identity", position="dodge") +
    facet_wrap(~PARAM, ncol=1) +
    theme_bw() +
    labs(y = "% of\nSubjects",
         x="") +
    theme(
      legend.position="bottom",
      legend.title = element_blank(),
      axis.title.y = element_text(angle = 0)
    )  
}
