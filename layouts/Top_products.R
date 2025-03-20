# library(highcharter)
# library(dplyr)
source("setup.R")

# Load Data
retail_data <- read.csv("data/online_retail_combined.csv", stringsAsFactors = FALSE)

# Aggregate Top-Selling Products
top_products <- retail_data %>%
  group_by(Description) %>%
  summarize(TotalQuantity = sum(Quantity, na.rm = TRUE)) %>%
  arrange(desc(TotalQuantity)) %>%
  top_n(10, TotalQuantity)  # Select Top 10 Products

# Create Highcharter Bar Chart
top_products_chart <- highchart() %>%
  hc_chart(type = "bar") %>%
  hc_title(text = "Top 10 Best-Selling Products") %>%
  hc_xAxis(categories = top_products$Description) %>%
  hc_yAxis(title = list(text = "Total Quantity Sold")) %>%
  hc_add_series(name = "Quantity Sold", data = top_products$TotalQuantity)

# Function to return the chart
get_top_products <- function() {
  return(top_products_chart)
}
