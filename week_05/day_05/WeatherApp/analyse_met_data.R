## Script for analysing in met data

# apply averaging

avg_data <- all_data %>% 
  #filter(location == input$location) %>% 
  filter(yyyy >= input$st_year & yyyy < input$end_year) %>% 
  group_by (location, mm) %>% 
  select(-yyyy) %>% 
  summarise(across(where(is.numeric),
                   ~{median(.x, na.rm = TRUE)})) %>% 
  ungroup()


max_data <- all_data %>% 
  filter(yyyy >= input$st_year & yyyy < input$end_year) %>% 
  group_by (location,mm) %>% 
  select(-yyyy) %>% 
  summarise(across(where(is.numeric),
                   ~{max(.x, na.rm = TRUE)})) %>%  
  ungroup()

min_data <- all_data %>% 
  filter(yyyy >= input$st_year & yyyy < input$end_year) %>% 
  group_by (location, mm) %>% 
  select(-yyyy) %>% 
  summarise(across(where(is.numeric),
                   ~{min(.x, na.rm = TRUE)})) %>% 
  ungroup()


# merge averages back into file
met_data = pivot_longer(all_data, c(tmax,tmin,af,rain,sun), 
                        names_to = "param", 
                        values_to = "data") 

met_avg = pivot_longer(avg_data, c(tmax,tmin,af,rain,sun), 
                       names_to = "param", 
                       values_to = "mnth_avg_data") 


met_min = pivot_longer(min_data, c(tmax,tmin,af,rain,sun), 
                       names_to = "param", 
                       values_to = "mnth_min_data") 

met_max = pivot_longer(max_data, c(tmax,tmin,af,rain,sun), 
                       names_to = "param", 
                       values_to = "mnth_max_data") 

avg_merge = merge(met_avg,met_max)
avg_merge = merge(avg_merge,met_min)
rm(avg_data,max_data,min_data)
rm (met_avg,met_max,met_min)

met_data <- left_join(met_data,avg_merge, by = c("mm","param","location")) %>% 
 mutate(anom_data = data - mnth_avg_data)
