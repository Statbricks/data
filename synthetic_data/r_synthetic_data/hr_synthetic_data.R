# HR Synthetic Data Generator in R
# This script creates synthetic HR data across 8 related tables

# Load necessary libraries
library(tidyverse)
library(lubridate)

# Set seed for reproducibility
set.seed(123)

# Helper functions
random_date <- function(start_date, end_date) {
  start_seconds <- as.numeric(as.POSIXct(start_date))
  end_seconds <- as.numeric(as.POSIXct(end_date))
  random_seconds <- runif(1, start_seconds, end_seconds)
  as.Date(as.POSIXct(random_seconds, origin = "1970-01-01"))
}

random_choice <- function(x, size = 1) {
  sample(x, size, replace = TRUE)
}

# Generate age_group table
generate_age_groups <- function() {
  tibble(
    agegroupid = 1:5,
    age_category = c("18-24", "25-34", "35-44", "45-54", "55+")
  )
}

# Generate BU (Business Unit) table
generate_bus <- function() {
  regions <- c("North America", "Europe", "Asia Pacific", "Latin America", "Middle East & Africa")
  vps <- c("John Smith", "Maria Rodriguez", "Aisha Patel", "Carlos Gomez", "Sarah Johnson",
           "Wei Chen", "David Kim", "Rachel Green", "Michael Scott", "Omar Hassan")
  
  business_units <- tibble()
  region_seq <- 1
  
  # Create main BUs
  main_bus <- c("Sales", "Marketing", "Finance", "IT", "HR", "Operations", "R&D", "Customer Support")
  
  for (i in seq_along(main_bus)) {
    num_regions <- sample(1:3, 1)
    
    for (j in 1:num_regions) {
      region <- random_choice(regions)
      bu_name <- if (j > 1) paste(main_bus[i], j) else main_bus[i]
      
      business_units <- business_units %>%
        bind_rows(tibble(
          bu = bu_name,
          regionseq = region_seq,
          vp = random_choice(vps),
          region = region
        ))
      
      region_seq <- region_seq + 1
    }
  }
  
  business_units
}

# Generate ethnicity table
generate_ethnicity <- function() {
  tibble(
    ethnicgroup = c("A", "B", "H", "W", "O", "T", "N"),
    ethnicity = c("Asian", "Black", "Hispanic", "White", "Other", "Two or More", "Not Specified")
  )
}

# Generate fp (Full/Part Time) table
generate_fp <- function() {
  tibble(
    fp = c("F", "P", "C", "I"),
    fpdescription = c("Full Time", "Part Time", "Contractor", "Intern")
  )
}

# Generate gender table
generate_gender <- function() {
  tibble(
    id = 1:3,
    gender = c("Male", "Female", "Not Specified"),
    sort = 1:3
  )
}

# Generate paytype table
generate_paytype <- function() {
  tibble(
    paytypeid = 1:4,
    paytype = c("Hourly", "Salary", "Commission", "Piece Rate")
  )
}

# Generate separation reason table
generate_separation_reason <- function() {
  tibble(
    Separationtypeid = 1:10,
    separationreason = c(
      "Voluntary - Career Opportunity",
      "Voluntary - Relocation",
      "Voluntary - Retirement",
      "Voluntary - Personal",
      "Voluntary - Health",
      "Involuntary - Performance",
      "Involuntary - Conduct",
      "Involuntary - Restructuring",
      "End of Contract",
      "Other"
    )
  )
}

