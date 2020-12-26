# get AQI data for UK stations from www.aqi.info api 
# only ~300 stations so there should be  no need for delays as used in etlFindUKstations-4.R

# example for station 8070, Norfolk
# apiReq <- "http://api.waqi.info/feed/@8070/?token=67d23a5ad81a0557c4be19eb43dbc1d10eeaf947"
# aqiData <- fromJSON(txt = apiReq)
# aqiData   # displays all attributes in console, see references folder for details in JSONdownloadExplained.txt

library('tidyverse')
library('jsonlite')
library('httr')
library('lubridate')
library('sys')
library('purrr')

setwd('/home/jay/c3/citiesAQI/data/raw')
boxStations <- read.csv('ukAqiStationsOriginal.csv')
boxID <- list(select(boxStations, stationIDX))
stnReports <- data.frame('idx', 'dominant', 'humidity', 'no2', 'pressure', 'pm10', 'pm2-5', 'temp', 't-local', 't-zone', 't-univ', 't-iso', stringsAsFactors = FALSE)
goTime <- Sys.time() 










for (i in 1:length(boxID[[1]][[1]])) {
  waqiAccess <- paste0("http://api.waqi.info/feed/@", boxID[[1]][[1]][i], "/?token=67d23a5ad81a0557c4be19eb43dbc1d10eeaf947")
  try(APIreply <- fromJSON(txt = waqiAccess), silent = TRUE)
  if (APIreply$status == "ok") {
    print(APIreply$data$city$name)    
    try(stnReports[nrow(stnReports) + 1,] <- list(APIreply$data$idx, APIreply$data$dominentpol, APIreply$data$iaqi$h$v, APIreply$data$iaqi$no2$v, APIreply$data$iaqi$p$v, APIreply$data$iaqi$pm10$v, APIreply$data$iaqi$pm25$v, APIreply$data$iaqi$t$v, APIreply$data$time$s, APIreply$data$time$tz, APIreply$data$time$v, APIreply$data$time$iso), silent = TRUE)
  }
  Sys.sleep(0.1)
}



write_csv(stnReports, path = paste0("./", format(now(), "%Y%m%d_%H%M"), "aqiUKEire.csv"), na = 'NA', append = TRUE, col_names = FALSE)
print('csv saved')
stopTime <- Sys.time()
timeTaken <- stopTime - goTime
print(timeTaken)