# library(leaflet)
# library(dplyr)
source("setup.R")

# Load retail data
retail_data <- read.csv("data/online_retail_combined.csv", stringsAsFactors = FALSE)

# Load country coordinates from external CSV file
country_coords <- read.csv("data/country_coordinates.csv", stringsAsFactors = FALSE)

# Aggregate sales by country
country_sales <- retail_data %>%
  group_by(Country) %>%
  summarize(TotalRevenue = sum(Quantity * Price, na.rm = TRUE)) %>%
  arrange(desc(TotalRevenue))

# Merge sales data with country coordinates dynamically
map_data <- merge(country_sales, country_coords, by = "Country", all.x = TRUE)

# Create Leaflet Map
sales_map <- leaflet(map_data) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~longitude,
    lat = ~latitude,
    radius = ~sqrt(TotalRevenue) / 100,  # Scale marker size by revenue
    popup = ~paste0("<b>", Country, "</b><br>Revenue: $", round(TotalRevenue, 2)),
    color = "blue",
    fillOpacity = 0.5
  ) %>%
  setView(lng = 0, lat = 40, zoom = 2)

# Function to return the map
get_sales_map <- function() {
  return(sales_map)
}