# Generate employees table
generate_employees <- function(bu_data, num_employees = 1000) {
  start_date <- as.Date("2018-01-01")
  end_date <- as.Date("2023-12-31")
  
  genders <- c("Male", "Female", "Not Specified")
  gender_ids <- c(1, 2, 3)
  names(gender_ids) <- genders
  
  ethnic_groups <- c("A", "B", "H", "W", "O", "T", "N")
  fp_options <- c("F", "P", "C", "I")
  
  employees <- tibble()
  
  for (i in 1:num_employees) {
    gender <- random_choice(genders)
    age <- sample(18:65, 1)
    
    # Determine age group
    age_group_id <- case_when(
      age <= 24 ~ 1,
      age <= 34 ~ 2,
      age <= 44 ~ 3,
      age <= 54 ~ 4,
      TRUE ~ 5
    )
    
    hire_date <- random_date(start_date, end_date)
    
    # Determine if terminated
    is_terminated <- runif(1) < 0.25  # 25% chance of being terminated
    term_date <- NULL
    term_reason <- NULL
    
    if (is_terminated) {
      term_date <- random_date(hire_date, end_date)
      term_reason <- sample(1:10, 1)
    }
    
    # Calculate tenure
    end_date_obj <- if (!is.null(term_date)) term_date else as.Date("2023-12-31")
    tenure_days <- as.integer(end_date_obj - hire_date)
    tenure_months <- as.integer(tenure_days / 30.44)
    
    # Determine if new hire (hired in last 90 days of data period)
    is_new_hire <- as.integer(as.Date("2023-12-31") - hire_date <= 90)
    
    # Determine if bad hire (terminated within 90 days)
    bad_hire <- as.integer(is_terminated && (term_date - hire_date) <= 90)
    
    employees <- employees %>%
      bind_rows(tibble(
        date = as.Date("2023-12-31"),  # Current reporting date
        employeeid = i,
        gender = gender_ids[gender],
        age = age,
        ethnicgroup = random_choice(ethnic_groups),
        fp = random_choice(fp_options),
        termdate = if (is_terminated) term_date else NA,
        isnnewhire = is_new_hire,
        bu = random_choice(bu_data$bu),
        hiredate = hire_date,
        paytypeid = sample(1:4, 1),
        termreason = if (is_terminated) term_reason else NA,
        agegroupid = age_group_id,
        tenuredays = tenure_days,
        tenuremonths = tenure_months,
        badhire = bad_hire
      ))
  }
  
  employees
}

# Generate all datasets
age_groups <- generate_age_groups()
business_units <- generate_bus()
ethnicity_data <- generate_ethnicity()
fp_data <- generate_fp()
gender_data <- generate_gender()
paytype_data <- generate_paytype()
separation_reason_data <- generate_separation_reason()
employees_data <- generate_employees(business_units, 10000)

# Save all tables as CSV files
write_csv(age_groups, "data/hr/age_group.csv")
write_csv(business_units, "data/hr/BU.csv")
write_csv(ethnicity_data, "data/hr/ethnicity.csv")
write_csv(fp_data, "data/hr/fp.csv")
write_csv(gender_data, "data/hr/gender.csv")
write_csv(paytype_data, "data/hr/paytype.csv")
write_csv(separation_reason_data, "data/hr/separationreason.csv")
write_csv(employees_data, "data/hr/employees.csv")

# Print table summaries
cat("Age Groups Table:\n")
print(age_groups)
cat("\nBusiness Units Table (first 5 rows):\n")
print(head(business_units, 5))
cat("\nEthnicity Table:\n")
print(ethnicity_data)
cat("\nFull/Part Time Table:\n")
print(fp_data)
cat("\nGender Table:\n")
print(gender_data)
cat("\nPay Type Table:\n")
print(paytype_data)
cat("\nSeparation Reason Table:\n")
print(separation_reason_data)
cat("\nEmployees Table (first 5 rows):\n")
print(head(employees_data, 5))

# Generate basic statistics for the employees data
cat("\nEmployee Statistics:\n")
cat("Total Employees:", nrow(employees_data), "\n")
cat("Terminated Employees:", sum(!is.na(employees_data$termdate)), "\n")
cat("New Hires:", sum(employees_data$isnnewhire), "\n")
cat("Bad Hires:", sum(employees_data$badhire), "\n")
cat("Average Tenure (months):", mean(employees_data$tenuremonths), "\n")

# Generate sample plots
# Distribution of employees by age group
age_distribution <- employees_data %>%
  group_by(agegroupid) %>%
  summarise(count = n()) %>%
  inner_join(age_groups, by = "agegroupid")

cat("\nAge Group Distribution:\n")
print(age_distribution)

# Termination reasons distribution
if (sum(!is.na(employees_data$termreason)) > 0) {
  term_reasons <- employees_data %>%
    filter(!is.na(termreason)) %>%
    group_by(termreason) %>%
    summarise(count = n()) %>%
    inner_join(separation_reason_data, by = c("termreason" = "Separationtypeid"))
  
  cat("\nTermination Reasons Distribution:\n")
  print(term_reasons)
}

