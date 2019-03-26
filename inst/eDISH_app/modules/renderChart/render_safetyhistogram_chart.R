render_safetyhistogram_chart <- function(input, output, session, data, settings, valid){
  
  ns <- session$ns
  
  
  # render eDISH chart if settings pass validation
  output$chart <- renderSafetyHistogram({
    req(data())
    req(settings())
    
  #  if (valid()==TRUE){
      trimmed_data <- safetyGraphics:::trimData(data = data(), settings = settings())
      safetyHistogram(data = data(), settings = settings())
    # } else{
    #   return()
    # }
  }) 
  
}