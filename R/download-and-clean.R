#' Download and clean interest rates
#' For use with compile_historical_rates
#'
#' @param url The URL from which to download the interest rate data
#' @return A dataframe of monthly interest rates
download_and_clean <- function(url) {
  data <- gdata::read.xls(url, header = TRUE, blank.lines.skip = TRUE, na.strings = c("", "NA"))
  data <- data[-c(0:1), ]
  data <- Filter(function(x)!all(is.na(x)), data)

  # clean up data and rename columns
  data <- as.data.frame(t(data))
  colnames(data)[0] <- "index"
  colnames(data)[1:2] <- c("year", "month")

  # duration time frames
  colnames(data)[3:202] <- sprintf("%s", seq(from = 0.5, to = 100, by = 0.5))

  data <- data[-1, ] # drop the first row only
  data$month <- match(data$month, month.abb)
  data[] <- lapply(data, function(x) as.numeric(as.character(x)))
  data$year <- zoo::na.locf(data$year)
  data$date <- as.Date(paste(data$year, data$month, "1", sep = "-"), "%Y-%m-%d")
  rownames(data) <- data$date
  data$date <- format(data$date, "%b %Y")

  return(data)
}
