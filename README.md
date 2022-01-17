# Summary-Commutes

### Introduction
This repository contains the Summary Commutes function and procedure used to return usable GPS data collected by participants.<br /><br />
The goal of the Summary Commutes Procedure is to create a data table containing the participants of the Air Quality study, the number of trips taken by each participant, and the percent usable data collected from these trips. This will help determine if trips have full, partial, minimal, or no GPS data available and how many trips for each participant have GPS data available.


### Installation 

### How to use
The GMU_commute function reads a .csv file containing the GPS data of each participant in the Air Quality study. These .csv files are quite large and are continuously recording GPS data. However, not all of the data collected are deemed "usable" for research. <br /><br />
We define **usable data** as trips that are longer than 5 minutes and trips that are properly recording data. For example, a trip may be logged in the participant's .csv file, but longitude and latitude variables were not being recorded, therefore, the data from this trip does not qualify as "usable" data. By defining usable data, we are able to filter out any test runs recorded as trips, or the setting up of the pollution monitors recorded as trips.<br /><br />

`GMU_commute` must accept 2 parameters:<br />
`file`: the name of the .csv file containing participant GPS data.<br />
`output`: a string value of the desired output. 

> Accepted values for *output*: "trip summary", "overall summary", or "df".  

> Note: The "trip summary" ouput returns the total number of rows (GPS data), the number of usable rows, and the percent usable data for each trip. The "overall summary" output returns the total number of rows, the number of usable rows, the percent usable data, the total number of trips, and the usable number of trips for each participant. Finally, the "df" output returns the subsetted dataframe, containing only usable GPS data.

<br /><br />

#### GMU_commute()
The first line of the function reads in the first row of the .csv file and assigns its output to the variable `headers`. The second line of the function then subsets the variable `headers` to only include columns 2:18 (faster to read only the columns of interest, as there are approximately 200 columns in total). The third line of the function uses `fread()` to read in the entire data frame, skipping the first 3 rows, selecting columns 2:18, and assigning the output to `df1`. Then, `headers` are assigned as the column names of `df1`:  

```
headers <- read.csv(file, header = F, nrows = 1, as.is = T)
headers <- as.character(headers[, c(2:18)])
df1 <- fread(file, skip = 3, select = c(2 : 18))
colnames(df1) = headers
```

> Note: the .csv files containing paricipant GPS data begin recording data on row 4. The second row of the .csv file is blank, while the third row contains the units for each column variable. We do not want our function to read in these rows, so we skip them. 

The following line of the function counts the number of unique Trips in the .csv file and assigns the output to the variable `total_trips`: 
```
total_trips <- n_distinct(df1$Trip)
```
<br />

The next line of the function selects the following columns of interest from df1: `Date & Time`, `Latitude`, `Longitude`, `Trip`, `Trip duration`, `Trip distance`, and assigns the new data frame to the variable `df2`: 
```
df2 <- df1 %>% 
       select("Date & Time", "Latitude", "Longitude", "Trip", "Trip duration", "Trip distance")
```
<br />

The following lines are the meat of the function, as they "clean-up" the inputted dataframe. First, the newly created dataframe, `df2`, is grouped by the variable `Trip`. A new column is created, `trip_total_time`, which contains the total duration of each trip. The dataframe is then subsetted by removing rows that do not have a total trip time greater than 5 minutes. Next, we mutate a column `missing`, that contains a 1 or 0 for each row of the dataframe. 

> Note: a value of 1 represents that latitude/longitude values were properly recorded, and a value of 0 represents that latitude/longitude values were not properly recorded (i.e. are recorded as 0). 

Similarly, the dataframe is subsetted again to only keep rows where the `missing` value is 1 (i.e. only keep rows where latitude/longitude were properly recorded). The variable `actual_trips` contains the number of usable trips after the dataframe has been subsetted to only include "usable data":

