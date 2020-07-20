#' Returns stabilized and nonstabilized segment rates for any year
#'
#' @importFrom magrittr %>%
#' @export
scrape_rates <- function() {
  # compile_historical_rates() scrapes and cleans the data for us
  data <- compile_historical_rates()

  # limit scope to be the current year at latest
  # i.e., no future years - they would all be N/A anyways (no info yet)
  data <- data[data$year <= as.integer(format(Sys.Date(), "%Y")), ]
  data <- data[order(data$year, data$month), ]

  # derive stabilized and non-stabilized rates
  data <- data %>%
    dplyr::mutate(PBGC_1 = format(round(rowMeans(data[, 4:13], na.rm = TRUE), 2), nsmall = 2),
                  PBGC_2 = format(round(rowMeans(data[, 14:43], na.rm = TRUE), 2), nsmall = 2),
                  PBGC_3 = format(round(rowMeans(data[, 44:123], na.rm = TRUE), 2), nsmall = 2),
                  segment_1 = format(round(zoo::rollapplyr(rowMeans(data[, 4:13], na.rm = TRUE),
                                                           width = 24, FUN = mean, partial = TRUE), 2), nsmall = 2),
                  segment_2 = format(round(zoo::rollapplyr(rowMeans(data[, 14:43], na.rm = TRUE),
                                                           width = 24, FUN = mean, partial = TRUE), 2), nsmall = 2),
                  segment_3 = format(round(zoo::rollapplyr(rowMeans(data[, 44:123], na.rm = TRUE),
                                                           width = 24, FUN = mean, partial = TRUE), 2), nsmall = 2))

  # offset by 1 month
  data$segment_1 <- lag(data$segment_1, 1)
  data$segment_2 <- lag(data$segment_2, 1)
  data$segment_3 <- lag(data$segment_3, 1)

  # return just the months and segment rates
  res <- data %>% dplyr::select(1, 2, 3, tail(names(.), 7))
  res <- res[order(-res$year, res$month), ]
  rownames(res) <- res$date

  return(res[, c("month", "year", "date", "segment_1", "segment_2", "segment_3",
                 "PBGC_1", "PBGC_2", "PBGC_3")])
}
