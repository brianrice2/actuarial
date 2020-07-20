#' Returns treasury rates for the given duration
#' Available columns to pull:
#'     1 mo, 2 mo, 3 mo, 6 mo,
#'     1 yr, 2 yr, 3 yr, 5 yr,
#'     7 yr, 10 yr, 20 yr, 30 yr
#' Data is generally updated at the end of each business day
#'
#' @param year The calendar year to pull results for
#' @param column_of_interest The duration of rates to pull info on
#' @export
scrape_treasury_rates <- function(year, column_of_interest) {
  # load in html
  url <- paste("https://www.treasury.gov/resource-center/data-chart-center/interest-rates/Pages/TextView.aspx?data=yieldYear&year=",
               year, sep = "")
  url <- url(url, "rb")
  webpage <- xml2::read_html(url)
  on.exit(close(url)) # close any url connections when exiting the function

  # find the table we want
  tbls_ls <- webpage %>%
    rvest::html_nodes("table") %>% # returns a list of lists
    .[2] %>% # is there an easier way to select the right table?
    rvest::html_table(fill = TRUE)

  # manipulate the data a bit
  rates_data <- tbls_ls[[1]]
  rates_data$date <- as.Date(rates_data$Date, format = "%m/%d/%y")
  rates_data$month <- factor(months(rates_data$date), levels = month.name)

  # when was the data last updated?
  last_updated <- format(tail(rates_data$date, 1), "%B %d, %Y")

  # summarize by monthly average
  avg_monthly_rates <- aggregate(dplyr::select(rates_data, column_of_interest),
                                 list(rates_data$month),
                                 mean)
  avg_monthly_rates[, 2] <- format(avg_monthly_rates[, 2], digits = 3, format = "f")
  colnames(avg_monthly_rates) <- c("month", paste(column_of_interest, "rate"))


  cat(paste("Rates as of", last_updated, "\n\n"))
  return(avg_monthly_rates)
}
