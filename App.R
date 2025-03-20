# library(rio)
# library(dplyr)
# library(shiny)
# library(shinydashboard)
# library(highcharter)
# library(leaflet)

source("layouts/Sales_trends.R")  
source("layouts/Top_products.R")
source("layouts/Sales_by_country.R")
source("layouts/Interactive_transaction_table.R")
source("layouts/Customer_insights.R")
source("setup.R")


# #import dataset
# retail_data <- import("data/online_retail_combined.csv")

# #Clean data
# retail_data <- retail_data %>%
#   filter(!is.na(CustomerID)) %>%  # Remove missing customers
#   mutate(Revenue = Quantity * Price)  # Calculate revenue

ui <- dashboardPage(
  dashboardHeader(title = "Retail Sales Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Sales Trends", tabName = "sales", icon = icon("chart-line")),
      menuItem("Top Products", tabName = "products", icon = icon("box")),
      menuItem("Sales by Country", tabName = "map", icon = icon("globe")),
      menuItem("Transactions", tabName = "transactions", icon = icon("table")),
      menuItem("Customer Insights", tabName = "customers", icon = icon("users"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "sales", plotlyOutput("sales_plot")),
      tabItem(tabName = "products",highchartOutput("top_products_chart")),
      tabItem(tabName = "map", leafletOutput("sales_map")),
      tabItem(tabName = "transactions", DTOutput("transactions_table")),
      tabItem(tabName = "customers", reactableOutput("customers_table"))
    )
  )
)

server <- function(input, output) {
  output$sales_plot <- renderPlotly({
    get_sales_trends()  
  })
  
  output$top_products_chart <- renderHighchart({
    get_top_products() 
  })
  
  output$sales_map <- renderLeaflet({
    get_sales_map()  
  })
  
  output$transactions_table <- renderDT({
    get_transactions_table() 
  })
  
  output$customers_table <- renderReactable({
    get_customer_insights()  
  })
}

shinyApp(ui, server)
