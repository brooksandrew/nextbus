###################################################
## This script finds unique buses.
##################################################
idBuses <- function(df, busvar='VehicleID', timevar='time', predvar='Minutes', wordy=F) {

  ### Find bus departures and arrivals
  df <- df[order(df[,busvar], df[,timevar]), ]
  dfd$difftime[2:nrow(df)] <- difftime(df[2:nrow(df), timevar], df[1:(nrow(df)-1), timevar], units='secs')
  df$diffminutes[2:nrow(df)] <- (df[2:nrow(df), predvar] - df[1:(nrow(df)-1),predvar])
  df$predtime <- df[,timevar] + df[,predvar]*60
  df$diffpredtime <- c(difftime(df$predtime[2:nrow(df)], df$predtime[1:(nrow(df)-1)])/60, NA)
  df[,paste(busvar, '.f1', sep='')] <- c(df[2:nrow(df), busvar], NA)
  df$arrival <- ifelse(df[,predvar]==0 & (df$diffpredtime>15 | df$VehicleID.f1!=df$VehicleID), 1, 0)
  df$departure <- c(0, df$arrival[1:(nrow(df)-1)])
  
  ## id buses
  df$busID <- cut(1:nrow(df), breaks=which(df$arrival==1), include.lowest=T, right=T)
  
  ## remdinder of what variables mean
  if(wordy==T){
    print('difftime:        simply the change in prediction (# of minutes from one vintage to the next)')
    print('predtime:        is the estimated arrival time of the bus from the current prediction')
    print('diffpredtime:    change (in minutes) in estimated arrival time of bus from (t+1) to t')
    print(paste(busvar, '.f1', ':    VehicleID of the bus one row ahead', sep=''))
    print('arrival:         1 if bus is arriving in this period, 0 otherwise')
    print('departure:       1 if bus is departing station in this period, 0 otherwise')
  }
  
  return(df)
}

if(1==0){
  setwd('C:/Users/ANDREW/Documents/github/nextbus/data/')
  a <- read.delim('bus64_12mar2014_7am.txt', sep='|', header=T, stringsAsFactors=F)
  a$time <- as.POSIXct(a$time)
  
  dfd <- idBuses(a, wordy=T)
  
  plot(dfd$predtime, col=dfd$VehicleID)
  plot(dfd$predtime, col=dfd$busID)
  plot(dfd$Minutes, col=dfd$VehicleID, pch=ifelse(dfd$arrival==1 | dfd$departure==1, 19,3)) #col=ifelse(dfd$arrival==1, 2,1)
    
}









