library(highcharter)

get_top_products <- function(data) {
  top_products <- data %>%
    group_by(Description) %>%
    summarize(QuantitySold = sum(Quantity)) %>%
    arrange(desc(QuantitySold)) %>%
    slice_max(QuantitySold, n = 10)
  
  highchart() %>%
    hc_chart(type = "bar") %>%
    hc_xAxis(categories = top_products$Description) %>%
    hc_add_series(name = "Quantity Sold", data = top_products$QuantitySold)
}