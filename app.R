# load packages
library(tidyverse)
library(gdata)
library(zoo)
library(shiny)

scrape_rates <- function() {
  #' Returns stabilized and nonstabilized segment rates for any year

  # compile_historical_rates.R scrapes and cleans the data for us
  source("./compile_historical_rates.R")
  data <- compile_historical_rates()

  # limit scope to be the current year at latest
  # i.e., no future years - they would all be N/A anyways (no info yet)
  data <- data[data$year <= as.integer(format(Sys.Date(), "%Y")), ]
  data <- data[order(data$year, data$month), ]

  # derive stabilized and non-stabilized rates
  data <- data %>% 
    mutate(PBGC_1 = format(round(rowMeans(data[, 4:13], na.rm = TRUE), 2), nsmall = 2),
           PBGC_2 = format(round(rowMeans(data[, 14:43], na.rm = TRUE), 2), nsmall = 2),
           PBGC_3 = format(round(rowMeans(data[, 44:123], na.rm = TRUE), 2), nsmall = 2),
           segment_1 = format(round(rollapplyr(rowMeans(data[, 4:13], na.rm = TRUE),
                                               width = 24, FUN = mean, partial = TRUE), 2), nsmall = 2),
           segment_2 = format(round(rollapplyr(rowMeans(data[, 14:43], na.rm = TRUE),
                                               width = 24, FUN = mean, partial = TRUE), 2), nsmall = 2),
           segment_3 = format(round(rollapplyr(rowMeans(data[, 44:123], na.rm = TRUE),
                                               width = 24, FUN = mean, partial = TRUE), 2), nsmall = 2))

  # offset by 1 month
  data$segment_1 <- lag(data$segment_1, 1)
  data$segment_2 <- lag(data$segment_2, 1)
  data$segment_3 <- lag(data$segment_3, 1)

  # return just the months and segment rates
  res <- data %>% select(1, 2, 3, tail(names(.), 7))
  res <- res[order(-res$year, res$month), ]
  rownames(res) <- res$date

  return(res[, c("month", "year", "date", "segment_1", "segment_2", "segment_3",
                 "PBGC_1", "PBGC_2", "PBGC_3")])
}

df <- scrape_rates()
rownames(df) <- df$date
df <- df[order(-df$year, df$month), ]

# remove some unnecessary whitespace on the entries
df <- trim(df)

# prevent us from seeing lots of NaN entries if we're not very far into the year
df <- df[df$segment_1 != "NaN", ]
df[df == "NaN"] <- "-"

# underlying data connection for the shiny server
server <- function(input, output, session) {
  # filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- df

    # filter table by month
    if (input$month != "All") {
      data <- data[data$month == input$month, ]
    }

    # filter table by year
    if (input$year != "All") {
      data <- data[data$year == input$year, ]
    }
    data
  }, 
  options = list(pageLength = 12,
                 columnDefs = list(list(visible = FALSE, targets = c(1, 2, 3)))
                 )
  ))
}

# user interface for the shiny server
ui <- fluidPage(
  titlePanel("Funding Yield Curve Segment Rates"),

  # create a new row in the UI for selectInputs (dropdowns)
  fluidRow(
    # dropdown for month
    column(4, selectInput("month", "month:",
                          c("All", unique(as.character(df$month))))),

    # dropdown for year
    column(4, selectInput("year", "year:",
                          c("All", unique(as.character(df$year)))))),

  # add the data table to the interface
  DT::dataTableOutput("table")
)

# create the server
shinyApp(ui = ui, server = server)
