# Server code for safetyGraphics App
#   - calls dataUpload module (data tab)
#   - calls renderSettings module (settings tab)
#   - calls chart modules (chart tab)
#   - uses render UI to append a red X or green check on tab title, 
#      indicating whether user has satisfied requirements of that tab

function(input, output, session){


  # run dataUpload module
  #
  #  returns selected dataset, settings, and validation status
  dataUpload_out <- callModule(dataUpload, "datatab")

  # add status to data panel nav bar
  #   always OK for now, since example data is loaded by default
  output$data_tab_title = renderUI({
   # HTML(paste("Data", icon("check", class="ok")))
    span(tagList("Data", icon("check", class="ok")))
  })
  
  # based on selected data set & generated/selected settings obj, generate settings page.
  #
  #  NOTE:  module is being triggered when selected dataset changes OR when settings list changes
  #   this could cause the module to trigger twice unecessarily in some cases because the settings are generated
  #   AFTER the data is changed.
  #
  # reutrns updated settings and validation status
    settings_new <-   callModule(renderSettings, "settingsUI",
                                 data = reactive(dataUpload_out$data_selected()),
                                 settings = reactive(dataUpload_out$settings()),
                                 status = reactive(dataUpload_out$status()))


  # update settings navbar
    output$settings_tab_title = renderUI({
      num_valid <- settings_new$status() %>% flatten() %>%  keep(., names(.)=="valid") %>% unlist() %>% sum()
      if(num_valid >0) {
        HTML(paste("Settings", icon("check", class="ok")))
      } else {
        HTML(paste("Settings", icon("times", class="notok")))
      }
    })


   # ## this currently wipes away everything anytime there's a change in chart selections OR
    #  change in validation status
   observe({

     charts <- settings_new$charts()

      # remove whole navMenu and all existing chart tabs
      removeTab(inputId="tabs", target="Charts")
     appendTab(inputId = "tabs", navbarMenu("Charts"))

      # for each chart, append a new tab to the menu and place the module UI output
      lapply(charts, function(chart){

        status <- settings_new$status()[[chart]]$valid
          if(status==TRUE){
             tab_title <- HTML(paste(chart, icon("check", class="ok")))
          } else {
             tab_title <- HTML(paste(chart, icon("times", class="notok")))
          }

        tabfun <- match.fun(paste0("render_", chart, "_chartUI"))  # module UI for given tab
       #tabid <- paste0(chart, "_tab_title")
        tabcode <- tabPanel(title = tab_title, 
                           # title = htmlOutput(tabid),
                             tabfun(paste0("chart", chart)))

        appendTab(inputId = "tabs",
                  tabcode,
                  menuName = "Charts")
      })
     })


   # call all chart modules
  for (chart in allcharts){
    
    modfun <- match.fun(paste0("render_", chart, "_chart"))
    
    # I'm thinking this code set up (loop + callModule() using reactives) isn't ideal and 
    # the value for "valid" doesn't always get passed directly.
    # Moving to renderChart module will hopefully help here
    callModule(module = modfun, 
               id = paste0("chart", chart),
               data = reactive(dataUpload_out$data_selected()),
               settings = reactive(settings_new$settings()),
               valid = reactive(settings_new$status()[[chart]]$valid)) ## why is this always sending SH
  }

  
  session$onSessionEnded(stopApp)

}
