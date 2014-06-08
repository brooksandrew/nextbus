rm(list=ls())
source('C:/Users/ANDREW/Documents/github/nextbus/code/idBuses.R')

dfb <- read.delim('C:/Users/ANDREW/Documents/github/nextbus/data/bus64_15mar2014_9am_marathon.txt', sep='|', header=T, stringsAsFactors=F)
dfb$time <- as.POSIXct(dfb$time, origin='EST')

## Finding Arrivals, Departures and trip
df <- idBuses(dfb)

## plotting to validate 
plot(df$predtime, col=df$VehicleID)
plot(df$predtime, col=df$tripID)
plot(df$Minutes, col=df$VehicleID, pch=ifelse(df$arrival==1 | df$departure==1, 19,3))
plot(df$Minutes, col=df$tripID, pch=ifelse(df$arrival==1 | df$departure==1, 19,3))

## clean bus data
dfc <- cleanBusData(df, minpredcount=10)
plot(dfc$Minutes, col=dfc$VehicleID, pch=ifelse(dfc$arrival==1 | dfc$departure==1, 19,3))
plot(dfc$Minutes, col=dfc$tripID, pch=ifelse(dfc$arrival==1 | dfc$departure==1, 19,3))

## assessing errors.
errdf <- validatePred(dfc, min=10)
mean(errdf[,1], na.rm=T)
mean(errdf[,2], na.rm=T)
mean(errdf[,3], na.rm=T)



  
  
