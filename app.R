# load packages
library('tidyverse')
library('gdata')
library('zoo')
library('shiny')

scrape_rates <- function(skip_download = TRUE) {
  #' Returns stabilized and nonstabilized segment rates for any year
  if (!skip_download) {
    source('./actuarial_download only.R')
  }
  data <- read.csv('rates_data.csv')
  data <- data[data$Year <= 2020, ]
  data <- data[order(data$Year, data$Month), ]
  
  # non-stabilized segment rates
  data$`1st segment (nonstabilized)` <- round(rowMeans(data[, 4:13], na.rm=TRUE), 2)
  data$`2nd segment (nonstabilized)` <- round(rowMeans(data[, 14:43], na.rm=TRUE), 2)
  data$`3rd segment (nonstabilized)` <- round(rowMeans(data[, 44:123], na.rm=TRUE), 2)
  
  # stabilized segment rates
  data$`1st segment` <- round(rollapplyr(rowMeans(data[, 4:13], na.rm=TRUE), width=24, FUN=mean, partial=TRUE), 2)
  data$`2nd segment` <- round(rollapplyr(rowMeans(data[, 14:43], na.rm=TRUE), width=24, FUN=mean, partial=TRUE), 2)
  data$`3rd segment` <- round(rollapplyr(rowMeans(data[, 44:123], na.rm=TRUE), width=24, FUN=mean, partial=TRUE), 2)
  
  data$`1st segment (nonstabilized)` <- format(data$`1st segment (nonstabilized)`, nsmall=2)
  data$`2nd segment (nonstabilized)` <- format(data$`2nd segment (nonstabilized)`, nsmall=2)
  data$`3rd segment (nonstabilized)` <- format(data$`3rd segment (nonstabilized)`, nsmall=2)

  data$`1st segment` <- format(data$`1st segment`, nsmall=2)
  data$`2nd segment` <- format(data$`2nd segment`, nsmall=2)
  data$`3rd segment` <- format(data$`3rd segment`, nsmall=2)
  
  # offset by 1 month
  data$`1st segment` <- lag(data$`1st segment`, 1)
  data$`2nd segment` <- lag(data$`2nd segment`, 1)
  data$`3rd segment` <- lag(data$`3rd segment`, 1)
  
  # return just the months and segment rates
  res = data %>% select(1, 2, 3, tail(names(.), 7))
  res <- res[order(-res$Year, res$Month), ]
  # res <- format(res, digits=2, nsmall=2)
  rownames(res) <- res$Date
  
  return(res[, c('Month', 'Year', 'Date', '1st segment','2nd segment','3rd segment',
                 '1st segment (nonstabilized)', '2nd segment (nonstabilized)', '3rd segment (nonstabilized)')])
}

df <- scrape_rates()
rownames(df) <- df$Date
df <- df[order(-df$Year, df$Month), ]
# remove some unnecessary whitespace on the entries
df <- trim(df)
# prevent us from seeing lots of NaN entries if we're not very far into the year
df <- df[df$`1st segment` != 'NaN', ]
df[df == 'NaN'] <- '-'

server <- function(input, output, session) {
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- df
    if (input$month != "All") {
      data <- data[data$Month == input$month, ]
    }
    if (input$year != "All") {
      data <- data[data$Year == input$year, ]
    }
    data
  }, options = list(pageLength = 12,
                    columnDefs = list(list(visible=FALSE, targets=c(1, 2, 3))))))
}

ui <- fluidPage(
  titlePanel("Funding Yield Curve Segment Rates"),
  
  # Create a new row in the UI for selectInputs
  fluidRow(
    # Dropdown for Month
    column(4, selectInput("month", "Month:",
                          c("All", unique(as.character(df$Month))))),
    # Dropdown for Year
    column(4, selectInput("year", "Year:",
                          c("All", unique(as.character(df$Year)))))),
  # Create a new row for the table
  DT::dataTableOutput("table")
)

shinyApp(ui=ui, server=server)
