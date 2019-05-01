## Shiny Dashboard Expt1
server <- function(input, output) { 
  
  data_crashes <- reactive({ 
    my_range <- seq(from = input$year[1], to = input$year[2], by = 1)
    
    result <- crashes_allDT[year(date) %in% my_range]
    
    result
  })   
  
  summary_data_crashes <- reactive({
    result <- data_crashes()[, .(All = .N, Fatal = sum(accident_severity == "Fatal"), Serious = sum(accident_severity == "Serious"), Slight = sum(accident_severity == "Slight")), by = "police_force"]
    result2 <- left_join(police_data, result , by = "police_force")
    result2
  })
  
  
  summary_data <- reactive({
    if( input$severity != "All"){
      result <- data_crashes()[accident_severity == input$severity]
    } else{
      result <- data_crashes()
    }
    result
  })
  
  
  county_crashes <- reactive({
    result<- data_crashes()[police_force == input$police_boundary ]
    result
  })
  
  crashes_activity_lonlat <- reactive({
    county_casualties <- crashes_allDT[accident_index %in% county_crashes()[, accident_index] ]
    
    if(input$activity == "Walking"){ 
      result1 <- county_casualties[walking > 0]          
      
    } else if(input$activity == "Cyclist"){
      result1 <- county_casualties[cycling > 0]
      #crashes_activity <- crashes_types[cycling > 0]
    } else { result1 <- county_casualties[passenger > 0]}
    
    if(input$severity != "All"){
      result2 <- result1[accident_severity == input$severity]
    } else { result2 <- result1}
    result2
    
  })
  
  mean_location <- reactive({
    result <- crashes_activity_lonlat() %>%
      summarise(meanLat = mean(latitude), meanLong = mean(longitude))
    result
  })
  
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      )  %>% 
      setView(-1.0, 52.0, zoom = 7)
    
    
  })  
  
  myPlot <- reactive({
    var <- input$severity
    p <- ggplot(data = summary_data_crashes()) +
      geom_sf( aes(text = police_force, fill = !!as.symbol(var))) +
      scale_fill_viridis_c() +
      #coord_fixed() +
      theme_void()
    p
  })
  
   output$summaryPlotly <- renderPlotly({
    #result <- summary_data_sf() %>% select(Incidents = accident_index) %>% 
      #aggregate(by = police_boundaries, FUN = length) %>%
      #mutate(Boundaries = police_boundaries$pfa16nm)
    #p <- ggplot(data = summary_data_sf()) +
      #geom_sf( aes(text = Boundaries, fill = Incidents)) +
      #scale_fill_viridis_c() +
      #coord_fixed() +
      #theme_void()
    ggplotly(myPlot())  
    #p
    
  })
   
   output$summaryPlot <- renderPlot({
     #result <- summary_data_sf() %>% select(Incidents = accident_index) %>% 
     #aggregate(by = police_boundaries, FUN = length) %>%
     #mutate(Boundaries = police_boundaries$pfa16nm)
     #p <- ggplot(data = summary_data_sf()) +
       #geom_sf( aes(text = Boundaries, fill = Incidents)) +
       #scale_fill_viridis_c() +
       #coord_fixed() +
       #theme_void()
     #ggplotly(p)  
     myPlot()
     
   })
   output$summaryValues <- renderValueBox({
     valueBox("Yearly Accident Summaries",
              paste0("Yearly range : ", input$year[1], " until ", input$year[2]),
     )
   })
   output$summaryValuesCounty <- renderValueBox({
     valueBox(subtitle = paste0("Yearly Accident Summaries, in ", 
                                input$police_boundary, " police area."), 
              value = paste0("Yearly range : ", input$year[1], " until ", input$year[2]),
     )
   })
   
   accident_victim <- reactive({
     result <- if(input$activity == "Walking"){
       " walker"
     } else if(input$activity == "Cyclist"){
       " cyclist"
     } else {" vehicle passenger"}
   })
   
   output$accident_numbers <- renderValueBox({
     valueBox(value = paste0(nrow(crashes_activity_lonlat()), " accidents."),
              subtitle = paste0(input$severity, " accidents involving a ", accident_victim(), "."))
   })
   output$severityType <- renderInfoBox({
     infoBox("Severity of Accidents",
             if(input$severity == "All"){
               paste0("All accident types")
             }
             else{
               paste0(input$severity, " accidents only.")
             }
     )
   })
   
  # Show a popup at the given location
  showAccidentPopup <- function(index, latitude, longitude) {
    selectedIndex <- crashes_activity_lonlat()[accident_index == index,]
    output$table2 <- renderDataTable(selectedIndex[, .(sex_of_casualty, age_band_of_casualty, casualty_type, weather_conditions)])
    num_rows <- nrow(selectedIndex)
    
    content <- as.character(tagList(
      tags$h3(paste0(selectedIndex[1, accident_severity], " accident")),                 
      tags$h5(paste0(selectedIndex[1, police_force], " police force")),
      tags$h5("Local Authority District: ", selectedIndex[1, local_authority_district]),
      tags$h5("Number of casualtites: ", num_rows),
      tags$h5("Date : ", selectedIndex[1,date_formatted]),
      
      tags$h5("Weather conditions : ", selectedIndex[1, weather_conditions])
    ))
    leafletProxy("map") %>% addPopups(longitude, latitude, content)
  }
  
  # When map is clicked, show a popup with accident info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    #print(paste0("event$id : ", event$id))
    
    if (is.null(event))
      return()
    
    isolate({
      showAccidentPopup(event$id, event$lat, event$lng)
    })
  })
  
  observe({
    colorData <-factor(c("Fatal", "Slight", "Serious"))
    pal <- colorFactor("viridis", colorData)
    radius <- 500
    
    leafletProxy("map", data = crashes_activity_lonlat()) %>%
      clearShapes() %>%
      setView(lng = mean_location()$meanLong, lat = mean_location()$meanLat, zoom = 9) %>%
      addCircles(lng = ~longitude, 
                 lat = ~latitude, radius=radius, 
                 stroke=FALSE, fillOpacity=0.4, fillColor= ~pal(accident_severity),
                 layerId = ~accident_index
                 
      ) %>%
      addLegend("bottomleft", pal=pal, values=colorData, title="Accident Severity",
                layerId="colorLegend")
  })
} ## server
