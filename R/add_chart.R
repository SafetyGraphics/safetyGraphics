
#' Add chart config (adapted from golem::add_module())
#' 
#' 
#' This function creates a module inside the local `config/` folder to define a new chart
#'   - dump yaml
#'   - create R scripts
#' 
#' @param path Path to store the chart configuration files, expecting a config root folder
#' 
#' +-- config
#'|  +-- aeExplorer.yaml
#'|  +-- newChart.yaml
#'
# |  \-- workflow
#'|      +-- aeExplorer_init.R
#'|      +-- newChart_main.R
#'
#' @param name The name of the chart (also name of the yaml file)
#' @param label Label of chart
#' @param type Type of chart: `plot`, `module`, or `htmlwidget`. Default is `plot` (static)
#' @param domain associated data domain, for example `aes`, `labs`, or `multiple`
#' @param package optional, R package that this chart is associated with.
#' @param workflow list of workflow functions appropriate for chart YAML
#' @param open boolean 
#' @param ... additional parameters for chart_template
#' 
#' @seealso [chart_template()]
#' 
#' @importFrom yaml write_yaml
#' 
#' @export

add_chart <- function(
  path,
  name = "newplot",
  label = "New Static Plot",
  type = "plot",
  domain = "labs",
  package = NULL,
  workflow = list(),
  open = TRUE,
  ...
){
  
  if (!requireNamespace("rprojroot", quietly = TRUE)) {
    stop("Package \"rprojroot\" needed for this function to work. Please install it.",
      call. = FALSE)
  }

  if (!requireNamespace("fs", quietly = TRUE)) {
    stop("Package \"fs\" needed for this function to work. Please install it.",
      call. = FALSE)
  }
  proj_root <- rprojroot::find_root(rprojroot::is_rstudio_project)
  if(missing(path)){
    path <- file.path(proj_root, "config")
  }
  
    
  yaml_where <- file.path(
    path, paste0(name, ".yaml")
  )
  
  
  # label: Safety Explorer
  # type: htmlwidget
  # domain: multiple
  # package: safetyCharts  
  # workflow:
  #   init: aeExplorer_init
  # widget: aeExplorer
  # 
  conf <- list()
  
  conf$label <- label
  conf$type <- type
  conf$domain <- domain
  conf$package <- package
  conf$workflow <- workflow
  
  
  
  if (tolower(type) == "module") {
    conf$workflow <- list(
      ui <- paste0(name, "_ui"),
      server <- paste0(name, "_server")
    )
  } else if (tolower(type) == "htmlwidget") {
    #TODO add htmlwidget
  } else if (tolower(type) == "plot") {
    conf$workflow$main <- name
  } 
  
  if (!fs::file_exists(yaml_where)){
    write_yaml(conf, yaml_where)
  }   
  
  
  r_where <- file.path(
    path,
    "workflow", 
    paste0(name, ".R")
  )
  
  if (!fs::file_exists(r_where)){
    fs::file_create(r_where)
    chart_template(name = name, path = r_where, type=type, ...)
  } 
}


#' Chart Template Function
#' @inheritParams add_chart
#' @param path The path to the R script where the module will be written. 
#' Note that this path will not be set by the user but internally by 
#' `add_chart()`. 
#' @param ... Arguments to be passed to the template, via `add_chart()`
#'
#' @return Used for side effect
#' @export
#' @seealso [add_chart()]
chart_template <- function(name, path, type, ...){
  
  write_there <- function(...){
    write(..., file = path, append = TRUE)
  }
  
  
  if (type=="plot"){
    
    # template_r <- system.file("config/workflow", "safety_histogram_chart.R", package = "safetyCharts")
    # file.copy(from = template_r, to = path, overwrite = T)
    
    write_there(sprintf("%s <- function(data, settings){", name))
    
    func_body <- 
      '  ## Replace with your custom code ##
         params <- aes_(
           x=as.name(settings$studyday_col), 
           y=as.name(settings$value_col), 
           group=as.name(settings$id_col)
         )
       
       
         if(hasName(settings, "measure_values")){
           sub <- data %>% filter(!!sym(settings$measure_col) %in% settings$measure_values)
         } else {
           sub <- data
         }
         
         p <- ggplot(data=sub, params) +
           geom_path(color = "black", alpha=0.15) +
           labs(x="Study Day", y="Lab Value", title="Lab Overview", subtitle="")+
           facet_grid(
             rows=as.name(settings$measure_col),
             scales="free_y"
           ) +
           theme_bw()
       
         return(p)
      
      '
    write_there(func_body)
    write_there("}")
    
  } else if (type=="module"){
    
    # write UI
    write_there(sprintf("%s_ui <- function(id){", name))
    write_there("  ns <- NS(id)")
    write_there("  tagList(")
    
    ph_ui <- '
    sidebar<-sidebarPanel(
        selectizeInput(
            ns("measures"), 
            "Select Measures", 
            multiple=TRUE, 
            choices=c("")
        )
    )
    main<-mainPanel(plotOutput(ns("customModOutput")))
    ui<-fluidPage(
        sidebarLayout(
            sidebar,
            main,
            position = c("right"),
            fluid=TRUE
        )
    )
    return(ui)
    '
    write_there(ph_ui)
    write_there("  )")
    write_there("}")
    write_there("    ")
    
    # write server use pre shiny v1.5 module convention
    write_there(sprintf("#' %s Server Function", name))
    write_there("#'")
    write_there(sprintf("%s_server <- function(input, output, session, params){", name))
    write_there("  ns <- session$ns")
    ph_server <- '
    ## replace with your custom code ##
    # Populate control with measures and select all by default
    observe({
        measure_col <- params()$settings$measure_col
        measures <- unique(params()$data[[measure_col]])
        updateSelectizeInput(
            session, 
            "measures",
            choices = measures,
            selected = measures
        )
    })

    # cusomize selected measures based on input
    settingsR <- reactive({
        settings <- params()$settings
        settings$measure_values <- input$measures
        return(settings)
    })


    #draw the chart
    output$customModOutput <- renderPlot({
       
       data <- params()$data
       settings <- settingsR()
       
        params <- aes_(
          x=as.name(settings$studyday_col), 
          y=as.name(settings$value_col), 
          group=as.name(settings$id_col)
        )


      if(hasName(settings, "measure_values")){
         sub <- data %>% filter(!!sym(settings$measure_col) %in% settings$measure_values)
      } else {
         sub <- data
      }
  
      p <- ggplot(data=sub, params) +
        geom_path(color = "black", alpha=0.15) +
        labs(x="Study Day", y="Lab Value", title="Lab Overview", subtitle="")+
        facet_grid(
          rows=as.name(settings$measure_col),
          scales="free_y"
        ) +
      theme_bw()

      return(p)
       
    })
    '
    write_there(ph_server)
    write_there("}")
    write_there("    ")
    
    
  } else if (type=="htmlwidget"){
    ##TODO add htmlwidget chart template code
  } 
  
}