#' Create an eDISH widget
#'
#' This function creates an interactive graphic for the Evaluation of Drug-Induced Serious Hepatotoxicity (eDISH)
#'
#' @param data A data frame containing the labs data. Data must be structured as one record per study participant per time point per lab measure. 
#' 
#' @import htmlwidgets
#'
#' @export
eDISH <- function(data) {

  # forward options using x
  rSettings = list(
    data = data
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'eDISH',
    rSettings,
   # width = width,
   # height = height,
    package = 'ReDish' #,
   # sizingPolicy = htmlwidgets::sizingPolicy(viewer.fill=FALSE)
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
