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

## initate data
met_data = read_csv(here::here("clean_data/met_data.csv"))

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
               checkboxGroupInput(inputId = "location",
                                  label = tags$strong("Select Locations to Plot"),
                                  choices = location_list)
        ),
        column(width = 6, align = "center",
               selectInput(inputId = "param",
                           label = tags$strong("Select Parameter to Plot"),
                           choices = param_list)
        )
        ),
        fluidRow(
            column(width =10, offset =1,
                   plotOutput("met_plot")
            )
        ),
    tags$a("Data source: UK Metoffice historic station data. Average monthly values are calculated relative to 1991-2020 baseline", 
           href = "https://www.metoffice.gov.uk/research/climate/maps-and-data/historic-station-data")
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$met_plot <- renderPlot({
        met_select <- met_data %>% 
            filter(location %in% input$location) %>% 
            filter(param == input$param)
        
        ggplot(met_select) +
            (aes(x = mm, y = data, colour = location)) +
            geom_line(linewidth = 1.5) +
            geom_point(size = 3) +
            ylab(paste0(input$param," (",units[which(param_list == input$param)],")")) +
            xlab("Month") +  
            scale_x_continuous(n.breaks = 12) +
            scale_colour_manual(values = palette$colours) +
            theme_met
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
