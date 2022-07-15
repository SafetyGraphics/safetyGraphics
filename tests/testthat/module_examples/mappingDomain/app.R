library(shiny)
library(safetyGraphics)
library(dplyr)

meta <- rbind(
  safetyCharts::meta_labs,
  safetyCharts::meta_aes,
  safetyCharts::meta_dm,
  safetyCharts::meta_hepExplorer
)
# reactlogReset()
measure_meta <- meta %>%
  filter(domain == "labs") %>%
  filter(col_key == "measure_col")
mm_default <- data.frame(
  text_key = c("measure_col", "measure_col--ALP"),
  current = c("PARAM", "Alkaline Phosphatase (U/L)"),
  stringsAsFactors = FALSE
)
labs_default <- meta %>%
  filter(domain == "labs") %>%
  mutate(current = standard_sdtm) %>%
  select(text_key, current)

aes_default <- meta %>%
  filter(domain == "aes") %>%
  mutate(current = standard_sdtm) %>%
  select(text_key, current)

ui <- tagList(
  tags$head(
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "index.css"
    )
  ),
  fluidPage(
    h2("Example 1: Labs Domain - measure only - no defaults"),
    mappingDomainUI("ex1", measure_meta, safetyData::adam_adlbc),
    tableOutput("ex1Out"),
    h2("Example 2: Labs Domain - measure only - with defaults"),
    mappingDomainUI("ex2", measure_meta, safetyData::adam_adlbc, mm_default),
    tableOutput("ex2Out"),
    h2("Example 3: AE Domain - no defaults"),
    mappingDomainUI("ex3", meta %>% filter(domain == "aes"), safetyData::adam_adae),
    tableOutput("ex3Out"),
    h2("Example 4: AE Domain - with defaults"),
    mappingDomainUI("ex4", meta %>% filter(domain == "aes"), safetyData::adam_adae, aes_default),
    tableOutput("ex4Out"),
    h2("Example 5: Labs Domain - no defaults"),
    mappingDomainUI("ex5", meta %>% filter(domain == "labs"), safetyData::adam_adlbc),
    tableOutput("ex5Out"),
    h2("Example 6: Labs Domain - with defaults"),
    mappingDomainUI("ex6", meta %>% filter(domain == "labs"), safetyData::adam_adlbc, labs_default),
    tableOutput("ex6Out"),
  )
)
server <- function(input, output, session) {
  ex1 <- callModule(mappingDomain, "ex1", measure_meta, safetyData::adam_adlbc)
  exportTestValues(ex1_data = {
    ex1()
  })
  output$ex1Out <- renderTable(ex1())

  ex2 <- callModule(mappingDomain, "ex2", measure_meta, safetyData::adam_adlbc)
  exportTestValues(ex2_data = {
    ex2()
  })
  output$ex2Out <- renderTable(ex2())

  ex3 <- callModule(mappingDomain, "ex3", meta %>% filter(domain == "aes"), safetyData::adam_adae)
  exportTestValues(ex3_data = {
    ex3()
  })
  output$ex3Out <- renderTable(ex3())

  ex4 <- callModule(mappingDomain, "ex4", meta %>% filter(domain == "aes"), safetyData::adam_adae)
  exportTestValues(ex4_data = {
    ex4()
  })
  output$ex4Out <- renderTable(ex4())

  ex5 <- callModule(mappingDomain, "ex5", meta %>% filter(domain == "labs"), safetyData::adam_adlbc)
  exportTestValues(ex5_data = {
    ex5()
  })
  output$ex5Out <- renderTable(ex5())

  ex6 <- callModule(mappingDomain, "ex6", meta %>% filter(domain == "labs"), labsafetyData::adam_adlbcs)
  exportTestValues(ex6_data = {
    ex6()
  })

  output$ex6Out <- renderTable(ex6())
}

# options(shiny.reactlog = TRUE)
shinyApp(ui, server)
