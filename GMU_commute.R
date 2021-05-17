#' \code{GMU_commute} Function to read the GMU commute data 
#' 
#' @title GMU_commute
#' @param file .csv filename containing the GMU commute data
#' @param output string of the desired function output; accepted values are: "trip summary", "overall summary", or "df"
#' @author Gabi Armada and Jenna Krall 
#' @export

library(tidyverse)
library(lubridate)
library(data.table)
GMU_commute <- function(file, output){
  headers <- read.csv(file, header = F, nrows = 1, as.is = T)
  headers <- as.character(headers[, c(2:18)])
  df1 <- fread(file, skip = 3, select = c(2 : 18))
  colnames(df1) = headers
  
  total_trips <- n_distinct(df1$Trip)
  
  df2 <- df1 %>% 
          select("Date & Time", "Latitude", "Longitude", "Trip", "Trip duration", "Trip distance")
  
  df2 <- df2 %>% 
          group_by(Trip) %>% 
          mutate(trip_total_time = max(`Trip duration`))
  df2 <- df2[!(df2$trip_total_time < "00:05:00"),] 
  
  # create variable for missingness (for %)
  df2 <- mutate(df2, missing = ifelse(Latitude == 0 | Longitude == 0, 0, 1))
  actual_trips <- filter(df2, missing == 1) %>% 
                  select(Trip) %>% 
                  n_distinct() 
  
  # trip summary (% missing)
  trip_summaries <- summarize(df2, nrows = n(), sum = sum(missing), mean = mean(missing))
  
  # overall summary
  overall_summary<- ungroup(df2) %>% 
                    summarize(nrows = n(), 
                              sum = sum(missing),
                              mean = round(mean(missing), digits = 3)) %>%
                    mutate(total_trips = total_trips, actual_trips = actual_trips)
  
  # filter df2 (only usable rows)
  df2 <- filter(df2, missing == 1)
  
  if (output == "trip summary"){
    return (trip_summaries)}
    else if (output == "overall summary"){
      return(overall_summary)} 
    else if(output == "df"){
      return (df2)}
}