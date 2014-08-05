rm(list=ls())
source('/Users/ajb/Documents/github/nextbus/code/idBuses.R')

df <- read.delim('/Users/ajb/Documents/github/nextbus/data/bus64_1Aug2014.txt', sep='|', header=T, stringsAsFactors=F)

## some pre-processing
df$time <- as.POSIXct(df$time, origin='EST')
df$hour <- as.numeric(strftime(df$time, '%H'))

df$TripID <- as.character(df$TripID)
df <- df[order(df$TripID, df$time),]

## marking arrival and departure dates for Trips
depart <- by(df$time, df$TripID, min)
arrive <- by(df$time, df$TripID, max)
df$departure <- 0; df$arrival <- 0; df$est <- ß0
for(i in 1:nrow(depart)-1) {
  tname <- names(depart)[i]
  df$departure[df$TripID==tname & df$time==depart[i]] <- 1
  df$arrival[df$TripID==tname & df$time==arrive[i]] <- 1
}

# removing buses that never arrive 
TripsThatArrive <- df$TripID[df$arrival==1 & df$Minutes==0]
df <- df[df$TripID %in% TripsThatArrive,]

# finding actual arrival times
df$est <- 0
for(i in 1:nrow(depart)) {
  tname <- names(depart)[i]
  df$est[df$TripID==tname] <- (df$time[df$TripID==tname & df$arrival==1] - df$time[df$TripID==tname])/60
}

# analyzing results
plot(df$est[df$Minutes==5], col=df$TripID[df$Minutes==5], pch=19)
hist(df$est[df$Minutes==5])
mean(df$est[df$Minutes==5])




  
  
