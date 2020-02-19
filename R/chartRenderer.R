#' Create an interactive graphics widget
#'
#' This function creates an nice interactive widget. See the vignettes for more details regarding how to customize charts.
#'
#' @param data A data frame containing the labs data. Data must be structured as one record per study participant per time point per lab measure.
#' @param debug_js print settings in javascript before rendering chart. Default: \code{FALSE}.
#' @param settings Optional list of settings arguments to be converted to JSON using \code{jsonlite::toJSON(settings, auto_unbox = TRUE, dataframe = "rows", null = "null")}. Default: \code{NULL}.
#' @param chart name of the chart to render
#'
#' @examples
#' \dontrun{
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
#' chartRenderer(data=adlbc, settings = settingsl, chart=safetyhistogram)
#'
#' }
#'
#' @import htmlwidgets
#'
#' @export
chartRenderer <- function(data, debug_js = FALSE, settings = NULL, chart=NULL) {
  # load chart metadata (use custom data if available)
  chartmeta<-safetyGraphics::chartsMetadata
  if(!(is.null(options('sg_chartsMetadata')[[1]]))){ #if the option exists
    if(options('sg_chartsMetadata')[[1]]){ #and it's set to true
      chartmeta<-options('sg_chartsMetadata_df')[[1]]
    }
  }

  # Chart specific customiztions (to be removed after js updates)
  if(chart %in% c("paneledoutlierexplorer","safetyoutlierexplorer")){
    settings$time_cols <- list(list(),list());
    settings$time_cols[[1]]<-list(
      type= "ordinal",
      value_col= settings[["visit_col"]],
      label= "Visit",
      order_col= settings[["visitn_col"]],
      order= NULL,
      rotate_tick_labels= TRUE,
      vertical_space= 100
    )
    settings$time_cols[[2]]<-list(
      type= "linear",
      value_col= settings[["studyday_col"]],
      label= "Study Day",
      order_col= settings[["studyday_col"]],
      order= NULL,
      rotate_tick_labels= FALSE,
      vertical_space= 0
    )
  }

  if(chart=="paneledoutlierexplorer"){
    settings$lln_col <- settings[["normal_col_low"]]
    settings$uln_col <- settings[["normal_col_high"]]
  }

  if(chart=="safetyshiftplot"){
    settings$time_col<-settings[["visit_col"]]
  }

  if(chart=="safetyresultsovertime"){
    settings$time_settings=list(
      value_col= settings[["visit_col"]],
      label= "Visit",
      order_col= settings[["visitn_col"]],
      order= NULL,
      rotate_tick_labels= TRUE,
      vertical_space= 100
    )

    settings$groups = settings$group_cols
  }

  if(chart=="aeexplorer"){
    settings$variables=list(
      major=settings[["bodsys_col"]],
      minor=settings[["term_col"]],
      group=settings[["trt_col"]],
      id=settings[["id_col"]],
      filters=settings[["filters"]],
      details=settings[["details"]]
    )
  }

  #Set Chart Width
  chartMaxWidth<-  chartmeta %>% filter(.data$chart==!!chart) %>% pull(.data$maxWidth)
  settings$max_width <- chartMaxWidth

  #Renderer
  chartFunction<- chartmeta %>% filter(.data$chart==!!chart) %>% pull(.data$main)
  subFunction<- chartmeta %>% filter(.data$chart==!!chart) %>% pull(.data$sub)
  chartType <- chartmeta %>% filter(.data$chart==!!chart) %>% pull(.data$type)

  rSettings = list(
    data = data,
    debug_js=debug_js,
    chartFunction = chartFunction,
    subFunction = subFunction,
    settings = jsonlite::toJSON(
      settings,
      auto_unbox = TRUE,
      null = "null"
    )
  )

  if (chartType=="htmlwidget"){
    # create widget
    htmlwidgets::createWidget(
      name = 'chartRenderer',
      rSettings,
      # width = width,
      # height = height,
      package = 'safetyGraphics',
      sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE)
    )
  } else {
    createChart(chartType, rSettings)
  }
}

#' Shiny bindings for chartRenderer
#'
#' Output and render functions for using safetyhistogram within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a chart
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name chartRenderer-shiny
#'
#' @export
output_chartRenderer <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'chartRenderer', width, height, package = 'safetyGraphics')
}

#' @rdname chartRenderer-shiny
#' @export
render_chartRenderer <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, output_chartRenderer, env, quoted = TRUE)
}
