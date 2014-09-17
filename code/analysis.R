rm(list=ls())
setwd('/Users/ajb/Documents/github/nextbus')

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

# finding actual prediction-to-arrival times
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
colfunc <- colorRampPalette(c("green", "white", "red"))
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
estq <- data.frame(as.matrix(aggregate(est~Minutes, df, function(x) quantile(x, seq(0,1,.05)))))

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
points(estq$est.50.-estq[,1], col='red')
segments(x0=0, y0=0, x1=100, y1=0, col='blue', lty=2)

## testplot - confidence intervals ggplot2
require('ggplot2')  
estq60 <- estq[estq$Minutes<=60,] 
colfunc <- colorRampPalette(c("pink", "firebrick"))
cols <- colfunc(4)

plt <- ggplot(estq60, aes(x= Minutes))
plt1 <- plt + 
  geom_ribbon(aes(ymin=est.5.-Minutes,  ymax=est.15.-Minutes), fill=cols[3]) + 
  geom_ribbon(aes(ymin=est.15.-Minutes,  ymax=est.25.-Minutes), fill=cols[2]) +
  geom_ribbon(aes(ymin=est.25.-Minutes,  ymax=est.50.-Minutes), fill=cols[1]) +
  geom_ribbon(aes(ymin=est.50.-Minutes,  ymax=est.75.-Minutes), fill=cols[1]) +
  geom_ribbon(aes(ymin=est.75.-Minutes,  ymax=est.85.-Minutes), fill=cols[2]) +
  geom_ribbon(aes(ymin=est.85.-Minutes,  ymax=est.95.-Minutes), fill=cols[3]) +
  geom_line(aes(y=est.50.-Minutes), col = "black", lwd = 1) +
  geom_line(aes(y=0), col = "black", lwd=0.5, linetype='dashed') +
  xlab("Prediction (minutes)") + ylab("Prediction error (minutes)") +
  scale_y_continuous(breaks=seq(floor(min(estq60$est.10.-estq60$Minutes)), ceiling(max(estq60$est.95.-estq60$Minutes)), 1)) + 
  scale_x_continuous(breaks=seq(0, 60, 10)) +
  geom_errorbar(data=estq[58,], aes(ymin=est.5.-Minutes, ymax=est.95.-Minutes), width=2, lwd=0.25) +
  geom_errorbar(data=estq[53,], aes(ymin=est.15.-Minutes, ymax=est.85.-Minutes), width=2, lwd=0.25) +
  geom_errorbar(data=estq[47,], aes(ymin=est.25.-Minutes, ymax=est.75.-Minutes), width=2, lwd=0.25) +
  annotate("text", label="50% confidence interval", x=47-1.5, y=estq60$est.65.[47]-estq60$Minutes[47], size=2.5, hjust=1) +
  annotate("text", label="70% confidence interval", x=53-1.5, y=estq60$est.80.[53]-estq60$Minutes[53], size=2.5, hjust=1) +
  annotate("text", label="90% confidence interval", x=58-1.5, y=estq60$est.90.[58]-estq60$Minutes[58], size=2.5, hjust=1) +
  annotate("text", label="Median", x=12+1, y=estq60$est.50.[12]-estq60$Minutes[12], size=3, hjust=0, fontface="bold")

plot(plt1)
ggsave(filename="plots/ggconf.png", plot=plt1)
ggsave(filename="/Users/ajb/Documents/github/simpleblog/assets/png/ggconf.png", plot=plt1, width=5, height=5, dpi=200) #temp

## std deviation for each minute
estvar <- data.frame(as.matrix(aggregate(err~Minutes, df, function(x) sqrt(var(x)))))
plot(estvar$err, pch=as.character(estvar$Minutes)) # simpleplot

plt2 <- ggplot(data=estvar[estvar$Minutes<=60,], aes(x=Minutes,y=err, label=Minutes)) +
          geom_text(aes(Minutes,err), size=3) +
          ylab("Standard deviation of prediction error") +
          xlab("Prediction (minutes)")

ggsave(filename="/Users/ajb/Documents/github/simpleblog/assets/png/ggstddev.png", plot=plt2, width=5, height=5, dpi=200) 


## outputting data to JSON... again
require('RJSONIO')
a<-toJSON(df)
write.table(a, file='/Users/ajb/Documents/github/nextbus/data/cleanTrips.json')
write.table(df, file='/Users/ajb/Documents/github/nextbus/data/cleanTrips.csv', row.names=F, sep=',')
write.table(df[df$timediffSample<=1, c('err', 'Minutes', 'time')], file='/Users/ajb/Documents/github/nextbus/data/cleanTrips_d3scatter.csv', row.names=F, sep=',')
write.table(df[df$time<quantile(df$time, 0.1),], file='/Users/ajb/Documents/github/nextbus/data/cleanTrips_small.csv', row.names=F, sep=',')

