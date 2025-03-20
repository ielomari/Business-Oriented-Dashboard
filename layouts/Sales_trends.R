# library(plotly)
# library(dplyr)
# library(lubridate)
source("setup.R")
# Load Data
retail_data <- read.csv("data/online_retail_combined.csv", stringsAsFactors = FALSE)


# Converts the InvoiceDate column from a character/string format into a proper date-time (POSIXct) format in R. 
# This is necessary for plotting time-series data and performing date-based calculations.

# Ensure the correct data types
retail_data <- retail_data %>%
  mutate(
    InvoiceDate = as.POSIXct(InvoiceDate, format="%Y-%m-%d %H:%M:%S", tz="UTC"),
    Quantity = as.numeric(Quantity),
    Price = as.numeric(Price)
  )

# Remove invalid rows and aggregate sales
sales_trends <- retail_data %>%
  filter(!is.na(InvoiceDate) & Quantity > 0 & Price > 0) %>%
  group_by(InvoiceDate) %>%
  summarize(TotalRevenue = sum(Quantity * Price, na.rm = TRUE))

# Check if data is empty after filtering
if (nrow(sales_trends) == 0) {
  stop("ERROR: No valid sales data available after filtering.")
}

# print(summary(sales_trends$InvoiceDate))
# print(summary(sales_trends$TotalRevenue))


# Create Plotly Chart
sales_plot <- plot_ly(
  data = sales_trends,
  x = ~InvoiceDate,
  y = ~TotalRevenue,
  type = "scatter",
  mode = "lines"
) %>%
  layout(title = "Sales Trends Over Time",
         xaxis = list(title = "Date"),
         yaxis = list(title = "Total Revenue"))

# Function to return the plot
get_sales_trends <- function() {
  return(sales_plot)
}
