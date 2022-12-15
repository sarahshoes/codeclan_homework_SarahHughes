---
title: "Load data and test plots"
output: html_notebook
---

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

```{r}
library(tidyverse)
library(janitor)
library(colorfindr)
library(lubridate)
```


## define function for stripping strings
# keeps going until all strings have been removed
```{r}
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
```

## define function for reading header
```{r}
extract_header <- function(filename){
  #filename <-  "lerwickdata.txt"
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
```

```{r}
input <- list(location = "lerwick",
              param = "tmax",
              baseline = "1991-2020")

input$st_year = as.numeric(str_sub(input$baseline,1,4)) 
input$end_year = as.numeric(str_sub(input$baseline,6,9))
```
```{r}
filename <- str_c(input$location,"data.txt")
header <- extract_header(filename)
data <- read.table(here::here("raw_data",filename), header = FALSE, skip = 7, comment.char = "P", fill = TRUE, flush = TRUE, col.names = header$col_names)
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
data <- data %>% 
  mutate(location = str_to_lower(header$location))
rm(header)
```
# apply averaging
```{r}
avg_data <- data %>% 
  filter(location == input$location) %>% 
  filter(yyyy >= input$st_year & yyyy < input$end_year) %>% 
  group_by (mm) %>% 
  select(-yyyy) %>% 
  summarise(across(where(is.numeric),
                     ~{median(.x, na.rm = TRUE)})) 
```

```{r}
max_data <- data %>% 
  filter(location == input$location) %>% 
  filter(yyyy >= input$st_year & yyyy < input$end_year) %>% 
  group_by (mm) %>% 
  select(-yyyy) %>% 
  summarise(across(where(is.numeric),
                     ~{max(.x, na.rm = TRUE)})) 
```

```{r}
min_data <- data %>% 
  filter(location == input$location) %>% 
  filter(yyyy >= input$st_year & yyyy < input$end_year) %>% 
  group_by (mm) %>% 
  select(-yyyy) %>% 
  summarise(across(where(is.numeric),
                     ~{min(.x, na.rm = TRUE)})) 
```

# merge averages back into file
```{r}
met_data = pivot_longer(data, c(tmax,tmin,af,rain,sun), 
                        names_to = "param", 
                        values_to = "data") 
```

```{r}
met_avg = pivot_longer(avg_data, c(tmax,tmin,af,rain,sun), 
                        names_to = "param", 
                        values_to = "mnth_avg_data") 
```

```{r}
met_min = pivot_longer(min_data, c(tmax,tmin,af,rain,sun), 
                        names_to = "param", 
                        values_to = "mnth_min_data") 
```

```{r}
met_max = pivot_longer(max_data, c(tmax,tmin,af,rain,sun), 
                        names_to = "param", 
                        values_to = "mnth_max_data") 
```

```{r}
avg_merge = merge(met_avg,met_max)
avg_merge = merge(avg_merge,met_min)
rm(data,avg_data,max_data,min_data)
rm (met_avg,met_max,met_min)
```


```{r}
all_met = left_join(met_data,avg_merge, by = c("mm","param")) %>% 
  mutate(anom_data = data - mnth_avg_data)
```

#test plot
```{r}
all_met %>%
  # create decimal year data for plotting
  mutate(dec_year = yyyy+(mm-0.5)/12) %>% 
  # select param to plot
  filter(param==input$param) %>% 
  ggplot() +
  #geom_line(aes(x=dec_year, y = data)) +
  #geom_line(aes(x=dec_year, y = mnth_avg_data), col = "gray") +
  geom_line(aes(x = dec_year, y = anom_data), col = "red")
```
#test plot
```{r}
all_met %>%
  # create decimal year data for plotting
  mutate(dec_year = yyyy+(mm-0.5)/12) %>% 
  # select param to plot
  filter(param==input$param) %>% 
  ggplot() +
  geom_line(aes(x=dec_year, y = data)) 
```

Recode data ready for app

```{r}
all_met <- all_met  %>% 
  mutate(param = recode(param, "tmax" = "Mean Daily Max Temperature",
                        "tmin" = "Mean Daily Min Temperature",
                        "af"   = "Air Frost",
                        "rain" = "Rainfall",
                        "sun" = "Sunshine"))
```


## merge all files together
```{r}
data=left_join(data1,data2)
data=left_join(data,data3)
```



```{r}
write_csv(met_data,here::here(
    "clean_data", "met_data.csv"))
```



```{r}
#create example plot
input <- list(param = "Sunshine", 
location = c("lerwick","eastbourne"))

param_list = unique(met_data$param)
location_list = unique(met_data$location)
units = c("degC","degC","days","mm","hours")

met_select <- met_data %>% 
filter(location %in% sel_location) %>% 
filter(param == sel_param)

ggplot(met_select) +
(aes(x = mm, y = data, colour = location)) +
geom_line(linewidth = 1.5) +
geom_point(size = 3) +
ylab(paste0(input$param," (",units[which(param_list == input$param)],")")) +
xlab("Month") +  
scale_x_continuous(n.breaks = 12) 
#scale_colour_manual(values = palette$colours) +
#theme_met
```

```{r}
met_data%>% 
  mutate(decyr = yyyy+((mm-0.5)/12)) %>% 
  ggplot()+
  aes(x = decyr, y = data)
  geom_line()

```




# create theme colours

# extract palette from screenshot of minty theme
```{r}
# If you rerun this colour selection will change
#metpal <- get_colors(here::here("minty_screenshot.png"))%>%  make_palette(n = 10)

#colours <- metpal[c(7,8,9)]
#metpal2 <- as.data.frame(colours)
#write_csv(metpal2,here::here("met_palette.csv"))
```

