# library(DT)  
# library(dplyr)  
source("setup.R")

# Load Data
retail_data <- read.csv("data/online_retail_combined.csv", stringsAsFactors = FALSE)

# Select only relevant columns
transactions_data <- retail_data %>%
  select(Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer.ID, Country) %>%
  mutate(InvoiceDate = as.POSIXct(InvoiceDate, format="%Y-%m-%d %H:%M:%S", tz="UTC"))

# Create interactive DataTable
get_transactions_table <- function() {
  datatable(
    transactions_data,
    options = list(
      pageLength = 10,  
      autoWidth = TRUE, 
      searchHighlight = TRUE,  
      dom = 'Bfrtip',  # Show buttons for CSV export
      buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
    ),
    extensions = 'Buttons',
    rownames = FALSE
  )
}
