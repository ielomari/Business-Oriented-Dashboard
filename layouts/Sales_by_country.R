library(leaflet)

get_sales_map <- function(data) {
  country_sales <- data %>%
    group_by(Country) %>%
    summarize(TotalRevenue = sum(Revenue, na.rm = TRUE))
  
  coords <- read.csv("data/country_coordinates.csv")
  map_data <- merge(country_sales, coords, by = "Country", all.x = TRUE) %>%
    filter(!is.na(Latitude) & !is.na(Longitude))
  
  leaflet(map_data) %>%
    addTiles() %>%
    addCircleMarkers(
      lng = ~Longitude,
      lat = ~Latitude,
      radius = ~sqrt(TotalRevenue)/100,
      popup = ~paste0("<b>", Country, "</b><br>Revenue: $", round(TotalRevenue, 2)),
      color = "blue",
      fillOpacity = 0.5
    ) %>%
    setView(lng = 0, lat = 40, zoom = 2)
}
