
demo_module_UI <- function(id) {
  ns <- NS(id) 
  tagList(
     textInput(ns("text_in"),  label="Type something here"),
     textOutput(ns("text_out"))
  )
}

demo_module <- function(input, output, session) {
  
  output$text_out <- renderText({paste(input$text_in)})
  
}
 