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
    use_waiter(),
    useShinyFeedback(),
    useShinyalert(),
    
    waiter_show_on_load(
      spin_fading_circles(), 
      html = h3("Loading Business Dashboard...")
    ),
    
    tabItems(
      tabItem(tabName = "sales", fluidPage(
        h2("Sales Trends Over Time"),
        actionButton("read_me","Read Me"),
        withSpinner(plotlyOutput("sales_plot")))),
        
      tabItem(tabName = "products", fluidPage(
        h2("Top 10 Best-Selling Products"),
        withSpinner(highchartOutput("top_products_chart"))
      )),
      
      tabItem(tabName = "map", fluidPage(
        h2("Sales by Country"),
        withSpinner(leafletOutput("sales_map", height = "500px"))
      )),
      
      tabItem(tabName = "transactions", fluidPage(
        h2("Transaction Records"),
        selectInput("filter_country", "Filter by Country:", choices = NULL, multiple = FALSE),
        loadingButton("apply_filter", "Apply Filter", class = "btn-primary"),  # Loading button
        withSpinner(DTOutput("transactions_table"))
      )),
      
      tabItem(tabName = "customers", fluidPage(
        h2("Customer Insights"),
        withSpinner(reactableOutput("customers_table"))
      ))
    )
  )
)

server <- function(input, output,session) {
  waiter_hide()  
  
  shinyalert(
    title = "Welcome!",
    text = "Explore the dashboard using the sidebar.",
    type = "info",
    showConfirmButton = TRUE
  )
  
  
  observeEvent(input$read_me, {
    showModal(modalDialog(
      title = "How to Use the Dashboard",
      "Navigate using the sidebar. Click tabs to explore sales trends, products, and customer insights.",
      easyClose = TRUE
    ))
  })
  
  observe({
    updateSelectInput(session, "filter_country", choices = unique(retail_data$Country))
  })
  
  
  # Apply filter button behavior
  observeEvent(input$apply_filter, {
    showFeedback("apply_filter")
    # Sys.sleep(2)  # Simulate processing delay
    hideFeedback("apply_filter")
  })
  
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
    filtered_data <- if (is.null(input$filter_country) || input$filter_country == "") {
      retail_data
    } else {
      retail_data %>% filter(Country == input$filter_country)
    }
    datatable(filtered_data, options = list(pageLength = 10))
  })
  
  
  output$customers_table <- renderReactable({
    get_customer_insights()  
  })
}

shinyApp(ui, server)
