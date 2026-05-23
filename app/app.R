library(shiny)
library(bslib)

ui <- page_fluid(
  # ----- Sidebar -----
  page_sidebar(
    sidebar = sidebar(
      # ----- Filters -----
      strong("Filters"),
      input_switch(
        "merged_filter", 
        "Merge Adjacent",
      ),
      selectizeInput(
        "location_filter",
        "Location",
        list("Recorder 1" = "1", "Recorder 2" = "2", "Recorder 3" = "3"),
        multiple = TRUE,
      ),
      selectizeInput(
        "species_filter",
        "Species",
        list("Species 1" = "1", "Species 2" = "2", "Species 3" = "3"),
        multiple = TRUE,
      ),
      dateRangeInput(
        inputId = "date_filter", 
        label = "Date Range"
      ),
      sliderInput(
        "confidence_filter", 
        "Confidence Threshold",
        min = 0,
        max = 1,
        value = 0,
      ),
      
      
      hr(), # section break
    )
  ),
  
  # ----- Main Page -----
  
)

server <- function(input, output, session){}

shinyApp(ui = ui, server = server)