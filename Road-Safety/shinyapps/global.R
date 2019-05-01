## Start up database

## LIBRARY PACKAGES
library(stats19)
library(sf)
library(dplyr)
library(data.table)
library(ggplot2)
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(plotly)
library(leaflet)
library(geojsonsf)
##-------------------------------------------------------

## set police force boundary names
my_boundary_choices <- sort(police_boundaries$pfa16nm)
police_data <- police_boundaries %>% mutate(police_force = pfa16nm) %>% select(police_force, geometry)

##--------------------------------------------------------
##Read data from Amazon AWS S3 bucket "shinyRoadSafety"
#use_credentials()
#crashes_allDT <- s3readRDS(object = "crashes_2013_2017DT.rds", bucket = "roadsafetyshiny")
#setkey(crashes_allDT, accident_index)
## Read data from data directory
base_dir <- "/srv/shiny-server"
crashes_allDT <- readRDS(file = file.path(base_dir, "data", "crashes_2013_2017DT.rds"))
##--------------------------------------------------------
