library(shiny)
library(safetyGraphics)
library(shinyjs)
# reactlogReset()
devtools::load_all()
ui <- tagList(
  useShinyjs(),
  fluidPage(
    h1("Example 1: Load one data set - calls mod_loadData directly"),
    loadDataUI("ex1", domain = "labs"),
    tableOutput("ex1Out"),
    h1("Example 2: Load 3 static domains - calls mod_loadDomains"),
    loadDomainsUI("ex2"),
    textOutput("ex2Out"),
    tableOutput("ex2Out_labs"),
    tableOutput("ex2Out_aes"),
    tableOutput("ex2Out_dm"),
    h1("Example 3: reactive domains - calls mod_loadDomains"),
    checkboxGroupInput(
      "domainList",
      "Choose Domains:",
      choices = c("a", "b", "c", "d", "e", "f"),
      selected = c("a", "b", "c")
    ),
    loadDomainsUI("ex3"),
    textOutput("ex3Out")
  )
)

server <- function(input, output, session) {
  ex1_data <- callModule(loadData, "ex1", domain = "labs")
  output$ex1Out <- renderTable(ex1_data$data())
  ex2_data <- callModule(loadDomains, "ex2", domains = reactive({
    c("labs", "aes", "dm")
  }))
  output$ex2Out <- renderText(names(ex2_data()))
  output$ex2Out_labs <- renderTable(ex2_data()$labs())
  output$ex2Out_aes <- renderTable(ex2_data()$aes())
  output$ex2Out_dm <- renderTable(ex2_data()$dm())
  ex3_data <- callModule(loadDomains, "ex3", domains = reactive({
    input$domainList
  }))
  output$ex3Out <- renderText({
    ex3_data() %>% map_chr(~ paste(dim(.x()), collapse = "x"))
  })
}

# options(shiny.reactlog = TRUE)
devtools::load_all()
shinyApp(ui, server)
