#' Create an edish widget
#'
#' This function creates an interactive graphic for the Evaluation of Drug-Induced Serious Hepatotoxicity (edish)
#'
#' @param data A data frame containing the labs data. Data must be structured as one record per study participant per time point per lab measure. 
#' @param id_col Unique subject identifier variable name. Default: \code{"USUBJID"}.
#' @param value_col Lab result variable name. Default: \code{"STRESN"}. 
#' @param measure_col Lab measure variable name. Default: \code{"TEST"}.
#' @param normal_col_low Lower limit of normal variable name. Default: \code{"STNRLO"}.
#' @param normal_col_high Upper limit of normal variable name. Default: \code{"STNRHI"}. 
#' @param visit_col Visit variable name. Default: \code{"VISIT"}.
#' @param visitn_col Visit number variable name. Default: \code{"VISITN"}. 
#' @param studyday_col  Visit day variable name. Default: \code{"DY"}. 
#' @param baseline An optional list defining which column (\code{value_col}) and \code{values} (one or more) represent the baseline visit(s) of the study.
#' @param filters An optional list of specifications for filters.  Each filter is a nested, named list (containing the filter value column: "value_col" and associated label: "label") within the larger list. Default: \code{NULL}.
#' @param group_cols An optional list of specifications for grouping columns.  Each group column is a nested, named list (containing the group variable column: "value_col" and associated label: "label") within the larger list. Default: \code{NULL}.
#' @param measure_values A list defining the data values from \code{measure_col} for the lab measures 
#' used in edish evaluations. Default: \preformatted{list(ALT = 'Aminotransferase, alanine (ALT)', 
#'      AST = 'Aminotransferase, aspartate (AST)',
#'      TB = 'Total Bilirubin',
#'      ALP = 'Alkaline phosphatase (ALP)')}
#' @param x_options Specifies variable options for the x-axis using the key values from \code{measure_values} (e.g. "ALT"). 
#' When multiple options are specified, a control allowing the user to interactively change the x variable is shown. Default: \code{c("ALT", "AST", "ALP")}.
#' @param y_options Specifies variable options for the y-axis using the key values from \code{measure_values} (e.g. "TB"). 
#' When multiple options are specified, a control allowing the user to interactively change the y variable is shown. Default: \code{"TB"}.
#' @param analysisFlag An optional list defining which column (\code{value_col}) and \code{values} should be used in edish and mDish analyses. Default: \code{NULL}.
#' @param visit_window Default visit window used to highlight edish points where x and y measures occurred within the specified number of days. 
#' Editable by user after render. Default: \code{30}.
#' @param r_ratio_filter Specifies whether the R Ratio filter should be shown. R ratio is defined as: 
#' (ALT value/ULN for ALT) / (ALP value/ULN for ALP). Default: \code{TRUE}.
#' @param r_ratio_cut Default cut point for R Ratio filter. Ignored when \code{r_ratio_filter = FALSE}. 
#' User can update this setting via the UI when \code{r_ratio_filter = TRUE}. Default: \code{0}.
#' @param showTitle Specifies whether the title should be drawn above the controls. Default: \code{TRUE}.
#' @param warningText Informational text to be displayed near the top of the controls 
#' (beneath the  title, if any). No warning is displayed if \code{warningText = ""}. If \code{warningText = NULL},
#' default warning text will be displayed ("Caution: This interactive graphic is not validated. Any clinical 
#' recommendations based on this tool should be confirmed using your organizations 
#' standard operating procedures.").
#' @param debug_js print settings in javascript before rendering chart. Default: \code{FALSE}.

#' @param settings Optional list of settings arguments to be converted to JSON using: \preformatted{
#' jsonlite::toJSON(settings, auto_unbox = TRUE, 
#'                  dataframe = "rows", null = "null")}
#' If provided, all other function parameters are ignored. Default: \code{NULL}.
#'  
#' @examples 
#' \dontrun{
#' 
#' ## Create edish figure customized to user data
#' edish(data=adlbc, 
#'       id_col = "USUBJID",
#'       value_col = "AVAL", 
#'       measure_col = "PARAM", 
#'       visit_col = "VISIT",
#'       visitn_col = "VISITNUM", 
#'       studyday_col = "ADY",
#'       normal_col_low = "A1LO", 
#'       normal_col_high = "A1HI", 
#'       measure_values = list(ALT = "Alanine Aminotransferase (U/L)",
#'                             AST = "Aspartate Aminotransferase (U/L)",
#'                             TB = "Bilirubin (umol/L)",
#'                             ALP = "Alkaline Phosphatase (U/L)"))
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
edish <- function(data,
                  id_col = "USUBJID",
                  value_col = "STRESN",
                  measure_col = "TEST",
                  normal_col_low = "STNRLO",
                  normal_col_high = "STNRHI",
                  visit_col = "VISIT",
                  visitn_col = "VISITN",
                  studyday_col = "DY",
                  baseline = NULL,
                  filters = NULL,
                  group_cols = NULL,
                  analysisFlag= NULL,
                  measure_values = list(ALT = "Aminotransferase, alanine (ALT)",
                                        AST = "Aminotransferase, aspartate (AST)",
                                        TB = "Total Bilirubin",
                                        ALP = "Alkaline phosphatase (ALP)"),
                  x_options = c("ALT", "AST", "ALP"),
                  y_options =  "TB", 
                  visit_window = 30,
                  r_ratio_filter = TRUE,
                  r_ratio_cut = 0,
                  showTitle = TRUE,
                  debug_js=FALSE,
                  warningText = NULL, 
                  settings = NULL) {

  # If only one baseline value value specified, convert value to list 
  # this ensures that the value will stay in array format when auto_unbox=TRUE specified in toJSON()
  # ... file an issue to fix on JS side
  if (!is.null(baseline)){
    if (length(baseline[["values"]])==1){
      baseline[["values"]] <- list(baseline[["values"]])
    }
  }

  if (!is.null(settings$baseline$values)){
     if (length(settings$baseline[["values"]])==1){
       if (! is.list(settings$baseline[["values"]])){
        settings$baseline[["values"]] <- as.list(settings$baseline[["values"]])
       }
     }
  }
  
  # if warningText is NULL, use default warningText
  if(is.null(warningText)){
    warningText <- "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures."
  }
  if (!is.null(settings)){
    if(is.null(settings$warningText)){
      settings$warningText <- "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures."
    }
  }

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
          visit_col = visit_col,
          visitn_col = visitn_col,
          studyday_col = studyday_col,
          baseline = baseline,
          filters = filters,
          group_cols = group_cols,
          analysisFlag = analysisFlag,
          measure_values = measure_values,
          x_options = x_options,
          y_options = y_options,
          visit_window = visit_window,
          r_ratio_filter = r_ratio_filter,
          r_ratio_cut = r_ratio_cut,
          showTitle = showTitle,
          warningText = warningText,
          debug_js=debug_js
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
