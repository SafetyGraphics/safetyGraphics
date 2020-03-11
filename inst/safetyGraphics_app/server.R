# Server code for safetyGraphics App
#   - calls dataUpload module (data tab)
#   - calls renderSettings module (settings tab)
#   - calls chart modules (chart tab)
#   - uses render UI to append a red X or green check on tab title,
#      indicating whether user has satisfied requirements of that tab

function(input, output, session){

  
  configVals <- reactiveValues()
  
  for (d in unique(settingsMetadata$domain)){
    configVals[[d]] <- callModule(config, d, domain = d, metadata=metadata_list, preload_data_list = preload_data_list)
  }

  charts <- reactive({
    out <- vector()
    for (i in names(configVals)){
      charts <- configVals[[i]]$charts()
      out <- c(out, charts)
    }
    return(out)    
  })
  
  #toggle css class of chart tabs
  observeEvent(charts(),{
    for (chart in names(charts())){
      valid <- charts()[[chart]]

      ## code to toggle css for chart-specific tab here
      toggleClass(selector= paste0("#nav_id li.dropdown ul.dropdown-menu li a[data-value='", chart, "']"), class="valid", condition=valid==TRUE)
      toggleClass(selector= paste0("#nav_id li.dropdown ul.dropdown-menu li a[data-value='", chart, "']"), class="invalid", condition=valid==FALSE)
    }
  })


  # hide charts tab if no chart selected
  observeEvent(charts(),{
    if (is.null(charts())){
      hideTab(inputId = "nav_id", target = "Charts")
      hideTab(inputId = "nav_id", target = "Reports")
    }
  },
  ignoreNULL = FALSE,
  ignoreInit = TRUE)  # so there's no hiding when the app first loads

  
  ##############################################################
  # Initialize Charts Modules
  ##############################################################

  # set up all chart tabs from the start
    for (chartnum in 1:nrow(chartsMetadata)){
      md <- chartsMetadata[chartnum,]
      chart<-md$chart
      chartLabel<-md$label

      appendTab(
        session = session,
        inputId ="nav_id",
        tab = tabPanel(
          title = chartLabel,
          value = chart,
          renderChartUI(paste0("chart", chart))
        ),
        menuName = "Charts"
      )
    }

    # hide/show chart tabs in response to user selections
    observe({

      # show charts and reports tabs if any charts are selected
      showTab(inputId = "nav_id", target = "Charts")
      showTab(inputId = "nav_id", target = "Reports")

      selected_charts <- names(charts())
      unselected_charts <- all_charts[!all_charts %in% selected_charts]
      for(chart in unselected_charts){
        hideTab(inputId = "nav_id",
                target = chart)
      }
      for(chart in selected_charts){
        showTab(inputId = "nav_id",
                target = chart)
      }
    })

  for(chart in all_charts){
    chartType <- chartsMetadata %>% filter(chart==!!chart) %>% pull(type)
    width <- chartsMetadata %>% filter(chart==!!chart) %>% pull(maxWidth)
    domain <- chartsMetadata %>% filter(chart==!!chart) %>% pull(domain)
    callModule(
      module = renderChart,
      id = paste0("chart", chart),
      data = reactive(configVals[[domain]]$data()),
      settings = reactive(configVals[[domain]]$settings()),
      valid = reactive(charts()[[chart]]),
      chart = chart,
      type = chartType,
      width = width
     # type = "htmlwidget"
    )

  }
    

    
    
      callModule(
        module = renderReports,
        id = "reportsUI",
        config = configVals,
        chartsMetadata = reactive(chartsMetadata[chartsMetadata$chart %in% names(charts()),c("chart","label","domain")])
      )
  
      
  output$about <- renderUI({
    HTML('<h1> <b> Welcome to the Safety Graphics Shiny App  </b> </h1>
         <p> The Safety Graphics Shiny app is an interactive tool for evaluating clinical trial safety using
         a flexible data pipeline. This application and corresponding
    <a href="https://cran.r-project.org/web/packages/safetyGraphics/index.html">safetyGraphics</a>
         R package have been developed as part of the <a href="https://safetygraphics.github.io/">Interactive Safety Graphics (ISG) workstream</a>
        of the ASA Biopharm-DIA Safety Working Group. </p>
         <h3><i> Using the app</i></h3>
        <p>Detailed instructions about using the app can be found in our
        <a href="https://cran.r-project.org/web/packages/safetyGraphics/vignettes/shinyUserGuide.html">vignette</a>. In short,
        the user will begin by loading a data file, adjust settings as needed and view the interactive charts.
        Finally, the user may export a self-contained, fully reproducible snapshot of the charts that can be easily shared with others.</p>
        <h3><i> Clinical Workflow </i></h3>
        This shiny app has been developed in parallel with a well-documented <a href="https://github.com/SafetyGraphics/SafetyGraphics.github.io/raw/master/guide/HepExplorerWorkflow_v1_1.pdf">clinical workflow</a>
 for monitoring hepatotoxicity. The workflow, written by expert physicians, provides a detailed description of how the interactive graphics can be used as part of a safety clinician’s monitoring practice.
        <h3><i> Interactive Charts </i></h3>
        <p> The included interactive charts are built using the <code>htmlwidgets</code> framework in R. The code libraries
        and configuration details for the underlying JavaScript charts are located below.
        <ul>
        <li>Hepatic Safety Explorer -
<a href="https://github.com/SafetyGraphics/hep-explorer">Library</a>,
<a href="https://github.com/SafetyGraphics/hep-explorer/wiki/Configuration">Configuration</a>
        </li>
        <li>Histogram -
<a href="https://github.com/RhoInc/safety-histogram">Library</a>,
<a href="https://github.com/RhoInc/safety-histogram/wiki/Configuration">Configuration</a></li>
        <li>Outlier Explorer -
<a href="https://github.com/RhoInc/safety-outlier-explorer">Library</a>,
<a href="https://github.com/RhoInc/safety-outlier-explorer/wiki/Configuration">Configuration</a></li>
        <li>Shift Plot -
<a href="https://github.com/RhoInc/safety-shift-plot">Library</a>,
<a href="https://github.com/RhoInc/safety-shift-plot/wiki/Configuration">Configuration</a></li>
        <li>Results Over Time -
<a href="https://github.com/RhoInc/safety-results-over-time">Library</a>,
<a href="https://github.com/RhoInc/safety-results-over-time/wiki/Configuration">Configuration</a></li>
        <li>Paneled Outlier Explorer -
<a href="https://github.com/RhoInc/paneled-outlier-explorer">Library</a>,
<a href="https://github.com/RhoInc/paneled-outlier-explorer/wiki/Configuration">Configuration</a></li></ul>
        </p>
<br>
         <p>For more information about <code>safetyGraphics</code>, please visit our
<a href="https://github.com/SafetyGraphics/safetyGraphics">GitHub repository</a>.  We also welcome your suggestions in our
<a href="https://github.com/SafetyGraphics/safetyGraphics/issues">issue tracker</a>.
         </p>')

  })

  output$hex <- renderImage({
    list(src = system.file("safetyGraphicsHex/safetyGraphicsHex.png", package = "safetyGraphics"), width="60%")
  }, deleteFile = FALSE)

  session$onSessionEnded(stopApp)
}
