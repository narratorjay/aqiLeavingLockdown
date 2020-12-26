        # get AQI data for UK stations from www.aqi.info api 
        # only ~300 stations so there should be  no need for 16s delays as used in etlFindUKstations-4.R
        
        # example for station 8070, Norfolk
        # apiReq <- "http://api.waqi.info/feed/@8070/?token=67d23a5ad81a0557c4be19eb43dbc1d10eeaf947"
        # aqiData <- fromJSON(txt = apiReq)
        # see references folder for details in JSONdownloadExplained.txt
        
        library('tidyverse')
        library('jsonlite')
        library('httr')
        library('lubridate')
        library('sys')
        #library('purrr')
        
        fnNULLtoNA <- function(pollutantValue)
          if (is.null(pollutantValue)) {
            pollutantValue <- NA
          } else {
            pollutantValue <- pollutantValue
          }
        
          # print('pollutantValue', pollutantValue) # print does not work within a function
          return(pollutantValue)
        
        setwd('/home/jay/c3/citiesAQI/data/raw')
        boxStations <- read.csv('ukEireAqiStations.csv')
        boxID <- list(select(boxStations, stationIDX))
        
        for (islandRun in 1:40){
          stnReports <- data.frame('idx', 'humidity', 'pressure', 'temp', 'dominant', 'pm10', 'pm2-5', 'co', 'no2', 'o3', 'so2', 't-local', 't-zone', 't-univ', 't-iso', stringsAsFactors = FALSE)
          goTime <- Sys.time() 
          
          for (i in 1:length(boxID[[1]][[1]])) {
            waqiAccess <- paste0("http://api.waqi.info/feed/@", boxID[[1]][[1]][i], "/?token=67d23a5ad81a0557c4be19eb43dbc1d10eeaf947")
            try(APIreply <- fromJSON(txt = waqiAccess), silent = TRUE)
            if (APIreply$status == "ok") {
              print(paste(APIreply$data$city$name, "- station ID", APIreply$data$idx))   
              try(stnReports[nrow(stnReports) + 1,] <- list(APIreply$data$idx, APIreply$data$iaqi$h$v, APIreply$data$iaqi$p$v, APIreply$data$iaqi$t$v, APIreply$data$dominentpol, fnNULLtoNA(APIreply$data$iaqi$pm10$v), fnNULLtoNA(APIreply$data$iaqi$pm25$v), fnNULLtoNA(APIreply$data$iaqi$co$v), fnNULLtoNA(APIreply$data$iaqi$no2$v), fnNULLtoNA(APIreply$data$iaqi$o3$v), fnNULLtoNA(APIreply$data$iaqi$so2$v), APIreply$data$time$s, APIreply$data$time$tz, APIreply$data$time$v, APIreply$data$time$iso), silent = TRUE)
            }
            Sys.sleep(0.1)
          }
          
          write_csv(stnReports, path = paste0("./", format(now(), "%Y%m%d_%H%M"), "aqiUKEire.csv"), na = 'NA', append = TRUE, col_names = FALSE)
          print(paste('Saved csv', islandRun))
          stopTime <- Sys.time()
          timeTaken <- stopTime - goTime
          print(paste('Run', islandRun, 'took', sprintf("%.1f", timeTaken), 'minutes'))
          
          Sys.sleep(840)  # wait fourteen minutes, gives roughly half-hour intervals because it takes ~16 mins to get 308? stations data
        }