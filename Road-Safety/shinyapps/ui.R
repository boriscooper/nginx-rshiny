## Shiny Dashboard expt1
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Road Safety England"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Interactive Map", tabName = "dashboard", icon = icon("dashboard"))
      #menuItem("Summary Map", tabname = "summary"),
      #menuItem("Data Summaries", tabName = "widgets", icon = icon("th"))
    ),
    h3("Inputs for interactive map of England"),
    br(),
    sliderInput(inputId = "year",
                label = "Select year(s)",
                min = 2013,
                max = 2017,
                value = c(2016, 2017),
                round = TRUE,
                sep = ""),
    selectInput(inputId = "severity",
                label = "Choose accident severity",
                choices = c("All", "Fatal", "Serious", "Slight"),
                selected = "All", multiple = FALSE),
    selectInput(inputId = "police_boundary",
                label = "Select police boundary",
                choices = my_boundary_choices,
                selected = "Avon and Somerset",
                multiple = FALSE),
    radioButtons(inputId = "activity",
                 label = "Select type of activity",
                 choices = c("Walking", "Cyclist", "Passenger"),
                 selected = "Walking")
    
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              tabBox(id = "RoadSafetydata",
                title = "Road Safety data", width = "600px",
                # The id lets us use input$tabset1 on the server to find the current tab
                tabPanel("County Map", "",
                         fluidRow(
                             leafletOutput("map", height = "600px") %>% withSpinner(color="#0dc5c1"),
                          br(),
                          valueBoxOutput(outputId = "summaryValuesCounty", width = 10),
                          valueBoxOutput(outputId = "accident_numbers", width = 10)
                         ) ## fluidRow
                        ) ,## tabPanel
                         
                tabPanel("Nationwide map", "Yearly Accident summaries",
                         fluidRow(
                              plotlyOutput(outputId = "summaryPlotly") %>% withSpinner(color="#0dc5c1"),
                              br(),
                              valueBoxOutput(outputId = "summaryValues", width = 10),
                              infoBoxOutput(outputId = "severityType", width = 10)
                         )## fluidRow
               # tabPanel("Tab3", "Tab content 3",
                        # plotOutput(outputId = "summaryPlot"))
                ) ## tabPanel
             
      ) ## tabBox
      ) ## tabItem
      # Second tab content
      #tabItem(tabName = "dashboard",
              #plotlyOutput(outputId = "summaryPlot")
              #h2("Widgets tab content")
     # )
    ) ##  tabItems
  
) ## dashboardBody
)  ## dashboardPage
