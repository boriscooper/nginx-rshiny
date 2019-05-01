## Shiny Dashboard Expt1
server <- function(input, output) { 
  
  mean_location <- reactive({
    result <- route() %>%
      summarise(meanLat = mean(lat), meanLong = mean(lon))
    result
  })
  
  route <- reactive({
    result <- route_sequence(new_bus_stop_sequenceDT, 
                             input$route_number,
                             input$direction)
    result
  })
  
  
  output$map <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>% 
      setView(lng = lon, lat = lat, zoom = zoom)
    #leaflet() %>%
      #addTiles(
        #urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        #attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      #)  %>% 
      #setView(lng = lon, lat = lat  , zoom = zoom)
  })  
  
  observe({
    
    leafletProxy("map", data = route()) %>%
      clearMarkers() %>%
      setView(lng = mean_location()$meanLong, 
              lat = mean_location()$meanLat, 
              zoom = 12) %>%
      
      addAwesomeMarkers(lng = ~lon, 
                        lat = ~lat, 
                        icon =  awesomeIcons(
                           icon = 'chevron-circle-up',
                           library = 'fa',
                           iconRotate = ~Heading,
                           markerColor = ifelse(input$direction == "Out","darkgreen", "purple")
                        ),
                      label = ~Stop_Name,
                      layerId = ~Stop_Code_LBSL)
    #addMarkers(lng = ~lon,
               #lat = ~lat,
               #popup = ~Stop_Name,
               #layerId = ~Stop_Code_LBSL)
      
    
                 
      
      #addLegend("bottomleft", pal=pal, values=colorData, title="Accident Severity",
                #layerId="colorLegend")
  })
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    #print(paste0("event$id : ", event$id))
    #print(paste0("event$lat : ", event$lat))
    #print(paste0("event$lng : ", event$lng))
    
    if (is.null(event))
      return()
    
    isolate({
      showBusInfoPopup(event$id, event$lat, event$lng)
    })
    
  })
  
  showBusInfoPopup <- function(index, latitude, longitude) {
    selectedIndex <- route()[Stop_Code_LBSL == index,]
    #output$table2 <- renderDataTable(selectedIndex[, .(Route, Stop_Name)])
    #num_rows <- nrow(selectedIndex)
    
    content <- as.character(tagList(
      tags$h3(paste0("Route : ",selectedIndex[1, Route])),                 
      tags$h5(paste0("Stop Name : ", selectedIndex[1, Stop_Name]))
      
    ))
    leafletProxy("map") %>% addPopups(longitude, latitude, content)
  }
} ## server
