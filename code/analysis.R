source('C:/Users/ANDREW/Documents/github/nextbus/code/idBuses.R')

dfb <- read.delim('C:/Users/ANDREW/Documents/github/nextbus/data/bus64_15mar2014_9am_marathon.txt', sep='|', header=T, stringsAsFactors=F)
dfb$time <- as.POSIXct(dfb$time, origin='EST')

df <- idBuses(dfb)

plot(df$predtime, col=df$VehicleID)
plot(df$predtime, col=df$busID)
plot(df$Minutes, col=df$VehicleID, pch=ifelse(df$arrival==1 | df$departure==1, 19,3))
plot(df$Minutes, col=df$busID, pch=ifelse(df$arrival==1 | df$departure==1, 19,3))




cleanBusData <- function(df, busvar='VehicleID', timevar='time', predvar='Minutes') {
  
}
