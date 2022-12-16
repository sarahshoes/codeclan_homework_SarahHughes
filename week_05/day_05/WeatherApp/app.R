#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(bslib)

##set up default input
input <- list(location = "lerwick",
              param = "tmax",
              baseline = "1991-2020")
input$st_year = as.numeric(str_sub(input$baseline,1,4)) 
input$end_year = as.numeric(str_sub(input$baseline,6,9))

##read in data - creates all_data and all_header
source(here::here("read_met_data.R"))

##analyse data
source(here::here("analyse_met_data.R"))
met_data <- met_data  %>% 
    mutate(param = recode(param, "tmax" = "Mean Daily Max Temperature",
                          "tmin" = "Mean Daily Min Temperature",
                          "af"   = "Air Frost",
                          "rain" = "Rainfall",
                          "sun" = "Sunshine"))

param_list = unique(met_data$param)
location_list = unique(met_data$location)
units = c("degC","degC","days","mm","hours")

## theme for plot
palette = read_csv(here::here("met_palette.csv"))

theme_met <- 
    theme(
        text = element_text(size = 14),
        title = element_text(size = 14),
        axis.text = element_text(size = 14),
        legend.text = element_text(size = 12),
        panel.background = element_rect(fill = "white"),
        panel.grid = element_line(colour = "grey90", linetype = "dashed"),
        legend.position = "bottom"
    )

##

# Define UI for application that draws a histogram
ui <- fluidPage(
    theme = bs_theme(bootswatch = "minty"),
    # Application title
    titlePanel("Weather Data Comparison"), 
    
    fluidRow(
        column(width = 6, align = "center",
               checkboxGroupInput(inputId = "location_input",
                                  label = tags$strong("Select Locations to Plot"),
                                  choices = location_list)
        ),
        column(width = 6, align = "center",
               selectInput(inputId = "param_input",
                           label = tags$strong("Select Parameter to Plot"),
                           choices = param_list)
        ),
        fluidRow(
            column(width =10, offset =1,
                   plotOutput("mnthly_met_plot")
            )
        )
    ),
    tags$a("Data source: UK Metoffice historic station data. Average monthly values are calculated relative to 1991-2020 baseline", 
           href = "https://www.metoffice.gov.uk/research/climate/maps-and-data/historic-station-data")
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$mnthly_met_plot <- renderPlot({
        met_select <- met_data %>% 
            filter(location %in% input$location_input) %>% 
            filter(param == input$param_input)
        
        ggplot(met_select) +
            (aes(x = mm, y = mnth_avg_data, colour = location)) +
            geom_line(linewidth = 1.5) +
            geom_point(size = 3) +
            ylab(paste0(input$param_input," (",units[which(param_list == input$param_input)],")")) +
            xlab("Month") +  
            scale_x_continuous(n.breaks = 12) +
            scale_colour_manual(values = palette$colours) +
            theme_met
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
