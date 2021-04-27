# Summary-Commutes
This repository contains the Summary Commutes function and Procedure used to return the percent usable trip data collected by participants. <br /><br />


The goal of the Summary Commutes Procedure is to create a table that contains the participants of the Air Quality study, the number of trips taken by each participant, and the percent usable data collected from these trips. This will help determine if trips have full, partial, minimal, or no GPS data available and how many trips for each participant have GPS data available. <br /><br />


## GMU_commute function 
The GMU_commute function reads in a .csv file that corresponds to the GPS data of each participant in the Air Quality study. These .csv files are quite large and are continuously recording trip data. However, not all of the data collected are deemed "usable" for research. We define usable data as trips that are longer than 5 minutes and trips that are properly recording data. For example, a trip may be logged in the participant's .csv file, but longitude and latitude variables were not being recorded, therefore, the data from this trip does not qualify as "usable" data. By defining usable data, we are able to filter out any test runs recorded as trips, or the set up of the car monitors recorded as trips.<br /><br />

#### Let's go through what the GMU_commute() function does...

This function accepts one parameter, file, which is the name of the .csv file containing participant GPS data.<br /><br />

The first line of the function reads in the first row of the .csv file and assigns its output to the variable **headers**. The second line of the function then reads in the entire data frame, skipping the first 3 rows and assigning the output to **df1**. Then, the headers extracted from the first row of the .csv file are assigned as the column names of **df1**:  

```
headers <- read.csv(file, header = F, nrows = 1, as.is = T)
df1 <- read.csv(file, skip = 3, header = F)
colnames(df1) = headers 
```

> Note: the .csv files containing paricipant GPS data begin recording data on row 4. The second row of the .csv file is blank, while the third row contains the units for each column variable. We do not want our function to read in these rows, so we skip them. 

The following line of the function counts the number of unique Trips in the .csv file and assigns the output to the variable **total_trips**: 
```
total_trips <- n_distinct(df1$Trip)
```
<br />

The next line of the function selects the following columns of interest from df1: *Date & Time*, *Latitude*, *Longitude*, *Trip*, *Trip duration*, *Trip distance*, and assigns the new data frame to the variable **df2**: 
```
df2 <- df1 %>% 
          select("Date & Time", "Latitude", "Longitude", "Trip", "Trip duration", "Trip distance")
```
<br />
The following lines are the meat of the function, as they "clean-up" the original dataframe. First the newly created dataframe, **df2**, is grouped by the variable *Trip*. A new column is created, *trip_total_trip*, which contains the total duration of each trip. The dataframe is then subsetted by removing rows that do not have total trip time greater than 5 minutes. Similarly, the dataframe is subsetted again by removing rows that contain *O* for the *Latitude* and *Longitude* variables: 
```
df2 <- df2 %>% group_by(Trip) %>% 
        mutate(trip_total_time = max(`Trip duration`))
df2 <- df2[!(df2$trip_total_time < "00:05:00"),] 
df2 <- df2[df2$Latitude != 0, ] 
df2 <- df2[df2$Longitude !=0, ]
```
<br /> 
The next line of the function then count the number of unique trips remaining in the newly subsetted dataframe, and assigns the output to the variable **actual_trips**. The following line calculates the percent of usable trip data available in the original .csv file of the participant, and assigns the output to the variable **percent_usable_trips**: 
```
actual_trips <- n_distinct(df2$Trip) 
percent_usable_trips <- (actual_trips/total_trips)*100
```
<br /> 
Finally, the function returns a vector containing the variables **total_trips**, **actual_trips**, and **percent_usable_trips**: 
```
return (c(total_trips, actual_trips, percent_usable_trips))
```
<br /><br /><br />
## Summary Commutes Procedure 
