#' \code{GMU_commute} Function to read the GMU commute data 
#' 
#' @title GMU_commute
#' @param csvfile .csv filename containing the GMU commute data
#' @author Gabi Armada 
#' @export

library(tidyverse)
library(lubridate)

GMU_commute <- function(file){
  headers <- read.csv(file, header = F, nrows = 1, as.is = T)
  df1 <- read.csv(file, skip = 3, header = F)
  colnames(df1) = headers 
  
  total_trips <- n_distinct(df1$Trip)
  
  df2 <- df1 %>% 
          select("Date & Time", "Latitude", "Longitude", "Trip", "Trip duration", "Trip distance")
  
  df2 <- df2 %>% group_by(Trip) %>% 
        mutate(trip_total_time = max(`Trip duration`))
  df2 <- df2[!(df2$trip_total_time < "00:05:00"),] 
  df2 <- df2[df2$Latitude != 0, ] 
  df2 <- df2[df2$Longitude !=0, ]
  
  actual_trips <- n_distinct(df2$Trip) 
  percent_usable_trips <- (actual_trips/total_trips)*100
  return (c(total_trips, actual_trips, percent_usable_trips))
}



