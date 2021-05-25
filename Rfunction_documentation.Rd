\name{GMU_commute}
\alias{GMU_commute}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Get usable GPS data
%%  ~~function to do ... ~~
}
\description{GMU_commute()  reads in a .csv file of GPS data and returns a user-specified output of the usable data contained in the GPS file. "Usable" data are defined by rows in which Longitude / Latitude locations are properly recorded (i.e. not 0), and trips that are longer than 5 minutes. GMU_commute() filters out rows based on the defined conditions for usbale data.  
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
GMU_commute(file, output)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{file}{The path to a GPS data file of .csv extension}
  \item{output}{A string that defines the function output specified by the user. Accepted values are "trip summary", "overall summary", or "df". The "trip summary" ouput returns the total number of rows (GPS data), the number of usable rows, and the percent usable data for each trip. The "overall summary" output returns the total number of rows, the number of usable rows, the percent usable data, the total number of trips, and the usable number of trips for each participant. Finally, the "df" output returns the subsetted dataframe, containing only usable GPS data.
}}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
  \item{trip summary }{A `tibble()` with columns: Trip, nrows, sum, and mean.}
  \item{overall summary }{A `tibble()` with columns: nrows, sum, mean, total_trips, actual_trips.}
  \item{overall summary }{A `data.frame()` containing only rows of usable data.}


}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}

\examples{
file <- here("GPS data/100100.csv") 
GMU_commute(file, output = "df")
GMU_commute(file, output = "trip summary"))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory (show via RShowDoc("KEYWORDS")):
% \keyword{ ~kwd1 }
% \keyword{ ~kwd2 }
% Use only one keyword per line.
% For non-standard keywords, use \concept instead of \keyword:
% \concept{ ~cpt1 }
% \concept{ ~cpt2 }
% Use only one concept per line.
