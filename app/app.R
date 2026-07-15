library(shiny)
library(bslib)
library(leaflet)
library(tidyverse)
library(plotly)
library(lubridate)

# Load and process data with datetime parsing
acoustic_data <- read.csv("../data/out.csv") |>
  mutate(
    datetime = as.POSIXct(timestamp, format = "%Y-%m-%dT%H:%M:%S"),
    date = as.Date(datetime),
    hour = hour(datetime),
    month = month(datetime)
  )

min_date <- min(acoustic_data$date, na.rm = TRUE)
max_date <- max(acoustic_data$date, na.rm = TRUE)

ui <- page_sidebar(
  # ----- Styling -----
  theme = bs_theme(
    bootstrap = 5, 
    bootswatch = "yeti"
  ),
  title = "Bird Acoustic Monitoring Dashboard",
  
  tags$style("
    #species_filter + .selectize-control .selectize-input {
      max-height: 76px;
      overflow-y: auto;
    }
  "),
  
  # ----- Sidebar -----
  sidebar = sidebar(
    # ----- Filters -----
    strong("Filters"),
    
    card(
      card_body(
        selectizeInput(
          "location_filter",
          "Recorder",
          choices = unique(acoustic_data$recorder_id),
          selected = unique(acoustic_data$recorder_id),
          multiple = TRUE,
          options = list(
            placeholder = "Select recorder(s)...",
            plugins = list("remove_button")
          )
        ),
        input_switch("recorder_all", "All", TRUE)
      )
    ),
    
    card(
      card_body(
        selectizeInput(
          "species_filter",
          "Species",
          choices = unique(acoustic_data$name),
          selected = unique(acoustic_data$name),
          multiple = TRUE,
          options  = list(
            placeholder = "Select species...",
            plugins = list("remove_button")
          )
        ),
        input_switch("species_all", "All", TRUE),
      )
    ),
    
    dateRangeInput(
      inputId = "date_filter",
      label = "Date Range",
      start = min_date,
      end = max_date
    ),
    
    card(
      card_body(
        sliderInput(
          "hour_filter",
          "Time of Day (Hours)",
          min = 0,
          max = 23,
          value = c(0, 23),
          step = 1,
          ticks = TRUE
        ),
        tags$small("Select 24-hour range (0 = midnight, 12 = noon, 23 = 11 PM)")
      )
    ),
    
    sliderInput(
      "confidence_filter",
      "Confidence Threshold",
      min = 0,
      max = 1,
      value = min(acoustic_data$score),
    ),
    
    input_switch(
      "rare_filter",
      "Rare Species",
    ),
  ),
  
  # ----- Tabs -----
  navset_tab(
    
    # ----- About Tab -----
    nav_panel(
      "About",
      card(
        max_width = 700,
        card_body(
          h5("About this Dashboard"),
          p("Birds serve as great bioindicators since they occupy a wide range 
          of habitats and their populations respond quickly to environmental 
          change (Kułaga, 2019). It is therefore advantageous to monitor bird 
          populations since they allow for the quick detection of environmental 
          stresses over the entire ecosystem. Detecting these changes is 
          imperitive to measure the impacts of our own development on ecosystems 
          as well as evaluate any measures being taken to remedy our harms."),
          
          p("This project aims to leverage the use of acoustic data in the 
          monitoring of bird populations, particularly through the use of 
          HawkEars, a machine learning-based approach for acoustic 
          classification of avian species (Huus, 2025). Affiliated with the 
          University of British Columbia, the data for this project comes from 
          acoustic recorders placed in the greater Vancouver area. The ultimate 
          goal of this project is to contribute to sustainable development and 
          ecosystem preservation by making collected data more accessible."),
          h5("Tabs"),
          tags$ul(
            tags$li(strong("About:"), 
                    " You are here."),
            tags$li(strong("Dashboard:"), 
                    " Displays an interactive map, summary statistics, and 
                    charts."),
          ),
          h5("Filters"),
          p("The filters for this dashboard can be found in the sidebar and 
            allow the user to select data based on the following criteria:"),
          tags$ul(
            tags$li(strong("Recorder:"), 
                    " Filter for any combination of acoustic recording units. 
                    This allows the user to filter by location."),
            tags$li(strong("Species:"), 
                    " Limit results to selected species."),
            tags$li(strong("Date Range:"), 
                    " Restrict displayed information to a specific time 
                    period."),
            tags$li(strong("Time of Day (Hours):"), 
                    " Filter detections by hour of the day to examine diurnal 
                    patterns in bird activity."),
            tags$li(strong("Confidence Threshold:"), 
                    " Show only detections above a minimum confidence score."),
            tags$li(strong("Rare Species:"), 
                    " Toggle on to show only the rare species identified by the 
                    HawkEars model."),
          ),
          h5("Displayed Information"),
          p("The information displayed on the dashboard will react to the 
            filtering criteria that the user specified via the filters 
            described above."),
          tags$ul(
            tags$li(strong("Total Detections:"), 
                    " Total number of detections, displayed as a summary 
                    statistic."),
            tags$li(strong("Unique Species:"), 
                    " Total number of unique species detected, displayed as a 
                    summary statistic."),
            tags$li(strong("Recorder Locations:"), 
                    " Locations of acoustic recorders, displayed on an 
                    interactive map. The size and opacity intensity of the 
                    recorder markers correspond to their species richness and 
                    detection activity respectively."),
            tags$li(strong("Species Counts:"), 
                    " A bar chart that displays the top 20 species. You can also 
                    see direct counts by hovering over each bar."),
            tags$li(strong("Recorder Activity Over Time:"), 
                    " A heatmap allowing users to compare each recording units
                    detections over time. The unit of time can be cahnged between
                    Hour, Date, Month, and Year depedning on the patterns the user
                    wishes to examine."),
            tags$li(strong("Detections Over Time:"), 
                    " A line chart showing the detections over time. The time 
                    unit can be changed between Hour, Date, Month, and Year 
                    depending on the activity patterns the user wishes to examine."),
            tags$li(strong("Confidence Distribution:"), 
                    " A histogram displaying the distribution of confidence 
                    scores. This provides a quick reference for users aiming to 
                    select a confidence threshold for data they are interested 
                    in."),
          ),
          h5("References"),
          tags$ul(
            tags$li("Huus, J., Kelly, K. G., Bayne, E. M., & Knight, E. C. 
                    (2025). HawkEars: A regional, high-performance avian 
                    acoustic classifier. Ecological Informatics, 87, 103122."),
            tags$li("Kułaga, K., & Budka, M. (2019). Bird species detection by 
                    an observer and an autonomous sound recorder in two 
                    different environments: Forest and farmland. PLoS One, 
                    14(2), e0211970."),
          )
        )
      )
    ),
    
    # ----- Dashboard Tab -----
    nav_panel(
      "Dashboard",
      
      layout_column_wrap(
        colwidths = c(8, 4),
        
        layout_columns(
          col_widths = 12,
          
          layout_columns(
            col_widths = c(6, 6),
            card(
              card_body(
                tags$div(
                  style = "display: flex; flex-direction: column; align-items: 
                          center; justify-content: center; gap: 4px;",
                  tags$span(
                    style = "font-size: 0.9rem; letter-spacing: 0.05rem; 
                    color: #444444",
                    "Total Detections"
                  ),
                  tags$div(
                    style = "display: flex; align-items: center; justify-content: 
                            center; gap: 8px; font-size: 1.6rem; color: #444444",
                    icon("binoculars"),
                    textOutput("total_obs")
                  )
                )
              )
            ),
            card(
              card_body(
                tags$div(
                  style = "display: flex; flex-direction: column; align-items: 
                          center; justify-content: center; gap: 4px;",
                  tags$span(
                    style = "font-size: 0.9rem; letter-spacing: 0.05rem; 
                    color: #444444",
                    "Unique Species"
                  ),
                  tags$div(
                    style = "display: flex; align-items: center; justify-content: 
                            center; gap: 8px; font-size: 1.6rem; color: #444444",
                    icon("dove"),
                    textOutput("unique_species")
                  )
                )
              )
            )
          ),
          
          card(
            leafletOutput("map")
          )
        ),
        
        card(
          plotlyOutput("species_bar")
        )
      ),
      
      layout_columns(
        col_widths = c(4, 4, 4),
        card(
          card_header(
            div(
              p("Recorder Activity Over Time"),
              style = "display: flex; justify-content: space-between; align-items: center;",
              selectInput(
                "heatmap_timeunit",
                "Time Unit:",
                choices = c("Hour" = "hour", "Date" = "date", "Month" = "month", "Year" = "year"),
                selected = "date",
                width = "150px"
              )
            )
          ),
          plotlyOutput("activity_heatmap")
        ),
        card(
          card_header(
            div(
              p("Detections Over Time"),
              style = "display: flex; justify-content: flex-end; gap: 1rem;",
              selectInput(
                "detections_timeunit",
                "Time Unit:",
                choices = c("Hour" = "hour", "Date" = "date", "Month" = "month", "Year" = "year"),
                selected = "date",
                width = "150px"
              )
            )
          ),
          plotlyOutput("detections_curve")
        ),
        card(
          plotlyOutput("confidence_hist")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  filtered_data <- reactive({
    acoustic_data |>
      filter(
        # Date range filter
        date >= input$date_filter[1],
        date <= input$date_filter[2],
        # Time of day filter
        hour >= input$hour_filter[1],
        hour <= input$hour_filter[2],
        # Confidence filter
        score > input$confidence_filter,
        # Species filter
        name %in% input$species_filter,
        # Location filter
        recorder_id %in% input$location_filter,
        # Rare species filter
        if (input$rare_filter) rare == "True" else TRUE
      )
  })
  
  count_data <- reactive({
    filtered_data() |>
      count(name, sort = TRUE) |>
      slice_head(n = 20)
  })
  
  location_summary <- reactive({
    data <- filtered_data()
    
    if (nrow(data) == 0) {
      return(data.frame(
        latitude = numeric(),
        longitude = numeric(),
        n_detections = numeric(),
        n_species = numeric(),
        species_list = character(),
        radius = numeric(),
        recorder_id = character(),
        popup_html = character()
      ))
    }
    
    summary_data <- data |>
      group_by(latitude, longitude) |>
      summarise(
        recorder_id = first(recorder_id),
        n_detections = n(),
        n_species = n_distinct(name),
        species_list = paste(unique(name), collapse = ", "),
        .groups = "drop"
      )
    
    if (nrow(summary_data) > 0) {
      max_sp <- max(summary_data$n_species, na.rm = TRUE)
      summary_data <- summary_data |>
        mutate(
          radius = 8 + (n_species / max_sp) * 5,
          fill_opacity = 0.3 + (n_detections / max(n_detections)) * 0.6
        )
      
      summary_data <- summary_data |>
        rowwise() |>
        mutate(
          popup_html = {
            top_species <- data |>
              filter(latitude == .data$latitude, longitude == .data$longitude) |>
              count(name, sort = TRUE) |>
              slice_head(n = 5)
            
            rare_species <- data |>
              filter(latitude == .data$latitude, longitude == .data$longitude, rare == "True") |>
              count(name, sort = TRUE) |> 
              slice_head(n = 5)
            
            top_species_rows <- paste0(
              seq_along(top_species$name), ". ", 
              top_species$name, " (", 
              top_species$n, ")",
              collapse = "<br>"
            )
            
            # Format rare species list
            rare_species_rows <- if (nrow(rare_species) > 0) {
              paste0(
                seq_along(rare_species$name), ". ", 
                rare_species$name, " (", 
                rare_species$n, ")",
                collapse = "<br>"
              )
            } else {
              "<em>None detected</em>"
            }
            
            paste0(
              "<div style='font-size: 13px; width: 240px;'>",
              "<b>Recorder: ", .data$recorder_id, "</b><br><br>",
              "<b>Top 5 Species:</b><br>",
              "<div style='margin-left: 10px; margin-top: 5px;'>",
              top_species_rows,
              "</div>",
              "<br>",
              "<b style='color: #d9534f;'>Rare Species:</b><br>",
              "<div style='margin-left: 10px; margin-top: 5px;'>",
              rare_species_rows,
              "</div>",
              "</div>"
            )
          }
        ) |>
        ungroup()
    }
    
    summary_data
  })
  
  heatmap_data <- reactive({
    data <- filtered_data()
    
    if (nrow(data) == 0) {
      return(NULL)
    }
    
    time_unit <- input$heatmap_timeunit
    
    if (time_unit == "hour") {
      data <- data |>
        mutate(time_period = paste(date, sprintf("%02d:00", hour)))
    } else if (time_unit == "date") {
      data <- data |>
        mutate(time_period = as.character(date))
    } else if (time_unit == "month") {
      data <- data |>
        mutate(time_period = paste(year(datetime), sprintf("%02d", month), sep = "-"))
    } else {
      data <- data |> 
        mutate(time_period = paste(year(datetime)))
    }
    
    heatmap_data <- data |>
      group_by(recorder_id, time_period) |>
      summarise(
        detections = n(),
        .groups = "drop"
      ) |>
      arrange(time_period)
    
    heatmap_data
  })
  
  detections_over_time <- reactive({
    data <- filtered_data()
    
    if (nrow(data) == 0) {
      return(NULL)
    }
    
    time_unit <- input$detections_timeunit
    
    if (time_unit == "hour") {
      data <- data |>
        mutate(time_period = paste(date, sprintf("%02d:00", hour)))
    } else if (time_unit == "date") {
      data <- data |>
        mutate(time_period = as.character(date))
    } else if (time_unit == "month") {
      data <- data |>
        mutate(time_period = paste(year(datetime), sprintf("%02d", month), sep = "-"))
    } else {
      data <- data |> 
        mutate(time_period = paste(year(datetime)))
    }
    
    summary_data <- data |>
      group_by(time_period) |>
      summarise(
        detections = n(),
        .groups = "drop"
      ) |>
      arrange(time_period)
    
    summary_data
  })
  
  observeEvent(input$species_all, {
    updateSelectizeInput(
      session,
      "species_filter",
      selected = if (input$species_all) {
        unique(acoustic_data$name)
      } else {
        character(0)
      }
    )
  })
  
  observeEvent(input$recorder_all, {
    updateSelectizeInput(
      session,
      "location_filter",
      selected = if (input$recorder_all) {
        unique(acoustic_data$recorder_id)
      } else {
        character(0)
      }
    )
  })
  
  # ----- Render Value boxes -----
  output$total_obs <- renderText({
    filtered_data() |> 
      nrow()
  })
  
  output$unique_species <- renderText({
    filtered_data() |>
      distinct(name) |>
      nrow()
  })
  
  # ----- Render Map -----
  output$map <- renderLeaflet({
    data <- location_summary()
    
    m <- leaflet() |>
      addProviderTiles(providers$CartoDB.VoyagerLabelsUnder) |>
      setView(lat = 49.2827, lng = -123.1207, zoom = 10)
    
    # Only add markers if there's data
    if (nrow(data) > 0) {
      m <- m |>
        addCircleMarkers(
          data = data,
          lng = ~longitude,
          lat = ~latitude,
          radius = ~radius,
          color = "#107838",
          weight = 2,
          opacity = ~fill_opacity,
          fillColor = "#107838",
          fillOpacity = 0.6,
          label = ~htmltools::HTML(paste0("Recorder: ", recorder_id, "<br>Species: ", n_species, " | Detections: ", n_detections)),
          popup = ~htmltools::HTML(popup_html)
        )
    }
    
    m
  })
  
  # ----- Render Species Count Bar Chart -----
  output$species_bar <- renderPlotly({
    plot_ly(
      data = count_data(),
      x = ~n,
      y = ~reorder(name, n),
      type = "bar",
      orientation = "h",
      marker = list(color = "#107838")
    ) |> 
      layout(
        title = "Species Counts (Top 20)",
        xaxis = list(title = "Count"),
        yaxis = list(title = "Species"),
        dragmode = FALSE
      ) |> 
      config(displayModeBar = FALSE)
  })
  
  # ----- Render Activity Heatmap -----
  output$activity_heatmap <- renderPlotly({
    data <- heatmap_data()
    
    if (is.null(data) || nrow(data) == 0) {
      plot_ly() |>
        layout(title = "No data available")
    } else {
      # Create matrix for heatmap
      heatmap_matrix <- data |>
        pivot_wider(
          names_from = time_period,
          values_from = detections,
          values_fill = 0
        ) |>
        column_to_rownames("recorder_id") |>
        as.matrix()
      
      plot_ly(
        z = heatmap_matrix,
        x = colnames(heatmap_matrix),
        y = rownames(heatmap_matrix),
        type = "heatmap",
        colorscale = "Viridis",
        colorbar = list(title = "Detections"),
        height = 400
      ) |>
        layout(
          title = NULL,
          xaxis = list(
            title = "Time Period",
            tickfont = list(size = 10),
            tickangle = -45
          ),
          yaxis = list(
            title = "Recorder",
            tickfont = list(size = 10)
          ),
          font = list(family = "Open Sans", color = "#444444"),
          dragmode = FALSE
        ) |>
        config(displayModeBar = FALSE)
    }
  })
  
  # ----- Render Detections Over Time Curve -----
  output$detections_curve <- renderPlotly({
    data <- detections_over_time()
    
    if (is.null(data) || nrow(data) == 0) {
      plot_ly() |>
        layout(title = "No data available")
    } else {
      plot_ly(
        data = data,
        x = ~time_period,
        y = ~detections,
        type = "scatter",
        mode = "lines+markers",
        line = list(color = "#00897B", width = 2),
        marker = list(size = 5, color = "#00897B"),
        height = 400
      ) |>
        layout(
          title = NULL,
          xaxis = list(
            title = "Time Period",
            tickfont = list(size = 10),
            tickangle = -45,
            nticks = 16
          ),
          yaxis = list(
            title = "Detections",
            tickfont = list(size = 10)
          ),
          font = list(family = "Open Sans", color = "#444444"),
          dragmode = FALSE,
          hovermode = "closest"
        ) |>
        config(displayModeBar = FALSE)
    }
  })
  
  # ----- Render Confidence Histogram -----
  output$confidence_hist <- renderPlotly({
    plot_data <- filtered_data()
    
    plot_ly(
      data = plot_data,
      x = ~score,
      type = "histogram",
      nbinsx = 20,
      marker = list(color = "#00897B")
    ) |>
      layout(
        title = list(text = "Confidence Distribution", font = list(size = 16)),
        xaxis = list(
          title = list(text = "Confidence Score", font = list(size = 15)),
          tickfont = list(size = 12),
          range = c(input$confidence_filter, 1)
        ),
        yaxis = list(
          title = list(text = "Number of Observations", font = list(size = 15)),
          tickfont = list(size = 12)
        ),
        font = list(family = "Open Sans", color = "#444444"),
        dragmode = FALSE
      ) |> 
      config(displayModeBar = FALSE)
  })
}

shinyApp(ui = ui, server = server)