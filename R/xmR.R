#'Generate the XMR data for any time-series data.
#'@description Used to calculate XMR data. 
#'
#'@param df The dataframe or tibble to calculate from.
#'Data must be in a tidy format.
#'At least one variable for time and one variable for measure.
#'@param measure The column containing the measure. Must be in numeric format.
#'@param recalc Logical: if you'd like it to recalculate bounds. Defaults to True
#'@param reuse Logical: Should points be re-used in calculations? Defaults to False
#'@param interval The interval you'd like to use to calculate the averages. 
#'Defaults to 5.
#'@param longrun Used to determine rules for long run. First point is the 'n' of points used to recalculate with, and the second is to determine what qualifies as a long run. Default is c(5,8) which uses the first 5 points of a run of 8 to recalculate the bounds. If a single value is used, then that value is used twice i.e. c(6,6))
#'@param shortrun Used to determine rules for a short run. The first point is the minimum number of points within the set to qualify a shortrun, and the second is the length of a possible set. Default is c(3,4) which states that 3 of 4 points need to pass the test to be used in a calculation. If a single value is used, then that value is used twice i.e. c(3,3))
#'@param testing Logical to print test results
#'@examples
#'\donttest{
#'df <- xmr(df, "Measure", recalc = T)
#'}
#'\donttest{
#'df <- xmr(df, "Measure", recalc = T, shortrun = c(3,4), longrun = c(5,8))
#'}
#'@import dplyr
#'@import ggplot2
#'@import tidyr
#'@export xmr
xmr <- function(df, measure, recalc = T, reuse, interval, longrun, shortrun, testing) {
  
  . <- "NA"
  
  if(missing(measure)){
    measure <- names(df)[2]
    }
  
  if (missing(interval)){
    interval <- 5
    }
  if (missing(recalc)){
    recalc <- T
    }
  if (missing(testing)){
    testing <- F
    }
  if (missing(reuse)){
    reuse <- T
  }
  if (missing(longrun)){
    longrun <- c(5, 8)
  }
  if (missing(shortrun)){
    shortrun <- c(3, 4)
  }
  
  sr_length = length(shortrun)
  
  if(length(shortrun) == 1){
    shortrun <- c(shortrun, shortrun)
  }
  
  if(length(longrun) == 1){
    longrun <- c(longrun, longrun)
  }
  
  
  
  if (longrun[1] > longrun[2]){
    message("Invalid longrun argument. First digit must be less than or equal to the second.")
  }
  if (shortrun[1] > shortrun[2]){
    message("Invalid shortrun argument. First digit must be less than or equal to the second.")
  }

  round2 <- function(x, n) {
    posneg <- sign(x)
    z <- abs(x) * 10 ^ n
    z <-  z + 0.5
    z <-  trunc(z)
    z <-  z / 10 ^ n
    z * posneg
  }
  
  interval <- round2(interval, 0)
  df$Order <- seq(1, nrow(df), 1)
  points <- seq(1, interval, 1)
  #limits calculator
  limits <- function(df){
    df$`Lower Natural Process Limit` <-
      df$`Central Line` - (df$`Average Moving Range` * 2.66)
    df$`Lower Natural Process Limit`[1] <- NA
    df$`Lower Natural Process Limit` <-
      ifelse(df$`Lower Natural Process Limit` <= 0,
             0,
             df$`Lower Natural Process Limit`)
    df$`Upper Natural Process Limit` <-
      df$`Central Line` + (df$`Average Moving Range` * 2.66)
    df$`Upper Natural Process Limit`[1] <- NA
    return(df)
  }
  #starting conditions
  starter <- function(dat){
    original_cent <- mean(dat[[measure]][1:interval], na.rm = T)
    dat$`Central Line` <- original_cent
    #moving range
    dat$`Moving Range` <- abs(dat[[measure]] - dplyr::lag(dat[[measure]], 1))
    for (i in 1:(nrow(dat) - 1)) {
      dat$`Moving Range`[i + 1] <- abs(dat[[measure]][i] - dat[[measure]][i + 1])
    }
    dat$`Average Moving Range` <- mean(dat$`Moving Range`[2:(interval)], na.rm = T)
    dat$`Average Moving Range`[1] <- NA
    dat <- limits(dat)
    return(dat)
  }
  #testing for shortruns
  shortruns <- function(df, side, points){
    if (side == "upper"){
      df$Test <- NA
      df$Test <- ifelse(
        (abs(df[[measure]] - df$`Central Line`) >
           abs(df[[measure]] - df$`Upper Natural Process Limit`) &
           !(df$Order %in% points)
        ), "1", "0")
      return(df)
    }
    if (side == "lower"){
      df$Test <- NA
      df$Test <- ifelse(
        (abs(df[[measure]] - df$`Central Line`) >
          abs(df[[measure]] - df$`Lower Natural Process Limit`) &
          !(df$Order %in% points)
         ), "1", "0")
      return(df)
    }
  }
  
  if(sr_length == 1){
      
      #run subsetters
      shortrun_subset <- function(df, test, order, measure, points, int){
        int <- int
        subsets <- c()
        value <- "1"
        run <- shortrun[2]
        percentage <- run * (shortrun[1]/shortrun[2])
    
        for (i in int:nrow(df)){
          pnts <- i:(i + shortrun[1]-1)
          q <- df[[test]][df[[order]] %in% pnts]
          r <- as.data.frame(table(q))
          if (!any(is.na(q) == T) && (value %in% r$q)){
            if (r$Freq[r$q == value] >= percentage &&
               !(pnts %in% points)){
              subset <- df[df[[order]] %in% pnts, ]
              df <- df[!(df[[order]] %in% pnts), ]
              subsets <- rbind(subsets, subset)
            }
          }
        }
        return(subsets[1:(shortrun[2]), ])
      }
  
  } else {
      
      #run subsetters
      shortrun_subset <- function(df, test, order, measure, points, int){
        int <- int
        subsets <- c()
        value <- "1"
        run <- shortrun[2]
        percentage <- run * (shortrun[1]/shortrun[2])
        
        for (i in int:nrow(df)){
          pnts <- i:(i + shortrun[1])
          q <- df[[test]][df[[order]] %in% pnts]
          r <- as.data.frame(table(q))
          if (!any(is.na(q) == T) && (value %in% r$q)){
            if (r$Freq[r$q == value] >= percentage &&
                !(pnts %in% points)){
              subset <- df[df[[order]] %in% pnts, ]
              df <- df[!(df[[order]] %in% pnts), ]
              subsets <- rbind(subsets, subset)
            }
          }
        }
        return(subsets[1:(shortrun[2]), ])
      }
      
  }
  
  
  
  
  run_subset <- function(subset, order, df, type, side, points){
    if (missing(type)){
      type <- "long"
      }
    if (missing(subset)){
      subset <-  df
      }
    if (type == "long"){
    breaks <- c(0, which(diff(subset[[order]]) != 1), length(subset[[order]]))
    d <- sapply(seq(length(breaks) - 1),
                function(i) subset[[order]][(breaks[i] + 1):breaks[i + 1]])
    if (is.matrix(d)){
      d <- split(d, rep(1:ncol(d), each = nrow(d)))
      }
    if (length(d) > 1){
      rns <- c()
      idx <- c()
      for (i in 1:length(d)){
        a <- length(d[[i]])
        rns <- c(rns, a)
        idx <- c(idx, i)
      }
      runs <- data.frame(idx, rns)
      idx <- unique(runs$idx[runs$rns == max(runs$rns)])
      run <- d[idx]
      subset <- subset[subset[[order]] %in% run[[1]], ]
    }
    else {
      subset <- subset[subset[[order]] %in% d[[1]], ]
      }
    }
    if (type == "short" && side == "upper"){
      df <- shortruns(df, "upper", points)
      subset <- shortrun_subset(df, "Test", "Order", measure, points, interval)
    }
    if (type == "short" && side == "lower"){
      df_subset <- shortruns(df, "lower", points)
      subset <- shortrun_subset(df_subset, "Test", "Order", measure, points, interval)
    }
  return(subset)
  }
  #recalculator
  recalculator <- function(dat, subset, order, length, message, reuse){
    if (length == longrun[2]){
      int <- longrun[1]
      subset$Test <- 1
      } else if (length == shortrun[2]){
      int <- shortrun[2]
      }
    if (nrow(subset) >= length){
      start <- min(subset[[order]], na.rm = T)
      if (length == longrun[2]){
        end <- start + (int-1)
        }
      else if (length == shortrun[2]){
        end <- start + (int-1)
        }
      lastrow <- max(dat[[order]], na.rm = T)
       if (length == longrun[2]){
        new_cnt <- mean(subset[[measure]][1:int], na.rm = T)
        new_mv_rng <- subset$`Moving Range`[1:int]
        new_av_mv_rng <- mean(new_mv_rng, na.rm = T)
        dat$`Average Moving Range`[start:lastrow] <- new_av_mv_rng
        dat$`Central Line`[start:lastrow] <- new_cnt
        dat <- limits(dat)
        calcpoints <- start:end
        points <- c(points, calcpoints)
        assign("points", points, envir = parent.frame())
        assign("calcpoints", calcpoints, envir = parent.frame())
        return(dat)
      } else if (length == shortrun[2]){
        new_cnt <- mean(subset[[measure]][subset$Test == 1], na.rm = T)
        new_mv_rng <- subset$`Moving Range`[subset$Test == 1]
        new_av_mv_rng <- mean(new_mv_rng, na.rm = T)
        start <- min(subset[[order]][subset$Test == 1], na.rm = T)
        end <- max(subset[[order]][subset$Test == 1], na.rm = T)
        dat$`Average Moving Range`[start:lastrow] <- new_av_mv_rng
        dat$`Central Line`[start:lastrow] <- new_cnt
        dat <- limits(dat)
        calcpoints <- start:end
        if (reuse == F){
          points <- c(points, calcpoints)
          }
        assign("points", points, envir = parent.frame())
        assign("calcpoints", calcpoints, envir = parent.frame())
        return(dat)
      }

    } else {
      return(dat)
      }
  }
  #runs application
  runs <- function(dat, run = c("short", "long"), 
                   side = c("upper", "lower"), 
                   longrun, shortrun, calcpoints){
    if (run == "short"){
      l <- shortrun[2]
    } else if (run == "long"){
      l <- longrun[2]
    }
    #upper longruns
    if (side == "upper" && run == "long"){
       dat_sub <- dat %>%
        filter(., .[[measure]] > `Central Line` &
                 !(Order %in% points)) %>%
        arrange(., Order)
       dat_sub <- run_subset(dat_sub, "Order")
       rep <- nrow(dat_sub)
       while (rep >= l){
         mess <- paste0(run, ": ", side)
         dat <- recalculator(dat, dat_sub, "Order", l, mess, reuse)
         assign("points", points, envir = parent.frame())
         if (testing == T){
           print(mess)
           print(calcpoints)
         }
         dat_sub <- dat %>%
           filter(., .[[measure]] > `Central Line` & !(Order %in% points)) %>%
           arrange(., Order)
         dat_sub <- run_subset(dat_sub, "Order")
         rep <- nrow(dat_sub)
        }
    }
    #lower longruns
    else if (side == "lower" && run == "long"){
      dat_sub <- dat %>%
        filter(., .[[measure]] < `Central Line` &
                 #abs(.[[measure]] - `Central Line`) <
                 #abs(.[[measure]] - `Lower Natural Process Limit`) &
                 !(Order %in% points)) %>%
        arrange(., Order)
      dat_sub <- run_subset(dat_sub, "Order")
      rep <- nrow(dat_sub)
      while (rep >= l){
        mess <- paste0(run, ": ", side)
        dat <- recalculator(dat, dat_sub, "Order", l, mess, reuse)
        assign("points", points, envir = parent.frame())
        if (testing == T){
          print(mess)
          print(calcpoints)
        }
        dat_sub <- dat %>%
          filter(., .[[measure]] < `Central Line` & !(Order %in% points)) %>%
          arrange(., Order)
        dat_sub <- run_subset(dat_sub, "Order")
        rep <- nrow(dat_sub)
      }
    }
    #upper shortruns
    else if (side == "upper" && run == "short"){
      dat_sub <- run_subset(order = "Order",
                            df = dat,
                            type = "short",
                            side = "upper",
                            points = points)
      rep <- nrow(dat_sub)
      while (!is.null(rep) && !is.na(rep)){
        mess <- paste0(run, ": ", side)
        dat <- recalculator(dat, dat_sub, "Order", l, mess, reuse)
        assign("points", points, envir = parent.frame())
        if (testing == T){
          print(mess)
          print(calcpoints)
        }
        dat_sub <- run_subset(order = "Order",
                              df = dat,
                              type = "short",
                              side = "upper",
                              points = points)
        rep <- nrow(dat_sub)
      }
    }
    ##lower shortrun
    else if (side == "lower" && run == "short"){
      dat_sub <- run_subset(order = "Order",
                            df = dat,
                            type = "short",
                            side = "lower",
                            points = points)
      rep <- nrow(dat_sub)
      while (!is.null(rep) && !is.na(rep)){
        mess <- paste0(run, ": ", side)
        dat <- recalculator(dat, dat_sub, "Order", l, mess, reuse)
        assign("points", points, envir = parent.frame())
        if (testing == T){
          print(mess)
          print(calcpoints)
        }
        dat_sub <- run_subset(order = "Order",
                              df = dat,
                              type = "short",
                              side = "lower",
                              points = points)
        rep <- nrow(dat_sub)
      }
    }
    return(dat)
  }
  if ((nrow(df)) >= interval){
    #if no recalculation of limits is desired
    if (recalc == F){
      df <- starter(df)
      }
    #if recalculation of limits desired
    if (recalc == T){
    #calculate inital values
      df <- starter(df)
      df <- runs(df, "short", "upper", longrun, shortrun)
      df <- runs(df, "short", "lower", longrun, shortrun)
      df <- runs(df, "short", "upper", longrun, shortrun)
      df <- runs(df, "short", "lower", longrun, shortrun)
      df <- runs(df, "long", "upper", longrun, shortrun)
      df <- runs(df, "long", "lower", longrun, shortrun)
      df <- runs(df, "short", "upper", longrun, shortrun)
      df <- runs(df, "short", "lower", longrun, shortrun)
      df <- runs(df, "long", "upper", longrun, shortrun)
      df <- runs(df, "long", "lower", longrun, shortrun)
      df <- runs(df, "short", "upper", longrun, shortrun)
      df <- runs(df, "short", "lower", longrun, shortrun)
      df <- runs(df, "long", "upper", longrun, shortrun)
      df <- runs(df, "long", "lower", longrun, shortrun)
      df <- limits(df)
    }
    lastpoint <- max(df$Order)
    penpoint <- shortrun[1]-1
    df$`Central Line`[c((lastpoint - penpoint) : lastpoint)] <-
      df$`Central Line`[c(lastpoint - penpoint)]
    df$`Average Moving Range`[c((lastpoint - penpoint) : lastpoint)] <-
      df$`Average Moving Range`[c(lastpoint - penpoint)]
    df <- limits(df)
    
    
    #rounding
    df$`Central Line` <- round2(df$`Central Line`, 3)
    df$`Moving Range` <- round2(df$`Moving Range`, 3)
    df$`Average Moving Range` <- round2(df$`Average Moving Range`, 3)
    df$`Lower Natural Process Limit` <-
      round2(df$`Lower Natural Process Limit`, 3)
    df$`Upper Natural Process Limit` <-
      round2(df$`Upper Natural Process Limit`, 3)
  }
  if ((nrow(df)) < interval) {
    df$`Central Line` <- NA
    df$`Moving Range` <- NA
    df$`Average Moving Range` <- NA
    df$`Lower Natural Process Limit` <- NA
    df$`Upper Natural Process Limit` <- NA
  }
  return(df)
}