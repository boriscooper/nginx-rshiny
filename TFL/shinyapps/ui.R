## Shiny Dashboard expt1
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Transport for London Bus Routes"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Interactive Map", tabName = "dashboard", icon = icon("dashboard"))
     
    ),
    h3("London Bus Routes"),
    br(),
    h4("Choose Route Number"),
    selectInput(inputId = "route_number",
                label = "",
                choices = c("1", "2", "3", "4", "5"),
                width = '40%',
                selected = "1", multiple = FALSE),
    
    radioButtons(inputId = "direction",
                 label = "Direction of travel",
                 choices = c("Out", "Return"),
                 selected = "Out")
   
  ), ## dashboardSidebar
  dashboardBody(

      fluidRow(
           leafletOutput("map", height = "800px")
                         
      ) ## fluidRow
    

) ## dashboardBody
)  ## dashboardPage
