#' Create an edish widget
#'
#' This function creates an \href{https://github.com/SafetyGraphics/safety-eDISH/}{interactive graphic} for the Evaluation of Drug-Induced Serious Hepatotoxicity (edish). See the \href{https://github.com/SafetyGraphics/safety-eDISH/wiki/Configuration}{chart docuemtnation} for details regarding the settings object.
#'
#' @param data A data frame containing the labs data. Data must be structured as one record per study participant per time point per lab measure.
#' @param debug_js print settings in javascript before rendering chart. Default: \code{FALSE}.
#' @param settings  List of settings arguments to be converted to JSON using: \preformatted{
#' jsonlite::toJSON(
#'   settings,
#'   auto_unbox = TRUE,
#'   dataframe = "rows",
#'   null = "null"
#' )}
#'
#' Default: \code{NULL}.
#'
#' @examples
#' \dontrun{
#'
#' ## Create edish figure using a premade settings list
#' group_cols_list <- list(
#'   list(value_col = "TRTP", label = "Treatment"),
#'   list(value_col = "SEX", label = "Sex"),
#'   list(value_col = "AGEGR1", label = "Age group")
#' )
#'
#'
#' filters_list <- list(
#'   list(value_col = "TRTA", label = "Treatment"),
#'   list(value_col = "SEX", label = "Sex"),
#'   list(value_col = "RACE", label = "RACE"),
#'   list(value_col = "AGEGR1", label = "Age group")
#' )
#'
#' settingsl <- list(id_col = "USUBJID",
#'       value_col = "AVAL",
#'       measure_col = "PARAM",
#'       visit_col = "VISIT",
#'       visitn_col = "VISITNUM",
#'       studyday_col = "ADY",
#'       normal_col_low = "A1LO",
#'       normal_col_high = "A1HI",
#'       group_cols = group_cols_list,
#'       filters = filters_list,
#'       measure_values = list(ALT = "Alanine Aminotransferase (U/L)",
#'                             AST = "Aspartate Aminotransferase (U/L)",
#'                             TB = "Bilirubin (umol/L)",
#'                             ALP = "Alkaline Phosphatase (U/L)"))
#' edish(data=adlbc, settings = settingsl)
#'
#' }
#'
#' @import htmlwidgets
#'
#' @export
edish <- function(data,  debug_js = FALSE, settings = NULL) {
  rSettings = list(
    data = data,
    settings = jsonlite::toJSON(
      settings,
      auto_unbox = TRUE,
      null = "null"
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'edish',
    rSettings,
   # width = width,
   # height = height,
    package = 'safetyGraphics',
    sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE)
  )
}

#' Shiny bindings for edish
#'
#' Output and render functions for using edish within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a edish
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name edish-shiny
#'
#' @export
output_edish <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'edish', width, height, package = 'safetyGraphics')
}

#' @rdname edish-shiny
#' @export
render_edish <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, output_edish, env, quoted = TRUE)
}
