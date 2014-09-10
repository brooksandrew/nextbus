rm(list=ls())

df1 <- read.delim('/Users/ajb/Documents/github/nextbus/data/bus64_4Aug2014.txt', sep='|', header=T, stringsAsFactors=F)
df2 <- read.delim('/Users/ajb/Documents/github/nextbus/data/bus64_8Aug2014.txt', sep='|', header=T, stringsAsFactors=F)
df2 <- df2[1:nrow(df2)-1, ]

## combining datasets
df <- rbind(df1, df2)

## some pre-processing
df$time <- as.POSIXct(df$time, origin='EST')
df$hour <- as.numeric(strftime(df$time, '%H'))

## creating unique key for bus trips
df$TripID <- as.character(df$TripID)
df$ID <- paste(df$TripID, df$VehicleID, sep="_")
df <- df[order(df$ID, df$time),]

## marking arrival and departure dates for Trips
depart <- by(df$time, df$ID, min)
arrive <- by(df$time, df$ID, max)
df$departure <- 0; df$arrival <- 0; df$est <- 0
for(i in 1:nrow(depart)-1) {
  tname <- names(depart)[i]
  df$departure[df$ID==tname & df$time==depart[i]] <- 1
  df$arrival[df$ID==tname & df$time==arrive[i]] <- 1
}

# removing buses that never arrive 
TripsThatArrive <- df$ID[df$arrival==1 & df$Minutes==0]
df <- df[df$ID %in% TripsThatArrive,]

# finding actual arrival times
df$est <- 0
for(i in 1:nrow(depart)) {
  tname <- names(depart)[i]
  df$est[df$ID==tname] <- (df$time[df$ID==tname & df$arrival==1] - df$time[df$ID==tname])/60
}

# finding prediction errors
df$err <- df$est - df$Minutes

# keeping just estimates every nth prediction when time between predictions is less than 30 seconds
df$timediff[2:nrow(df)] <- df$time[2:nrow(df)] - df$time[1:(nrow(df)-1)]
df$timediff[is.na(df$timediff)] <- 0
n <- 10
df$timediffSample[df$timediff<30] <- rep(1:n, length.out=sum(df$timediff<30))
df$timediffSample[is.na(df$timediffSample)] <- 0

## quick fix for trips with repeated Trip IDs... need to properly fix this later
df <- df[df$est<1000,]

#checking plot
with(df, plot(time, Minutes, col=factor(df$ID)))
df2 <- df[df$time<as.POSIXct('2014-08-05 22:00:00 EDT'),]
colfunc <- colorRampPalette(c("green", "white" "red"))
lateness <- df2$Minutes-df2$est
plot(df2$time, df2$Minutes, col=colfunc(30)[findInterval(lateness, seq(min(lateness), max(lateness), length.out=30))])

# analyzing results
plot(df$time[df$Minutes==13], df$est[df$Minutes==13], col=factor(df$ID[df$Minutes==13]), pch=19)
hist(df$est[df$Minutes==5])
mean(df$est[df$Minutes==5])

#what about at rush hour?
hist(df$est[df$Minutes==5 & df$hour<=9 & df$hour>=7])
mean(df$est[df$Minutes==5 & df$hour<=19 & df$hour>=15])

# aggregate results
estMean <- aggregate(est~Minutes, df, 'mean')
estMedian <- aggregate(est~Minutes, df, 'median')
estq <- data.frame(as.matrix(aggregate(est~Minutes, df, function(x) quantile(x, seq(0,1,.1)))))

# plots - confidence
plot(estMean[,2]-estMean[,1], xlab='prediction', ylab='error')
plot(estq$est.10.-estq[,1], xlab='prediction', ylab='error')
plot(estq$est.50.-estq[,1], xlab='prediction', ylab='error')
plot(estq$est.90.-estq[,1], xlab='prediction', ylab='error')

plot(df$Minutes[df$est<100], df$est[df$est<100])
require('hexbin')
plot(hexbin(df$Minutes[df$est<100], df$est[df$est<100], xbins=50), xlab='Prediction', ylab='Actual minutes until arrival')

## test plot - confidence intervals
plot(estq$est.10.-estq[,1], xlab='prediction', ylab='error', 
     ylim =c(-2, max(max(estq$est.10-estq[,1], estq$est.70.-estq[,1]))))
points(estq$est.70.-estq[,1])

## outputting data to JSON... again
require('RJSONIO')
a<-toJSON(df)
write.table(a, file='/Users/ajb/Documents/github/nextbus/data/cleanTrips.json')
write.table(df, file='/Users/ajb/Documents/github/nextbus/data/cleanTrips.csv', row.names=F, sep=',')
write.table(df[df$timediffSample<=1, c('err', 'Minutes', 'time')], file='/Users/ajb/Documents/github/nextbus/data/cleanTrips_d3scatter.csv', row.names=F, sep=',')
write.table(df[df$time<quantile(df$time, 0.1),], file='/Users/ajb/Documents/github/nextbus/data/cleanTrips_small.csv', row.names=F, sep=',')

