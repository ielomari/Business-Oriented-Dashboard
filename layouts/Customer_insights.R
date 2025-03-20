# library(reactable) 
# library(dplyr) 

source("setup.R")

# Load Data
retail_data <- read.csv("data/online_retail_combined.csv", stringsAsFactors = FALSE)

# Aggregate Total Spending Per Customer
customer_data <- retail_data %>%
  group_by(Customer.ID, Country) %>%
  summarize(
    TotalSpent = sum(Quantity * Price, na.rm = TRUE),
    TotalOrders = n(),
    UniqueProducts = n_distinct(StockCode)
  ) %>%
  arrange(desc(TotalSpent))  # Sort customers by total spending

# Create interactive customer insights table
get_customer_insights <- function() {
  reactable(
    customer_data,
    columns = list(
      Customer.ID = colDef(name = "Customer ID", width = 150),
      Country = colDef(name = "Country", width = 150),
      TotalSpent = colDef(name = "Total Spent (€)", format = colFormat(prefix = "€", digits = 2), width = 200),
      TotalOrders = colDef(name = "Total Orders", width = 150),
      UniqueProducts = colDef(name = "Unique Products Purchased", width = 250)
    ),
    defaultPageSize = 10,
    striped = TRUE,  # Alternate row colors
    highlight = TRUE,  # Highlight on hover
    bordered = TRUE,  # Add table borders
    filterable = TRUE,  # Add filtering options
    searchable = TRUE  # Add search box
  )
}
