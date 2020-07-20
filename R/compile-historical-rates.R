#' Aggregate historical interest rate data
#' For use with scrape_rates
#'
#' @return A dataframe of monthly interest rates for all available years
compile_historical_rates <- function() {
  data <- download_and_clean("http://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/hqm_19_23.xls")

  # add historical data from treasury website
  years_data <- list(list("84", "88"), list("89", "93"),
                     list("94", "98"), list("99", "03"),
                     list("04", "08"), list("09", "13"), list("14", "18"))

  for (pair in years_data) {
    data_old <- download_and_clean(paste("http://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/hqm_",
                                         pair[1], "_", pair[2], ".xls", sep = ""))

    # attach to existing dataframe
    data <- rbind(data, data_old)
  }

  # sort by year then month
  data <- data[order(data$year, data$month), ]

  return(data)
}
