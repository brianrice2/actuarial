# load dependencies
library(rvest)
library(lubridate)
library(dplyr)

scrape_rates <- function(year, column_of_interest) {
  #' Returns treasury rates for the given duration
  #' Available columns to pull:
  #'     1 mo, 2 mo, 3 mo, 6 mo,
  #'     1 yr, 2 yr, 3 yr, 5 yr,
  #'     7 yr, 10 yr, 20 yr, 30 yr
  #' Data is generally updated at the end of each business day
  #' @param year The calendar year to pull results for
  #' @param column_of_interest The duration of rates to pull info on
  # load in html
  url <- paste("https://www.treasury.gov/resource-center/data-chart-center/interest-rates/Pages/TextView.aspx?data=yieldYear&year=",
               year, sep = "")
  webpage <- read_html(url)

  # find the table we want
  tbls <- html_nodes(webpage, "table")
  tbls_ls <- webpage %>% 
    html_nodes("table") %>% 
    .[2] %>% 
    html_table(fill = TRUE)

  # manipulate the data a bit
  rates_data <- tbls_ls[[1]]
  rates_data$date <- as.Date(rates_data$date, format = "%m/%d/%y")
  rates_data$month <- months(rates_data$date)
  rates_data$month <- factor(rates_data$month, levels = month.name)

  # when was the data last updated?
  last_updated <- format(tail(rates_data$date, 1), "%B %d, %Y")

  # summarize by monthly average
  avg_monthly_rates <- aggregate(select(rates_data, column_of_interest),
                                 list(rates_data$month),
                                 mean)
  avg_monthly_rates[, 2] <- format(avg_monthly_rates[, 2], digits = 3, format = "f")
  colnames(avg_monthly_rates) <- c("month", paste(column_of_interest, "rate"))

  # close url connection and return our info
  closeAllConnections()
  cat(paste("Rates as of", last_updated, "\n\n"))
  return(avg_monthly_rates)
}

scrape_rates(2019, "30 yr")
