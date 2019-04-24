#' Create a Safety Histogram widget
#'
#' This function creates a Safety Histogram using R htmlwidgets.  
#'
#' @param data A data frame containing the labs data. Data must be structured as one record per study participant per time point per lab measure. 
#' @param id_col Unique subject identifier variable name. Default: \code{"USUBJID"}.
#' @param value_col Lab result variable name. Default: \code{"STRESN"}. 
#' @param measure_col Lab measure variable name. Default: \code{"TEST"}.
#' @param normal_col_low Lower limit of normal variable name. Default: \code{"STNRLO"}.
#' @param normal_col_high Upper limit of normal variable name. Default: \code{"STNRHI"}. 
#' @param unit_col   Unit of measure variable name. Default is \code{"STRESU"}.
#' @param filters An optional list of specifications for filters.  Each filter is a nested, named list (containing the filter value column: "value_col" and associated label: "label") within the larger list. Default: \code{NULL}.
#' @param details An optional list of specifications for details listing.  Each column to be added to details listing is a nested, named list (containing the variable name: "value_col" and associated label: "label") within the larger list. Default: \code{NULL}.
#' @param start_value Value of variable defined in \code{measure_col} to be rendered in the histogram when the widget loads. 
#' @param missingValues Vector of values defining a missing \code{value_col}. Default is \code{c('','NA','N/A')}.
#' @param debug_js print settings in javascript before rendering chart. Default: \code{FALSE}.
#' @param settings Optional list of settings arguments to be converted to JSON using \code{jsonlite::toJSON(settings, auto_unbox = TRUE, dataframe = "rows", null = "null")}.  If provided, all other function parameters are ignored. Default: \code{NULL}.
#'
#' @examples 
#' \dontrun{
#' 
#' ## Create Histogram figure customized to user data
#'safetyhistogram(data=adlbc, 
#'                id_col = "USUBJID",
#'                value_col = "AVAL", 
#'                measure_col = "PARAM", 
#'                normal_col_low = "A1LO", 
#'                normal_col_high = "A1HI", 
#'                unit_col = "PARAMCD")
#' 
#' ## Create Histogram figure using a premade settings list
#' details_list <- list(
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
#'       unit_col = "PARAMCD",
#'       normal_col_low = "A1LO", 
#'       normal_col_high = "A1HI", 
#'       details = details_list,
#'       filters = filters_list)
#'       
#' safetyhistogram(data=adlbc, settings = settingsl)
#' 
#' }
#' 
#' @import htmlwidgets
#'
#' @export
safetyhistogram <- function(data,
                            id_col = "USUBJID",
                            value_col = "STRESN",
                            measure_col = "TEST",
                            normal_col_low = "STNRLO",
                            normal_col_high = "STNRHI",
                            unit_col = "STRESU",
                            filters = NULL,
                            details = NULL,
                            start_value = NULL,
                            missingValues = c("","NA","N/A"),
                            debug_js = FALSE,
                            settings = NULL) {

  # forward options using rSettings
  if (is.null(settings)){
    rSettings = list(
      data = data,
      settings = jsonlite::toJSON(
        list(
          id_col = id_col, 
          value_col = value_col,
          measure_col = measure_col,
          normal_col_low = normal_col_low,
          normal_col_high = normal_col_high,
          unit_col = unit_col, 
          filters = filters,
          details = details,
          start_value = start_value,
          missingValues = missingValues,
          debug_js = debug_js
        ),
        auto_unbox = TRUE,
        null = "null"
      )
    )    
  } else{
    rSettings = list(
      data = data,
      settings = jsonlite::toJSON(settings,
                                  auto_unbox = TRUE,
                                  null = "null")
    )
  }

  # create widget
  htmlwidgets::createWidget(
    name = 'safetyhistogram',
    rSettings,
    # width = width,
    # height = height,
    package = 'safetyGraphics',
    sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE)
    
  )
}

#' Shiny bindings for safetyhistogram
#'
#' Output and render functions for using safetyhistogram within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a safetyhistogram
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name safetyhistogram-shiny
#'
#' @export
output_safetyhistogram <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'safetyhistogram', width, height, package = 'safetyGraphics')
}

#' @rdname safetyhistogram-shiny
#' @export
render_safetyhistogram <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, output_safetyhistogram, env, quoted = TRUE)
}
