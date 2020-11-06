library(dplyr)
library(ggplot2)

safety_histogram_chart <- function(data, settings, description="Safety Histogram"){
  id_col <- settings[["id_col"]]
  value_col <- settings[["value_col"]]
  measure_col <- settings[["measure_col"]]
  normal_col_low <- settings[["normal_col_low"]]
  normal_col_high <- settings[["normal_col_high"]]
  unit_col <- settings[["unit_col"]]
  
  # prep data
  dd <- data %>%
    select(one_of(c(id_col, value_col,  measure_col, normal_col_low, normal_col_high))) %>%
    setNames(., c("id_col","value_col","measure_col","normal_col_low","normal_col_high")) %>%
    filter(!is.na(value_col))

  # get labels for fig
  ylab <- "# of\nObservations"
  plot_title <- description

  # color for histogram
  col <- RColorBrewer::brewer.pal(3, "Set2")[1]

  p <- ggplot(data=dd) +
    geom_rect(
      aes(
        xmin=normal_col_low , 
        xmax=normal_col_high, 
        ymin=-Inf, 
        ymax=Inf
      ),
      alpha=0.5, 
      stat="identity", 
      fill = "gray90", 
      color="gray70"
    )+
    geom_histogram(
      aes(
        x=value_col
      ), 
      fill=col, 
      alpha=0.6, 
      color=col
    )+
    theme_bw() +
    labs(
      x="",
      y=ylab,
      title=plot_title
    ) +
    facet_wrap(
      vars(measure_col),
      scales="free_x"
    )
    

  return(p)
}
