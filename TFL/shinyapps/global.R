## Start up database

## LIBRARY PACKAGES
library(sf)
library(dplyr)
library(data.table)
library(ggplot2)
library(shiny)
library(shinydashboard)
library(leaflet)
library(geojsonsf)
library(rgdal)
##-------------------------------------------------------
base_dir <- "/srv/shiny-server"
data_dir <- file.path(base_dir, "data")
##  Bus stop data
lat <- 51.5
lon <- 0.0
zoom <- 10
##------------------------------------------------------
ukgrid <- "+init=epsg:27700"
latlong <- "+init=epsg:4326"

bus_stopsDT <- fread(file = file.path(data_dir, "bus-stops-10-06-15.csv"))
bus_stopsDT <- bus_stopsDT[1:nrow(bus_stopsDT)-1, ] ## remove empty last row
coordsDT <- bus_stopsDT[, .(Location_Easting, Location_Northing)]
##-------------------------------------------------------
## function to add lon and lat coordinates to sequence data table
new_sequence <- function(bus_stopsDT, sequenceDT){
        setkey(sequenceDT, Stop_Code_LBSL)
        result <- merge(sequenceDT, bus_stopsDT, on = "Stop_Code_LBSL")
        result <- result[, .(Stop_Code_LBSL, Route, Run, Sequence, Heading.x, Stop_Name.x, lon, lat )]
        result[, Run := ifelse(Run == 1, "Out", "Return")]
        old_names <- names(result)
        new_names <- c("Stop_Code_LBSL", "Route", "Run", "Sequence", "Heading", "Stop_Name", "lon", "lat")
        setnames(result, old = old_names, new = new_names)
        setkey(result, Route, Run, Sequence)
        result
}
##-------------------------------------------------------

## function to select route data table
route_sequence <- function(sequenceDT, route_number, direction = 1){
        result <- sequenceDT[Route == route_number & Run == direction]
        result
}

##---------------------------------------------------

# Create the SpatialPointsDataFrame
bus_stops_SP <- SpatialPointsDataFrame(coords = coordsDT, data = bus_stopsDT[, .(Stop_Code_LBSL, Bus_Stop_Code, Stop_Name)],
                                       proj4string = CRS(ukgrid))
### Convert
bus_stops_SP_LL <- spTransform(bus_stops_SP, CRS(latlong))
bus_stopsDT[, lon := coordinates(bus_stops_SP_LL)[,1]][, lat := coordinates(bus_stops_SP_LL)[,2]]
setkey(bus_stopsDT, Stop_Code_LBSL)
##--------------------------------------------------------
## Bus stop sequence examples
bus_stop_sequenceDT <- fread(file = file.path(data_dir, "stop-sequences-example.csv"))
new_bus_stop_sequenceDT <-new_sequence(bus_stopsDT, bus_stop_sequenceDT)
##-----------------------------------------------------------


