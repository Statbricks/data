# Load required libraries
library(tidyverse)
library(lubridate)

# Set seed for reproducibility
set.seed(123)

# Kenya-specific data
kenya_counties <- c("Nairobi", "Mombasa", "Kisumu", "Nakuru", "Kiambu", 
                    "Uasin Gishu", "Machakos", "Kajiado", "Kilifi", "Nyeri")

kenya_cities <- list(
  "Nairobi" = c("Nairobi CBD", "Westlands", "Karen", "Eastleigh", "Kasarani"),
  "Mombasa" = c("Mombasa Island", "Nyali", "Bamburi", "Shanzu", "Likoni"),
  "Kisumu" = c("Kisumu CBD", "Kondele", "Mamboleo", "Milimani", "Nyalenda"),
  "Nakuru" = c("Nakuru CBD", "London", "Milimani", "Lanet", "Naka"),
  "Kiambu" = c("Thika", "Kikuyu", "Ruiru", "Kiambu Town", "Limuru"),
  "Uasin Gishu" = c("Eldoret", "Burnt Forest", "Turbo", "Moiben", "Ziwa"),
  "Machakos" = c("Machakos Town", "Athi River", "Kangundo", "Matuu", "Kathiani"),
  "Kajiado" = c("Ngong", "Ongata Rongai", "Kitengela", "Kajiado Town", "Kiserian"),
  "Kilifi" = c("Kilifi Town", "Malindi", "Watamu", "Mtwapa", "Mariakani"),
  "Nyeri" = c("Nyeri Town", "Karatina", "Othaya", "Mweiga", "Naro Moru")
)

# Kenyan names (representing different ethnic groups)
kenyan_names <- c(
  "Wanjiku", "Kamau", "Odhiambo", "Otieno", "Kipchoge", "Kosgei", "Mohammed",
  "Ali", "Njoroge", "Wambui", "Mwangi", "Auma", "Chebet", "Ruto", "Kimani",
  "Omondi", "Wekesa", "Mutuku", "Gathoni", "Mutua", "Nyambura", "Kiprop",
  "Maina", "Gitonga", "Wafula", "Kipkorir", "Okoth", "Waithaka", "Akinyi",
  "Mutiso", "Wanyama", "Owino", "Ndungu", "Ngugi", "Karanja", "Wanjiru",
  "Muthoni", "Kavita", "Kariuki", "Nyawira", "Chepkoech", "Naliaka", "Kibet",
  "Muriuki", "Onyango", "Wangari", "Adhiambo", "Cherotich", "Kimutai", "Ndegwa"
)

# Categories and subcategories relevant to Kenya
categories <- c("Electronics", "Clothing", "Furniture", "Groceries", "Beauty")

subcategories <- list(
  "Electronics" = c("Mobile Phones", "Laptops", "TVs", "Accessories", "Appliances"),
  "Clothing" = c("Traditional Wear", "Casual Wear", "Formal Wear", "Sportswear", "Accessories"),
  "Furniture" = c("Living Room", "Bedroom", "Office", "Outdoor", "Kitchen"),
  "Groceries" = c("Fresh Produce", "Cereals", "Beverages", "Snacks", "Household"),
  "Beauty" = c("Skincare", "Makeup", "Haircare", "Fragrances", "Personal Care")
)

# Payment modes common in Kenya
payment_modes <- c("M-Pesa", "Cash on Delivery", "Bank Transfer", "Credit Card", "Airtel Money")

# Generate Orders data (500 rows)
generate_orders <- function(n = 500) {
  # Generate random dates within the last 2 years
  end_date <- as.Date("2025-03-31")  # Using current date
  start_date <- end_date - years(2)
  
  dates <- sample(seq(start_date, end_date, by = "day"), n, replace = TRUE)
  
  # Format date as in the example
  formatted_dates <- format(dates, "%A, %d %B %Y")
  
  # Generate order IDs
  order_ids <- paste0("K-", sample(10000:99999, n))
  
  # Randomly select counties and cities
  selected_counties <- sample(kenya_counties, n, replace = TRUE)
  
  # Select cities based on the selected county
  selected_cities <- mapply(function(county) {
    sample(kenya_cities[[county]], 1)
  }, selected_counties)
  
  # Randomly select customer names
  customer_names <- sample(kenyan_names, n, replace = TRUE)
  
  # Create the orders dataframe
  orders <- tibble(
    `Order ID` = order_ids,
    `Order Date` = formatted_dates,
    CustomerName = customer_names,
    State = selected_counties,
    City = unlist(selected_cities)
  )
  
  return(orders)
}

# Generate Order Details data (3 items per order on average)
generate_details <- function(orders, items_multiplier = 3) {
  n_details <- nrow(orders) * items_multiplier
  
  # Get the order IDs from the orders dataframe
  order_ids <- orders$`Order ID`
  
  # Each order will have multiple items (random number between 1 and 5)
  selected_order_ids <- rep(order_ids, times = sample(1:5, length(order_ids), replace = TRUE))
  
  # Trim to match our target size
  selected_order_ids <- selected_order_ids[1:n_details]
  
  # Generate random categories
  selected_categories <- sample(categories, n_details, replace = TRUE)
  
  # Select subcategories based on the selected category
  selected_subcategories <- mapply(function(category) {
    sample(subcategories[[category]], 1)
  }, selected_categories)
  
  # Generate random quantities, amounts, and profits
  quantities <- sample(1:10, n_details, replace = TRUE)
  
  # Amounts will be based on category and quantity (with some randomness)
  base_prices <- c("Electronics" = 5000, "Clothing" = 2000, "Furniture" = 8000, 
                   "Groceries" = 500, "Beauty" = 1000)
  
  amounts <- mapply(function(category, quantity) {
    round(base_prices[category] * quantity * runif(1, 0.8, 1.2))
  }, selected_categories, quantities)
  
  # Profits will be a percentage of amount (between -30% and +40%)
  profits <- mapply(function(amount) {
    round(amount * runif(1, -0.3, 0.4))
  }, amounts)
  
  # Payment modes
  selected_payment_modes <- sample(payment_modes, n_details, replace = TRUE)
  
  # Create the details dataframe
  details <- tibble(
    `Order ID` = selected_order_ids,
    Amount = amounts,
    Profit = profits,
    Quantity = quantities,
    Category = selected_categories,
    `Sub-Category` = unlist(selected_subcategories),
    PaymentMode = selected_payment_modes
  )
  
  return(details)
}

# Generate the data
orders <- generate_orders(500)
details <- generate_details(orders)

# View the structure of the generated data
glimpse(orders)
glimpse(details)

# Optional: Save the data to CSV files
write_csv(orders, "data/sales/kenya_orders.csv")
write_csv(details, "data/sales/kenya_details.csv")

# Sample data view
head(orders, 10)
head(details, 10)