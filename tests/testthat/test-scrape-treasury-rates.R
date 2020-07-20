test_that("URL structure is valid", {
  current_year <- format(Sys.Date(), "%Y")
  url <- paste("https://www.treasury.gov/resource-center/data-chart-center/interest-rates/Pages/TextView.aspx?data=yieldYear&year=",
               current_year, sep = "")

  # regexp = NA means *no* error is expected
  expect_error(xml2::read_html(url), regexp = NA)
})
