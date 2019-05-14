#' Charts Metadata
#'
#' Metadata about the charts available in the shiny app
#'
#' @format A data frame with 29 rows and 7 columns
#' \describe{
#'    \item{chart}{Name of the chart - one word, all lower case}
#'    \item{label}{Nicely formatted name of the chart}
#'    \item{description}{Description of the chart}
#'    \item{repo_url}{Homepage for chart's code repository (if any)}
#'    \item{settings_url}{Homepage for chart's settings documentation}
#'    \item{main}{Name of the main function used to initialize the app. The function must accept "location" and "settings" parameters (in that order) and have an .init() method, expecting a json data array.}
#'    \item{type}{type of chart (e.g. 'htmlwidget')}
#'    \item{maxWidth}{max width for the widget}
#' }
#'
#' @source Created for this package
"chartsMetadata"
