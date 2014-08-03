findArrival <- function(df) {
  dfs <- df[order(df$TripID, df$Minutes),]
  dfs$dupe <- duplicated(paste(dfs$TripID, dfs$Minutes))
  dfs$Start <- ifelse(dfs$dupe==F & dfs$Minutes==0, 1, 0)
  return(dfs)
}


dfs <- findArrival(df)
plot(dfs$time, dfs$Minutes, col=ifelse(dfs$Start==1, 1, 2))
