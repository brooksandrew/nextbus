###################################################
## idBuses ########################################
## This script finds unique buses.
##################################################
idBuses <- function(df, busvar='VehicleID', timevar='time', predvar='Minutes', wordy=F) {

  ### Find bus departures and arrivals
  df <- df[order(df[,busvar], df[,timevar]), ]
  df$difftime[2:nrow(df)] <- difftime(df[2:nrow(df), timevar], df[1:(nrow(df)-1), timevar], units='secs')
  df$diffminutes[2:nrow(df)] <- (df[2:nrow(df), predvar] - df[1:(nrow(df)-1),predvar])
  df$predtime <- df[,timevar] + df[,predvar]*60
  df$diffpredtime <- c(difftime(df$predtime[2:nrow(df)], df$predtime[1:(nrow(df)-1)])/60, NA)
  df[,paste(busvar, '.f1', sep='')] <- c(df[2:nrow(df), busvar], NA)
  df$arrival <- ifelse(df[,predvar]==0 & (df$diffpredtime>15 | df[,paste(busvar, '.f1', sep='')]!=df[,busvar]), 1, 0)
  df$departure <- c(0, df$arrival[1:(nrow(df)-1)])
  
  ## id buses
  df$tripID <- as.numeric(factor(cut(1:nrow(df), breaks=c(1, which(df$arrival==1),nrow(df)), include.lowest=T, right=T)))
  
  ## reminder of what variables mean
  if(wordy==T){
     print('difftime:        simply the change in prediction (# of minutes from one vintage to the next)')
     print('predtime:        is the estimated arrival time of the bus from the current prediction')
     print('diffpredtime:    change (in minutes) in estimated arrival time of bus from (t+1) to t')
     print(paste(busvar, '.f1', ':    VehicleID of the bus one row ahead.', sep=''))
     print('arrival:      1 if bus is arriving in this period, 0 otherwise')
     print('departure:    1 if bus is departing station in this period, 0 otherwise')
   }
  
  return(df)
}



## Example

if(1==0){
  setwd('C:/Users/ANDREW/Documents/github/nextbus/data/')
  a <- read.delim('bus64_12mar2014_7am.txt', sep='|', header=T, stringsAsFactors=F)
  a$time <- as.POSIXct(a$time)
  
  dfd <- idBuses(a, wordy=T)
  
  plot(dfd$predtime, col=dfd$VehicleID)
  plot(dfd$predtime, col=dfd$tripID)
  plot(dfd$Minutes, col=dfd$VehicleID, pch=ifelse(dfd$arrival==1 | dfd$departure==1, 19,3))
  plot(dfd$Minutes, col=dfd$VehicleID, pch=ifelse(dfd$arrival==1 | dfd$departure==1, 19,3)) #col=ifelse(dfd$arrival==1, 2,1)
}


##########################################################################
## cleanBusData ##########################################################
## This function cleans the bus data created with the idBuses function
## above.  It deletes trips with less than 10 (or x) predictions.
##########################################################################

cleanBusData <- function(df, minpredcount=10) {
  agg <- aggregate(time~tripID, df, 'length')
  names(agg) <- c('tripID', 'predcount')
  df <- merge(df, agg, by='tripID', all=T)
  df <- df[df$predcount > minpredcount, ]
  return(df)
}

## Example
if(1==0) {
  setwd('C:/Users/ANDREW/Documents/github/nextbus/data/')
  a <- read.delim('bus64_12mar2014_7am.txt', sep='|', header=T, stringsAsFactors=F)
  a$time <- as.POSIXct(a$time)
  
  dfd <- idBuses(a, wordy=T)
  dfd <- cleanBusData(dfd)
}

##########################################################################
## validatePred ##########################################################
##This script validates the predictions of nextbus.  It returns how late or early
## each bus is at a particular time away on average.  For example, when nextbus says
## 5 mins how late is nextbus on average
##########################################################################

validatePred <- function(df, min=5, id='tripID', arrival='arrival', predtime='predtime', pred='Minutes', time='time') {
  errorBegin <- c()
  errorEnd <- c()
  errorAvg <- c()
  for(i in unique(df[df[,pred]==min,id])){
    err <- (df[df[,arrival]==1 & df[,id]==i, time] - df[df[,pred]==min & df[,id]==i, predtime])/60
    errorBegin <- c(errorBegin, err[1])
    errorEnd <- c(errorEnd, err[length(err)])
    errorAvg <- c(errorAvg, mean(err, na.rm=T))
    #print(paste(length(errorBegin),length(errorEnd),length(errorAvg)))
  }
  
  errordf <- data.frame(errorBegin=errorEnd, errorBegin=errorBegin, errorAvg=errorAvg)
  
  return(errordf)
  
}


