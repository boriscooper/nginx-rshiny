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
library(aws.signature)
library(aws.s3)
##-------------------------------------------------------

## set police force boundary names
my_boundary_choices <- sort(police_boundaries$pfa16nm)
police_data <- police_boundaries %>% mutate(police_force = pfa16nm) %>% select(police_force, geometry)

##--------------------------------------------------------
##Read data from Amazon AWS S3 bucket "shinyRoadSafety"
use_credentials()
crashes_allDT <- s3readRDS(object = "crashes_2013_2017DT.rds", bucket = "roadsafetyshiny")
setkey(crashes_allDT, accident_index)

##--------------------------------------------------------
