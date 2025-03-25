library(plotly)

get_sales_trends <- function(data) {
  sales_trends <- data %>%
    group_by(InvoiceDate) %>%
    summarize(TotalRevenue = sum(Revenue, na.rm = TRUE))
  
  plot_ly(
    data = sales_trends,
    x = ~InvoiceDate,
    y = ~TotalRevenue,
    type = "scatter",
    mode = "lines"
  ) %>%
    layout(title = "Sales Trends Over Time")
}
