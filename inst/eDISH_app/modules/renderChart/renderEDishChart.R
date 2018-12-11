renderEDishChart <- function(input, output, session, data, settings, valid){
  
  ns <- session$ns
  
  
  output$chart <- renderEDISH({
    req(data())
    req(settings())
    
    if (valid()==TRUE){
      eDISH(data = data(), settings = settings())
    } else{
      return()
    }
  })  
}