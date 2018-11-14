#' Create an eDISH widget
#'
#' This function creates an interactive graphic for the Evaluation of Drug-Induced Serious Hepatotoxicity (eDISH)
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
#' @param baseline_visitn Value of baseline visit number. Used to calculate mDish. Default: \code{1}. 
#' @param filters An optional data frame of filters ("value_col") and associated metadata ("label"). Default: \code{NULL}.
#' @param group_cols An optional data frame of filters ("value_col") and associated metadata ("label"). Default: \code{NULL}.
#' @param measure_values A list defining the data values from \code{measure_col} for the lab measures 
#' used in eDish evaluations. Default: \code{list(ALT = 'Aminotransferase, alanine (ALT)', 
#' AST = 'Aminotransferase, aspartate (AST)', TB = 'Total Bilirubin', ALP = 'Alkaline phosphatase (ALP)')}.
#' @param x_options Specifies variable options for the x-axis using the key values from \code{measure_values} (e.g. "ALT"). 
#' When multiple options are specified, a control allowing the user to interactively change the x variable is shown. Default: \code{c("ALT", "AST", "ALP")}.
#' @param y_options Specifies variable options for the y-axis using the key values from \code{measure_values} (e.g. "TB"). 
#' When multiple options are specified, a control allowing the user to interactively change the y variable is shown. Default: \code{c("TB", "ALP")}.
#' @param analysisFlag An optional list defining which column \code{value_col} and values \code{values} should be used to records for use in eDish and mDish analyses. Default: \code{NULL}.
#' @param visit_window Default visit window used to highlight eDish points where x and y measures occurred within the specified number of days. 
#' Editable by user after render. Default: \code{30}.
#' @param r_ratio_filter Specifies whether the R Ratio filter should be shown. R ratio is defined as: 
#' (ALT value/ULN for ALT) / (ALP value/ULN for ALP). Default: \code{TRUE}.
#' @param r_ratio_cut Default cut point for R Ratio filter. Ignored when \code{r_ratio_filter = FALSE}. 
#' User can update this setting via the UI when \code{r_ratio_filter = TRUE}. Default: \code{0}.
#' @param showTitle Specifies whether the title should be drawn above the controls. Default: \code{TRUE}.
#' @param warningText Informational text to be displayed near the top of the controls (beneath the title, if any).
#'  No warning is displayed if \code{warningText = ""}. Default: \code{"Caution: This interactive graphic is 
#'  not validated. Any clinical recommendations based on this tool should be confirmed using your organizations 
#'  standard operating procedures."}.
#' @param debug_js print settings in javascript before rendering chart. Default: \code{FALSE}.

#' @param settings Optional list of settings arguments to be converted to JSON using \code{jsonlite::toJSON(settings, auto_unbox = TRUE, dataframe = "rows", null = "null")}.  If provided, all other function parameters are ignored. Default: \code{NULL}.
#'  
#' @examples 
#' \dontrun{
#' 
#' ## Create eDISH figure customized to user data
#' eDISH(data=adlbc, 
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
#' ## Create eDISH figure using a premade settings list
#' group_cols_vec <- c("TRTP","SEX", "AGEGR1")
#' 
#' filters_df <- data.frame(
#'   value_col=c("TRTA", "SEX", "RACE", "AGEGR1"),
#'   label = c("Treatment", "Sex", "RACE", "Age group")
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
#'       group_cols = group_cols_vec,
#'       filters = filters_df,
#'       measure_values = list(ALT = "Alanine Aminotransferase (U/L)",
#'                             AST = "Aspartate Aminotransferase (U/L)",
#'                             TB = "Bilirubin (umol/L)",
#'                             ALP = "Alkaline Phosphatase (U/L)"))
#' eDISH(data=adlbc, settings = settingsl)
#' 
#' }
#' 
#' @import htmlwidgets
#'
#' @export
eDISH <- function(data,
                  id_col = "USUBJID",
                  value_col = "STRESN",
                  measure_col = "TEST",
                  normal_col_low = "STNRLO",
                  normal_col_high = "STNRHI",
                  visit_col = "VISIT",
                  visitn_col = "VISITN",
                  studyday_col = "DY",
                  baseline_visitn = 1,
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
                  warningText = "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures.",
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
          visit_col = visit_col,
          visitn_col = visitn_col,
          studyday_col = studyday_col,
          baseline_visitn = baseline_visitn,
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
        dataframe = "rows",
        null = "null"
      )
    )    
  } else{
    rSettings = list(
      data = data,
      settings = jsonlite::toJSON(settings,
                                  auto_unbox = TRUE,
                                  dataframe = "rows",
                                  null = "null")
    )
  }


  # create widget
  htmlwidgets::createWidget(
    name = 'eDISH',
    rSettings,
   # width = width,
   # height = height,
    package = 'safetyGraphics',
    sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE)
  )
}

#' Shiny bindings for eDISH
#'
#' Output and render functions for using eDISH within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a eDISH
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name eDISH-shiny
#'
#' @export
eDISHOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'eDISH', width, height, package = 'safetyGraphics')
}

#' @rdname eDISH-shiny
#' @export
renderEDISH <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, eDISHOutput, env, quoted = TRUE)
}
