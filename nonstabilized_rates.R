# load packages
library('tidyverse')
library('gdata')

scrape_nonstabilized_rates <- function(year=2019) {
  #' Returns nonstabilized segment rates for the given year
  #' @param year The calendar year to pull results for
  # pull the corporate bond rates from the IRS website
  url <- 'https://www.irs.gov/pub/irs-tege/recent_corporate_bond_yield_curve_spot_rates.xls'
  download.file(url, destfile='file.xls')
  data <- read.xls('file.xls', header=TRUE, blank.lines.skip=TRUE, na.strings=c("", "NA"))
  data <- data[-c(0:4), ]
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
  data$Month[is.na(data$Month)] <- 8
  data$Date <- as.Date(paste(data$Year, data$Month, '1', sep='-'), '%Y-%m-%d')
  rownames(data) <- data$Date
  data$Date <- format(data$Date, '%b %Y')
  
  # find segment rates
  data$`1st segment` <- round(rowMeans(data[, 3:12], na.rm=TRUE), 2)
  data$`2nd segment` <- round(rowMeans(data[, 13:42], na.rm=TRUE), 2)
  data$`3rd segment` <- round(rowMeans(data[, 43:122], na.rm=TRUE), 2)
  
  # return just the months and segment rates
  res = data %>% select(1, 2, tail(names(.), 4))
  rownames(res) <- res$Date
  return(res[which(res$Year==year), c('1st segment','2nd segment','3rd segment')])
}

scrape_nonstabilized_rates(year=2019)
