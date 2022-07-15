#' @title html chart summary
#' @description  makes a nicely formatted html summary for a chart object
#'
#' @param chart list containing chart specifications
#' @param showLinks boolean indicating whether to include links
#' @param class character to include as class
#'
#' @export

makeChartSummary <- function(chart, showLinks = TRUE, class = "chart-header") {
  if (utils::hasName(chart, "links")) {
    links <- purrr::map2(
      chart$links,
      names(chart$links),
      ~ a(
        .y,
        href = .x,
        class = "chart-link",
        target = "_blank"
      )
    )
    links <- div(tags$small("Links"), links)
  } else {
    links <- NULL
  }

  labelDiv <- div(tags$small("Chart"), chart$label)
  typeDiv <- div(tags$small("Type"), chart$type)
  dataDiv <- div(tags$small("Data Domain"), paste(chart$domain, collapse = " "))

  if (showLinks) {
    summary <- div(
      labelDiv,
      typeDiv,
      dataDiv,
      links,
      class = class
    )
  } else {
    summary <- div(
      labelDiv,
      typeDiv,
      dataDiv,
      class = class
    )
  }
  return(summary)
}
