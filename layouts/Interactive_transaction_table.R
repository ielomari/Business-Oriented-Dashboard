library(DT)

get_transactions_table <- function(data) {
  datatable(
    data %>% select(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country),
    options = list(pageLength = 10),
    rownames = FALSE
  )
}
