createChartTab <- function(chart){
  tab_title <- HTML(paste(chart, icon("question-circle", class="maybe")))
  tabfun <- match.fun(paste0("render_", chart, "_chartUI"))  # module UI for given tab
  tabcode <- tabPanel(title = tab_title, tabfun(paste0("chart", chart)))
  chartTab <- appendTab(inputId = "tabs",  tabcode, menuName = "Charts")
  return(chartTab)
}
