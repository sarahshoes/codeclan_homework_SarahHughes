## Script for reading in met data
  
  # Note that data input ignores 'provisional' tags on data
  # Data from most recent year is likely to be provisional
  
  #  the file structure is like this
  #  header line1 with location
  #  header line2 including position
  #  header line3
  #  header line4
  #  header line5
  #  yyyy  mm   tmax    tmin      af    rain     sun
  #              degC    degC    days      mm   hours

# data quality flags are * for estimated data and # for different sun detector

# for testing - parameters that will maybe be passed?

input <- list(location = "lerwick",
              param = "tmax",
              baseline = "1991-2020")
input$st_year = as.numeric(str_sub(input$baseline,1,4)) 
input$end_year = as.numeric(str_sub(input$baseline,6,9))

# Set up libraries needed -------------------------------------------------
library(tidyverse)
library(janitor)
library(colorfindr)
library(lubridate)

# Section 1 - Define function for reading in header -----------------------

# data is in a fixed width format with 7 header lines
# this code reads header and extracts the necessary metadata from it

extract_header <- function(filename){
  header_txt <- read_lines(here::here("raw_data",filename),n_max = 7)
  location_txt <- header_txt[1]
  position_lat <- str_extract(header_txt[2], "Lat\\s.{6}") #identify lat string
  position_lat <- as.numeric(str_remove(position_lat,"Lat ")) #strip lat string
  position_lon <- str_extract(header_txt[2], "Lon\\s.{6}") #identify lon string
  position_lon <- as.numeric(str_remove(position_lon,"Lon ")) #strip lon string
  col_txt <- str_split(header_txt[6], pattern = "\\s{1,}", simplify = TRUE)
  col_txt <- col_txt[2:8]
  param_txt <- str_split(header_txt[7], pattern = "\\s{1,}", simplify = TRUE)
  param_txt <- param_txt[2:5]
  header <- list("location" = location_txt,
                 "param_names" = param_txt,
                 "col_names" = col_txt,
                 "latitude" = position_lat,
                 "longitude" = position_lon)
}


# Section 4 Define function for reading a met data file -------------------

read_data <- function(filename){
  #read data
  data <- read.table(here::here("raw_data",filename), 
                     header = FALSE, skip = 7, #skip over header rows 
                     comment.char = "P", # removes lines that have Provisional
                     fill = TRUE, 
                     flush = TRUE, 
                     col.names = header$col_names) #take this from header
  data$tmax <- strip_strings(data$tmax,c("\\*","\\#"))
  data$tmax <- as.double(data$tmax)
  data$tmin <- strip_strings(data$tmin,c("\\*","\\#"))
  data$tmin <- as.double(data$tmin)
  data$af <- strip_strings(data$af,c("\\*","\\#"))
  data$af <- as.double(data$af)
  data$rain <- strip_strings(data$rain,c("\\*","\\#"))
  data$rain <- as.double(data$rain)
  data$sun <- strip_strings(data$sun,c("\\*","\\#"))
  data$sun <- as.double(data$sun)  
  data %>% 
    mutate(location = str_to_lower(header$location))
}

# Section 2 Define function for stripping strings -------------------------

# some data values are tagged with * to indicate provisional data
# we are treating this data in the same way as non-provissional data so need 
# will just ignore this tag. some sunshine data are also tagged with # to 
# indicate instrument used. again we are ignoring this 

strip_strings <- function(old_column, strings){
  cleaned <- old_column
  # order strings longest first so "string within string" is not a problem
  order <- sort(nchar(strings), decreasing=TRUE, index.return=TRUE)
  strings <- strings[order$ix]
  for (badstring in strings){
    cleaned <- str_remove(cleaned,str_c(" ",badstring)) 
    #adding this doesnt allow for a string to be 'embedded'
    cleaned <- str_trim(cleaned)
  }
  return(cleaned)  
}

# Section 4 - Identify data files available ------------------------------------

# will expand this section to identify available data from a directory
# for now its just a list
location_list = c("lerwick","paisley","eastbourne")

# Section 5 - Read in the data --------------------------------------------

for (iloc in 1:length(location_list)){
  filename <- str_c(location_list[iloc],"data.txt")
  #first read header
  header <- extract_header(filename)
  #then read data
  data <- read_data(filename)
  if (iloc == 1){
  all_data <- data
  all_header <- header
  } else {
  all_data <- bind_rows(all_data,data)
  all_header$location <- paste(all_header$location,header$location)
  all_header$longitude <- paste(all_header$longitude,header$longitude)
  all_header$latitude <- paste(all_header$latitude,header$latitude)
     }
}
rm(header,data)