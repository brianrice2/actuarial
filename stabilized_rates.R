# load packages
library('tidyverse')
library('gdata')
library('zoo')

scrape_stabilized_rates <- function(year=2019) {
  #' Returns stabilized segment rates for the given year
  #' @param year The calendar year to pull results for
  
  # helper function - download file and perform necessary cleaning
  download_and_clean <- function(url) {
    download.file(url, destfile='file.xls')
    data <- read.xls('file.xls', header=TRUE, blank.lines.skip=TRUE, na.strings=c("", "NA"))
    data <- data[-c(0:1), ]
    data <- Filter(function(x)!all(is.na(x)), data)
    
    # clean up data and rename columns
    data <- as.data.frame(t(data))
    colnames(data)[0] <- 'index'
    colnames(data)[1] <- 'Year'
    colnames(data)[2] <- 'Month'
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
  
  data <- download_and_clean('https://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/hqm_19_23.xls')
  
  # add historical data from treasury website
  years_data <- list(list('84', '88'), list('89', '93'), list('94', '98'), list('99', '03'),
                     list('04', '08'), list('09', '13'), list('14', '18'))
  
  for (pair in years_data) {
    data_old <- download_and_clean(paste('https://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/hqm_', pair[1], '_', pair[2], '.xls', sep=''))
    data <- rbind(data, data_old)
  }
  
  data <- data[data$Year <= 2019, ]
  data <- data[order(data$Year, data$Month), ]
  
  # find segment rates
  data$`1st segment` <- round(rollapplyr(rowMeans(data[, 3:12], na.rm=TRUE), width=24, FUN=mean, partial=TRUE), 2)
  data$`2nd segment` <- round(rollapplyr(rowMeans(data[, 13:42], na.rm=TRUE), width=24, FUN=mean, partial=TRUE), 2)
  data$`3rd segment` <- round(rollapplyr(rowMeans(data[, 43:122], na.rm=TRUE), width=24, FUN=mean, partial=TRUE), 2)
  
  # data$`1st segment` <- format(data$`1st segment`, nsmall=2)
  # data$`2nd segment` <- format(data$`2nd segment`, nsmall=2)
  # data$`3rd segment` <- format(data$`3rd segment`, nsmall=2)
  
  # offset by 1 month
  data$`1st segment` <- lag(data$`1st segment`, 1)
  data$`2nd segment` <- lag(data$`2nd segment`, 1)
  data$`3rd segment` <- lag(data$`3rd segment`, 1)
  
  # return just the months and segment rates
  res = data %>% select(1, 2, tail(names(.), 4))
  res <- res[order(-res$Year, res$Month), ]
  rownames(res) <- res$Date
  return(res[which(res$Year==year), c('1st segment','2nd segment','3rd segment')])
}

scrape_stabilized_rates(year=2019)
