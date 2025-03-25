library(reactable)

get_customer_insights <- function(data) {
  customer_data <- data %>%
    group_by(CustomerID, Country) %>%
    summarize(
      TotalSpent = sum(Revenue, na.rm = TRUE),
      TotalOrders = n(),
      UniqueProducts = n_distinct(StockCode),
      .groups = "drop"
    ) %>%
    arrange(desc(TotalSpent))
  
  reactable(
    customer_data,
    columns = list(
      CustomerID = colDef(name = "Customer ID"),
      Country = colDef(name = "Country"),
      TotalSpent = colDef(name = "Total Spent", format = colFormat(prefix = "$")),
      TotalOrders = colDef(name = "Orders"),
      UniqueProducts = colDef(name = "Unique Products")
    ),
    searchable = TRUE,
    filterable = TRUE,
    highlight = TRUE,
    defaultPageSize = 10
  )
}