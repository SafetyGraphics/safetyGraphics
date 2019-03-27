#' Get chart-specific settings
#'
#' Subset master settings list to chart-specific settings list only
#'
#' @param settings Settings list containing settings for all selected charts.
#' @param chart The chart for which settings should be returned.
#'
#' @return Chart-specific settings
#'
#' @examples
#' settings <- safetyGraphics::generateSettings(standard="ADaM")
#' safetyGraphics:::getChartSettings(settings = settings, chart = "edish")
#' 
#' @keywords internal
#' 
getChartSettings <- function(settings, chart){
  settings_names <- names(safetyGraphics::generateSettings("None",chart=chart))
  return(settings[settings_names])
}
