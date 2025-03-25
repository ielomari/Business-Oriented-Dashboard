library(dplyr)
library(readr)

retail_data <- read_csv("data/online_retail_combined.csv") %>%
  # Rename incorrectly named columns
  rename(
    InvoiceNo = Invoice,
    CustomerID = `Customer ID`
  ) %>%
  filter(!is.na(CustomerID)) %>%
  mutate(Revenue = Quantity * Price)
