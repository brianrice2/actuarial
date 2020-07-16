# load packages
library(dplyr)
library(gdata)
library(zoo)
library(shiny)

download_and_clean <- function(url) {
  # download.file(url, destfile='file.xls')
  data <- read.xls(url, header = TRUE, blank.lines.skip = TRUE, na.strings = c("", "NA"))
  data <- data[-c(0:1), ]
  data <- Filter(function(x)!all(is.na(x)), data)
  
  # clean up data and rename columns
  data <- as.data.frame(t(data))
  colnames(data)[0] <- 'index'
  colnames(data)[1] <- 'Year'
  colnames(data)[2] <- 'Month'
  
  # duration time frames
  colnames(data)[3:202] <- sprintf("%s", seq(from=0.5, to=100, by=0.5))
  
  data <- data[-1, ]
  data$Month <- match(data$Month, month.abb)
  data[] <- lapply(data, function(x) as.numeric(as.character(x)))
  data$Year <- zoo::na.locf(data$Year)
  data$Date <- as.Date(paste(data$Year, data$Month, '1', sep='-'), '%Y-%m-%d')
  rownames(data) <- data$Date
  data$Date <- format(data$Date, '%b %Y')
  
  return(data)
}

compile_historical_rates <- function() {
  data <- download_and_clean('http://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/hqm_19_23.xls')
  
  # add historical data from treasury website
  years_data <- list(list('84', '88'), list('89', '93'), list('94', '98'), list('99', '03'),
                     list('04', '08'), list('09', '13'), list('14', '18'))
  
  for (pair in years_data) {
    data_old <- download_and_clean(paste('http://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/hqm_', pair[1], '_', pair[2], '.xls', sep=''))
    data <- rbind(data, data_old)
  }
  
  # sort by year then month
  data <- data[order(data$Year, data$Month), ]
  
  return(data)
}
