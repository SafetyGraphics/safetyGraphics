library(ggplot2)
library(dplyr)
library(tidyr)


custom_ggplot <- function(data, settings){
  
  id_col <- settings[["id_col"]]
  value_col <- settings[["value_col"]]
  measure_col <- settings[["measure_col"]]
  measure_alt <- settings[["measure_values"]][["ALT"]]
  measure_tb <- settings[["measure_values"]][["TB"]]
  group <- settings[["group_cols"]][1]
  normal_col_high <- settings[["normal_col_high"]]
  studyday_col <- settings[["studyday_col"]]
  
  if (!is.null(group)){
    d <- data %>% 
      select(id_col = id_col, 
             measure_col = measure_col, 
             value_col = value_col, 
             normal_col_high = normal_col_high, 
             studyday_col = studyday_col,
             group = group) %>%
      filter(measure_col %in% c(measure_alt, measure_tb)) %>% 
      group_by(id_col, measure_col) %>% 
      filter(value_col==max(value_col)) %>% 
      mutate(peak_val_uln = value_col/normal_col_high) %>% 
      unique %>% 
      slice(1) %>% 
      group_by(id_col) %>% 
      unique %>% 
      mutate(days_between = abs(studyday_col[1]-studyday_col[2])) %>% 
      select(id_col,group,  measure_col, peak_val_uln, days_between) %>% 
      unique %>% 
      spread(measure_col, peak_val_uln) %>% 
      setNames(., c("id","group","days_between", "alt","tb")) %>% 
      na.omit %>% 
      ungroup %>% 
      mutate(hys_law = 100*sum(alt>3 & tb>2)/n(),
             hyper = 100*sum(alt <3 & tb >2)/n(),
             temple = 100*sum(alt >3 & tb <2)/n(),
             normal = 100*sum(alt <3 & tb <2)/n()
      ) %>% 
      mutate_at(vars(hys_law:normal), ~ paste0(format(round(.,1), nsmall=1), "%"))
    
    plottext <- data.frame(
      xpos = c(Inf,-Inf,Inf,-Inf),
      ypos =  c(Inf, Inf,-Inf,-Inf),
      hjust = c(1.1,-0.1,1.1,-0.1) ,
      vjust = c(1.3,1.3,-0.3,-0.3),
      text1 = c("Possible Hy's Law Range", 
                "Hyperbilirubinemia",
                "Temple's Corollary",
                "Normal Range"),
      text2 = as.character(unique(select(d, hys_law:normal)))) 
    
    p <- ggplot(data=d, aes(alt, tb)) +
      geom_point(size = 2, alpha=0.7,aes(color=group, shape=factor(days_between<=30))) +
      scale_shape_manual(values = c(1, 19), guide=FALSE) + 
      theme_bw()  +
      geom_hline(yintercept = 2, lty=2, color="darkgray")+
      geom_vline(xintercept = 3, lty=2, color="darkgray") +
      theme(legend.position = "top",
            legend.title=element_blank()) +
      scale_x_continuous(name = paste(measure_alt, "[xULN]"),
                         breaks = seq(0, round(max(d$alt)+0.5,1), 0.5),
                         labels =  function(x) sprintf("%.1f", x))+
      scale_y_continuous(name = paste(measure_tb, "[xULN]"),
                         breaks = seq(0, round(max(d$tb),1), 1),
                         labels =  function(x) sprintf("%.1f", x)) +
      geom_text(data=plottext,
                aes(x=xpos,y=ypos,
                    hjust=hjust,vjust=vjust,
                    label=paste(text1, text2)),
                color = 'black', size=3)
  } else {
    d <- data %>% 
      select(id_col = id_col, 
             measure_col = measure_col, 
             value_col = value_col, 
             normal_col_high = normal_col_high, 
             studyday_col = studyday_col) %>%
      filter(measure_col %in% c(measure_alt, measure_tb)) %>% 
      group_by(id_col, measure_col) %>% 
      filter(value_col==max(value_col)) %>% 
      mutate(peak_val_uln = value_col/normal_col_high) %>% 
      unique %>% 
      slice(1) %>% 
      group_by(id_col) %>% 
      unique %>% 
      mutate(days_between = abs(studyday_col[1]-studyday_col[2])) %>% 
      select(id_col,measure_col, peak_val_uln, days_between) %>% 
      unique %>% 
      spread(measure_col, peak_val_uln) %>% 
      setNames(., c("id","days_between", "alt","tb")) %>% 
      na.omit %>% 
      ungroup %>% 
      mutate(hys_law = 100*sum(alt>3 & tb>2)/n(),
             hyper = 100*sum(alt <3 & tb >2)/n(),
             temple = 100*sum(alt >3 & tb <2)/n(),
             normal = 100*sum(alt <3 & tb <2)/n()
      ) %>% 
      mutate_at(vars(hys_law:normal), ~ paste0(format(round(.,1), nsmall=1), "%"))
    
    plottext <- data.frame(
      xpos = c(Inf,-Inf,Inf,-Inf),
      ypos =  c(Inf, Inf,-Inf,-Inf),
      hjust = c(1.1,-0.1,1.1,-0.1) ,
      vjust = c(1.3,1.3,-0.3,-0.3),
      text1 = c("Possible Hy's Law Range", 
                "Hyperbilirubinemia",
                "Temple's Corollary",
                "Normal Range"),
      text2 = as.character(unique(select(d, hys_law:normal)))) 
    
    p <- ggplot(data=d, aes(alt, tb)) +
      geom_point(size = 2, alpha=0.7,aes(shape=factor(days_between<=30))) +
      scale_shape_manual(values = c(1, 19), guide=FALSE) + 
      theme_bw()  +
      geom_hline(yintercept = 2, lty=2, color="darkgray")+
      geom_vline(xintercept = 3, lty=2, color="darkgray") +
      theme(legend.position = "top",
            legend.title=element_blank()) +
      scale_x_continuous(name = paste(measure_alt, "[xULN]"),
                         breaks = seq(0, round(max(d$alt)+0.5,1), 0.5),
                         labels =  function(x) sprintf("%.1f", x))+
      scale_y_continuous(name = paste(measure_tb, "[xULN]"),
                         breaks = seq(0, round(max(d$tb),1), 1),
                         labels =  function(x) sprintf("%.1f", x)) +
      geom_text(data=plottext,
                aes(x=xpos,y=ypos,
                    hjust=hjust,vjust=vjust,
                    label=paste(text1, text2)),
                color = 'black', size=3)
  }
  return(p)
}

