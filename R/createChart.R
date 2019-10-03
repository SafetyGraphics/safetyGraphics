#' Create a custom static or plotly R graphic
#'
#' @param type Type of chart. Options are \code{"static"} or \code{plotly}.
#' @param rSettings List containing all arguments needed for chart creation: 
#' \code{rSettings = list(
#' data = data,
#' debug_js=debug_js,
#' chartFunction = chartFunction,
#' settings = jsonlite::toJSON(
#'   settings,
#'   auto_unbox = TRUE,
#'   null = "null"
#' ))}
#' 
#' @keywords internal
createChart <- function(type, rSettings){
  
  data <- rSettings[["data"]]
  settings <- jsonlite::fromJSON(rSettings[["settings"]])
  chartFunction <- rSettings[["chartFunction"]]
  
  chartCode <- system.file("custom", type, paste0(chartFunction, ".R"), package = "safetyGraphics")
  source(chartCode)
  chartFunction <- match.fun(chartFunction)
  chartFunction(data, settings)
  
}