```
df2 <- df2 %>% 
        group_by(Trip) %>% 
        mutate(trip_total_time = max(`Trip duration`))
df2 <- df2[!(df2$trip_total_time < "00:05:00"),] 

# create variable for missingness (for %)
df2 <- mutate(df2, missing = ifelse(Latitude == 0 | Longitude == 0, 0, 1))
actual_trips <- filter(df2, missing == 1) %>% 
                select(Trip) %>% 
                n_distinct() 
```
<br /> 

The following lines of the function generate summary data by trip (`trip_summaries`) and by participant (`overall_summary`). The trip summaries count the total number of rows, the number of usable rows, and the percent usable data **for each distinct trip**. The overall summary counts the total number of rows, the number of usable rows, the percent usable data, the total trips, and the usable trips **for each participant file**. 
```
# trip summary (% missing)
trip_summaries <- summarize(df2, nrows = n(), sum = sum(missing), mean = mean(missing))
  
# overall summary
overall_summary<- ungroup(df2) %>% 
                  summarize(nrows = n(), 
                            sum = sum(missing),
                            mean = round(mean(missing), digits = 3)) %>%
                  mutate(total_trips = total_trips, actual_trips = actual_trips)
```
<br /> 

Next, the function filters `df2` to only include rows with usable data:
```
# filter df2 (only usable rows)
df2 <- filter(df2, missing == 1)
```
<br /> 

Finally, the GMU_commute() function returns an output based on the string output defined by the user. The following if/else if statements show the control structure of the function's return values: 
```
if (output == "trip summary"){
    return (trip_summaries)}
  else if (output == "overall summary"){
    return(overall_summary)} 
  else if(output == "df"){
    return (df2)}
```

### Implementation
The next step in the Summary Commutes Procedure is to pass all participant GPS data files through the `GMU_commute()` function. In order to do this in an efficient manner, we use a for loop to pass the participant data into the `file` parameter of the `GMU_commute()` function and display the outputs in a table. 
<br />  

The following line uses `dir_ls()` from the `fs` package to store all participant GPS data file paths, and assign them to the variable `file_paths`: 
```
file_paths <- fs::dir_ls(here("GPS data"))
```
<br />  
In the following lines, we initialize the matrix `usable_trips` with the number of rows as the length of the variable `file_paths` (i.e. the number of participant data files we have) and the number of columns as 6. Then, `colnames()` is used to set the respective column names for the `usable_trips` matrix that we just created.  
<br />  

```
usable_trips <- matrix(nrow = length(file_paths), ncol = 6)
colnames(usable_trips) <- c("participant", "nrows", "usable_rows", "percent_usable_data", "total_trips", "actual_trips")
```
<br />   

Th next lines of code contain a for loop that loops through all of the participant data file paths stored in the variable `file_paths`. First, the loop uses the `substr()` function to extract only the participant name from the file path, and assigns it to the first column of the `usable_trips` matrix. The loop then passes the participant data file to the `GMU_commute()` function and assigns the output to the variable `list_output`. 

> Note: we are specifying the "overall summary" output from the `GMU_commute()` function. 

Next, `list_output` is unlisted using `unlist()`, and assigned to the 2nd, 2rd, 4th, 5th, and 6th columns of the `usable_trips` matrix. Once the loop has finished looping through all participant GPS data files, we use the function `kable` from the `knitr` package to generate a simple table of the now filled `usable_trips` matrix. 
```
for (i in seq_along(file_paths)){
      usable_trips[i, 1] <- substr(file_paths[i], start =51, stop = 56)
      list_ouput <- GMU_commute(file = file_paths[[i]], output = "overall summary")
      usable_trips[i, c(2,3,4,5,6)] <- unlist(list_ouput)
}
knitr::kable(usable_trips, "simple")
```

Use the following lines to save the matrix `usable_trips` as a dataframe to local disk:
```
usable_trips <- data.frame(usable_trips)
save(usable_trips, file = "usable_trips.Rdata")
```