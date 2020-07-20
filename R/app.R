#' Runs a shiny app
#'
#' @export
run_shiny <- function() {
  df <- scrape_rates()
  rownames(df) <- df$date
  df <- df[order(-df$year, df$month), ]

  # remove some unnecessary whitespace on the entries
  df <- gdata::trim(df)

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
  ui <- shiny::fluidPage(
    shiny::titlePanel("Funding Yield Curve Segment Rates"),

    # create a new row in the UI for selectInputs (dropdowns)
    shiny::fluidRow(
      # dropdown for month
      shiny::column(4, shiny::selectInput("month", "month:",
                                          c("All", unique(as.character(df$month))))),

      # dropdown for year
      shiny::column(4, shiny::selectInput("year", "year:",
                                          c("All", unique(as.character(df$year)))))),

    # add the data table to the interface
    DT::dataTableOutput("table")
  )

  # create the server
  shiny::shinyApp(ui = ui, server = server)
}
