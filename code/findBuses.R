###################################################
## This script finds unique buses.
##################################################
a <- read.delim('C:/Users/ANDREW/Dropbox/wmata/bus64_12mar2014_7am.txt', sep='|', header=T, stringsAsFactors=F)
a$time <- as.POSIXct(a$time)

df <- a
busvar <- 'VehicleID'
timevar <- 'time'
predvar <- 'Minutes'

findArrivingBuses <- function(df, busvar, timevar, predvar) {
  ids <- unique(df[,busvar])
  
  ##differencing predictions
  for(i in ids){
    rowids <- which(df[,busvar]==i)
    df[rowids[2:length(rowids)], 'diffpred'] <- diff(df[rowids, predvar])
    df[rowids[2:length(rowids)], 'difftime'] <- difftime(df[rowids[2:length(rowids)], timevar], df[rowids[1:length(rowids)-1], timevar])
  }
  
  df$jumptime <- ifelse(abs(df$difftime)>60*1, 1, 0)
  df$jumppred_a <- ifelse(abs(df$diffpred)>2, 1, 0)
  
  ##arrival times
  df$arrival <- ifelse(df[,predvar]==0,1,0)
  
  arrivals <- data.frame(rows = which(df$arrival==1))
  arrivals$Minutes <- df$Minutes[arrivals$rows]
  arrivals$time <- df$time[arrivals$rows]
  
  arrivals$VehicleID <- df$VehicleID[arrivals$rows]
  arrivals$difftime <- NA
  arrivals$difftime[1:(nrow(arrivals)-1)] <- difftime(arrivals$time[2:nrow(arrivals)], arrivals$time[1:(nrow(arrivals)-1)], units='secs')
  arrivals$VehicleID.l1 <- NA
  arrivals$VehicleID.l1[2:nrow(arrivals)] <- arrivals$VehicleID[1:nrow(arrivals)-1]
  arrivals$arrived <- ifelse(arrivals$difftime>60*3 & arrivals$VehicleID==arrivals$VehicleID.l1, 1, 0)
  
  df$arrivalFinal <- 0
  df$arrivalFinal[arrivals$rows[arrivals$arrived==1]] <- 1 
  
  
  ### Find departing buses
  dfd <- a
  dfd <- a[order(a$VehicleID, a$time), ]
  dfd$difftime[2:nrow(dfd)] <- difftime(dfd$time[2:nrow(dfd)], dfd$time[1:(nrow(dfd)-1)], units='secs')
  dfd$diffminutes[2:nrow(dfd)] <- (dfd$Minutes[2:nrow(dfd)] - dfd$Minutes[1:(nrow(dfd)-1)])
  dfd$start <- ifelse(dfd$difftime>100 & dfd$diffminutes > 10, 1, 0)
  dd <- dfd$time[2:nrow(dfd)] - dfd$Minutes[1:(nrow(dfd)-1)]
  dfd$pred[2:nrow(dfd)] <- as.data.frame(as.POSIXct(dd))
}


if(1==0){
  df$arrivalF <- findBuses(df, 'VehicleID' , 'time', 'Minutes')
  table(df$arrivalF)
}


plot(dfd$Minutes, col=ifelse(dfd$start==1,2,1), pch=ifelse(dfd$start==1, 19, 3))




plot(a$Minutes, col=a$VehicleID)
plot(df$Minutes, col=df$jumppred_a+1, pch=ifelse(df$jumppred_a==1,1,21))
plot(df$Minutes, col=df$arrival+1, pch=ifelse(df$arrival==1,19,21))
plot(df$Minutes, col=ifelse(df$arrivalFinal==1,2,1), pch=ifelse(df$arrivalFinal==1, 19, 3))
with(df[df$VehicleID==7215,], plot(Minutes, col=arrival+1, pch=ifelse(arrival==1,19,21)))

cbind(df$difftime, df$diffpred)
