#' Create an eDISH widget
#'
#' This function creates an interactive graphic for the Evaluation of Drug-Induced Serious Hepatotoxicity (eDISH)
#'
#' @param data A data frame containing the labs data. Data must be structured as one record per study participant per time point per lab measure. 
#' @param id_col Unique subject identifier variable name. Default: \code{"USUBJID"}.
#' @param value_col Lab result variable name. Default: \code{"STRESN"}. 
#' @param measure_col Lab measure variable name. Default: \code{"TEST"}.
#' @param unit_col Lab measure unit variable name. Default: \code{"STRESU"}.
#' @param normal_col_low Lower limit of normal variable name. Default: \code{"STNRLO"}.
#' @param normal_col_high Upper limit of normal variable name. Default: \code{"STNRHI"}. 
#' @param visitn_col Visit number variable name. Default: \code{"VISITN"}. 
#' @param baseline_visitn Value of baseline visit number. Used to calculate mDish. Default: \code{1}. 
#' @param filters An optional data frame of filters ("value_col") and associated metadata ("label"). Default: \code{NULL}.
#' @param group_cols  An optional vector of names of grouping variables. Default: \code{NULL}.
#' @param measure_values A list defining the data values from \code{measure_col} for the lab measures 
#' used in eDish evaluations. Default: \code{list(ALT = 'Aminotransferase, alanine (ALT)', 
#' AST = 'Aminotransferase, aspartate (AST)', TB = 'Total Bilirubin', ALP = 'Alkaline phosphatase (ALP)')}.
#' @param x_options Specifies variable options for the x-axis using the key values from \code{measure_values} (e.g. "ALT"). 
#' When multiple options are specified, a control allowing the user to interactively change the x variable is shown. Default: \code{c("ALT", "AST", "ALP")}.
#' @param y_options Specifies variable options for the y-axis using the key values from \code{measure_values} (e.g. "TB"). 
#' When multiple options are specified, a control allowing the user to interactively change the y variable is shown. Default: \code{"TB"}.
#' @param measure_bounds Sets upper and lower percentiles used for defining outliers in the "Lab Summary Table"
#' in the participant details section. Default: \code{c(0.01, 0.99)}.
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
#'  
#' @import htmlwidgets
#'
#' @export
eDISH <- function(data,
                  id_col = "USUBJID",
                  value_col = "STRESN",
                  measure_col = "TEST",
                  unit_col = "STRESU",
                  normal_col_low = "STNRLO",
                  normal_col_high = "STNRHI",
                  visitn_col = "VISITN",
                  baseline_visitn = 1,
                  filters = NULL,
                  group_cols = NULL,
                  measure_values = list(ALT = "Aminotransferase, alanine (ALT)",
                                        AST = "Aminotransferase, aspartate (AST)",
                                        TB = "Total Bilirubin",
                                        ALP = "Alkaline phosphatase (ALP)"),
                  x_options = c("ALT", "AST", "ALP"),
                  y_options = "TB", 
                  measure_bounds = c(0.01, 0.99),
                  visit_window = 30,
                  r_ratio_filter = TRUE,
                  r_ratio_cut = 0,
                  showTitle = TRUE,
                  warningText = "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures.") {

  
  # # define filters object
  # filters <- filters
  # if (is.null(filters)){
  #   if (is.null(filters_value_col)){
  #     filters <- NULL    # no filters specified
  #   } else {
  #     if (is.null(filters_label)){
  #       filters_label = filters_value_col
  #     }
  #     filters <- data.frame(value_col = filters_value_col,   
  #                           label = filters_label)
  #   }
  # }
  # 
  # # define group_cols object
  # group_cols <- group_cols
  # if (is.null(group_cols)){
  #   if (is.null(group_cols_value_col)){
  #     group_cols <- NULL    # no group_cols specified
  #   } else {
  #     if (is.null(group_cols_label)){
  #       group_cols_label = group_cols_value_col
  #     }
  #     group_cols <- data.frame(value_col = group_cols_value_col,   
  #                           label = group_cols_label)
  #   }
  # }

  # forward options using x
  rSettings = list(
    data = data,
    settings = jsonlite::toJSON(
      list(
        id_col = id_col, 
        value_col = value_col,
        measure_col = measure_col,
        unit_col = unit_col,
        normal_col_low = normal_col_low,
        normal_col_high = normal_col_high,
        visitn_col = visitn_col,
        baseline_visitn = baseline_visitn,
        filters = filters,
        group_cols = group_cols,
        measure_values = measure_values,
        x_options = x_options,
        y_options = y_options,
        measure_bounds = measure_bounds,
        visit_window = visit_window,
        r_ratio_filter = r_ratio_filter,
        r_ratio_cut = r_ratio_cut,
        showTitle = showTitle,
        warningText = warningText
      ),
      auto_unbox = TRUE,
      dataframe = "rows"
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'eDISH',
    rSettings,
   # width = width,
   # height = height,
    package = 'ReDish',
    sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress = TRUE)
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
  htmlwidgets::shinyWidgetOutput(outputId, 'eDISH', width, height, package = 'ReDish')
}

#' @rdname eDISH-shiny
#' @export
renderEDISH <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, eDISHOutput, env, quoted = TRUE)
}
