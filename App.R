library(shiny)
library(shinydashboard)
library(dplyr)
library(plotly)
library(highcharter)
library(leaflet)
library(DT)
library(reactable)
library(waiter)
library(shinyFeedback)
library(shinycssloaders)
library(shinyalert)
library(shinyjs)
library(rio)
library(rmarkdown) 
library(shinymanager)
library(rsconnect)

deployApp()


# Secure credentials via environment vars
auth_users <- data.frame(
  user = c(Sys.getenv("DASHBOARD_ADMIN"), Sys.getenv("DASHBOARD_USER")),
  password = c(Sys.getenv("DASHBOARD_ADMIN_PWD"), Sys.getenv("DASHBOARD_USER_PWD")),
  admin = c(TRUE, FALSE),
  stringsAsFactors = FALSE
)

credentials <- check_credentials(auth_users)

source("data/data_manipulation.R")

source("layouts/Sales_trends.R")  
source("layouts/Top_products.R")
source("layouts/Sales_by_country.R")
source("layouts/Interactive_transaction_table.R")
source("layouts/Customer_insights.R")

ui <- secure_app(dashboardPage(
  dashboardHeader(title = "Retail Sales Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Sales Trends", tabName = "sales", icon = icon("chart-line")),
      menuItem("Top Products", tabName = "products", icon = icon("box")),
      menuItem("Sales by Country", tabName = "map", icon = icon("globe")),
      menuItem("Transactions", tabName = "transactions", icon = icon("table")),
      menuItem("Customer Insights", tabName = "customers", icon = icon("users")),
      conditionalPanel(
        condition = "output.is_admin === true",
        menuItem("Admin Panel", tabName = "admin", icon = icon("user-shield"))
      )
    )
  ),
  dashboardBody(
    use_waiter(),
    useShinyFeedback(),
    # useShinyalert(),
    useShinyjs(),
    waiter_show_on_load(
      spin_fading_circles(), 
      html = h3("Loading Business Dashboard...")
    ),
    
    tabItems(
      tabItem(tabName = "sales", fluidPage(
        h2("Sales Trends Over Time"),
        actionButton("read_me","Read Me"),
        withSpinner(plotlyOutput("sales_plot")),
        downloadButton("download_data", "Download Processed Data"),
        downloadButton("download_report", "Generate Report")
        )),
        
      tabItem(tabName = "products", fluidPage(
        h2("Top Best-Selling Products"),
        withSpinner(highchartOutput("top_products_chart"))
      )),
      
      tabItem(tabName = "map", fluidPage(
        h2("Sales by Country"),
        withSpinner(leafletOutput("sales_map", height = "500px"))
      )),
      
      tabItem(tabName = "transactions", fluidPage(
        h2("Transaction Records"),
        selectInput("filter_country", "Filter by Country:", choices = NULL, multiple = FALSE),
        # loadingButton("apply_filter", "Apply Filter", class = "btn-primary"),
        withSpinner(DTOutput("transactions_table"))
      )),
      
      tabItem(tabName = "customers", fluidPage(
        h2("Customer Insights"),
        withSpinner(reactableOutput("customers_table"))
      )),
      tabItem(tabName = "admin", fluidPage(
        h2("Admin Panel"),
        downloadButton("download_raw", "Download Full Dataset"),
        h3("Registered Users"),
        DTOutput("user_table")
      ))
    )
  )
)
)
server <- function(input, output,session) {
  res_auth <- secure_server(check_credentials = credentials)

  
  output$is_admin <- reactive({
    req(res_auth$user)  # Wait until user is logged in
    
    user_row <- auth_users %>%
      filter(user == res_auth$user)
    
    if (nrow(user_row) == 1) {
      return(user_row$admin)
    } else {
      return(FALSE)
    }
  })
  
  
  outputOptions(output, "is_admin", suspendWhenHidden = FALSE)
 
  observeEvent(res_auth$user, {
    shinyalert(
      title = "Welcome!",
      text = paste("Hello", res_auth$user, "- Explore the dashboard using the sidebar."),
      type = "info"
    )
  })
  
  
  observeEvent(input$read_me, {
    showModal(modalDialog(
      title = "How to Use the Dashboard",
      "Navigate using the sidebar. Click tabs to explore sales trends, products, and customer insights.",
      easyClose = TRUE
    ))
  })
  
  observe({
    updateSelectInput(session, "filter_country", choices = unique(retail_data$Country))
    updateSelectInput(session, "report_country", choices = unique(retail_data$Country))
  })
  
  
  # # Apply filter button behavior
  # observeEvent(input$apply_filter, {
  #   updateLoadingButton(session, "apply_filter", loading = TRUE)
  #   
  #   # Simulate filtering or processing
  #   Sys.sleep(1)
  #   
  #   updateLoadingButtonLabel(session, inputId = "apply_filter", label = "Apply Filter")
  # })
  
  
  output$sales_plot <- renderPlotly({
    get_sales_trends(retail_data)  
  })
  
  output$top_products_chart <- renderHighchart({
    get_top_products(retail_data) 
  })
  
  output$sales_map <- renderLeaflet({
    get_sales_map(retail_data)  
  })
  

  output$transactions_table <- renderDT({
    filtered_data <- if (is.null(input$filter_country) || input$filter_country == "") {
      retail_data
    } else {
      retail_data %>% filter(Country == input$filter_country)
    }
    get_transactions_table(filtered_data)
  })
  
  
  output$customers_table <- renderReactable({
    get_customer_insights(retail_data)  
  })
  
  # Download processed data
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("processed_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      export(retail_data, file)
    }
  )
  
  output$download_report <- downloadHandler(
    filename = function() paste0("dashboard_report_", Sys.Date(), ".html"),
    content = function(file) {
      shinyjs::disable("download_report")
      filtered_data <- if (is.null(input$filter_country) || input$filter_country == "") retail_data else retail_data %>% filter(Country == input$filter_country)
      rmarkdown::render(
        input = "www/report_template.Rmd",
        output_file = file,
        params = list(country = input$filter_country, data = filtered_data),
        envir = new.env(parent = globalenv())
      )
      shinyjs::enable("download_report")
      shinyalert("Success", "Report has been generated!", type = "success")
    }
  )
  
  output$download_raw <- downloadHandler(
    filename = function() "raw_retail_data.csv",
    content = function(file) export(retail_data, file)
  )
  
  output$user_table <- renderDT({
    datatable(auth_users, rownames = FALSE)
  })
  
  # Waiter hide after outputs are rendered
  session$onFlushed(function() {
    waiter_hide()
  }, once = TRUE)
  
}

shinyApp(ui, server)
