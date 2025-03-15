# Modified HR Synthetic Data Generator in R
# This script creates synthetic HR data across 8 related tables with enhanced visualization patterns

# Load necessary libraries
library(tidyverse)
library(lubridate)
library(ggplot2)  # Added for better visualizations

# Set seed for reproducibility (changed for different results)
set.seed(456)  # Changed from 123

# Helper functions
random_date <- function(start_date, end_date) {
  start_seconds <- as.numeric(as.POSIXct(start_date))
  end_seconds <- as.numeric(as.POSIXct(end_date))
  random_seconds <- runif(1, start_seconds, end_seconds)
  as.Date(as.POSIXct(random_seconds, origin = "1970-01-01"))
}

random_choice <- function(x, size = 1, prob = NULL) {
  sample(x, size, replace = TRUE, prob = prob)
}

# Generate age_group table
generate_age_groups <- function() {
  tibble(
    agegroupid = 1:5,
    age_category = c("18-24", "25-34", "35-44", "45-54", "55+")
  )
}

# Generate BU (Business Unit) table with enhanced regional distribution
generate_bus <- function() {
  regions <- c("North America", "Europe", "Asia Pacific", "Latin America", "Middle East & Africa")
  region_weights <- c(0.3, 0.25, 0.2, 0.15, 0.1)  # Modified distribution by region
  
  vps <- c("John Smith", "Maria Rodriguez", "Aisha Patel", "Carlos Gomez", "Sarah Johnson",
           "Wei Chen", "David Kim", "Rachel Green", "Michael Scott", "Omar Hassan")
  
  business_units <- tibble()
  region_seq <- 1
  
  # Create main BUs with more variety
  main_bus <- c("Sales", "Marketing", "Finance", "IT", "HR", "Operations", "R&D", "Customer Support",
                "Legal", "Executive")  # Added 2 more BUs
  
  for (i in seq_along(main_bus)) {
    # More variety in number of regions
    num_regions <- sample(1:5, 1, prob = c(0.1, 0.2, 0.3, 0.3, 0.1))
    
    for (j in 1:num_regions) {
      region <- random_choice(regions, prob = region_weights)
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

# Generate fp (Full/Part Time) table with additional options
generate_fp <- function() {
  tibble(
    fp = c("F", "P", "C", "I", "T"),  # Added "T" for Temporary
    fpdescription = c("Full Time", "Part Time", "Contractor", "Intern", "Temporary")
  )
}

# Generate gender table with non-binary option
generate_gender <- function() {
  tibble(
    id = 1:4,  # Added a 4th option
    gender = c("Male", "Female", "Non-Binary", "Not Specified"),
    sort = 1:4
  )
}

# Generate paytype table
generate_paytype <- function() {
  tibble(
    paytypeid = 1:5,  # Added one more pay type
    paytype = c("Hourly", "Salary", "Commission", "Piece Rate", "Hybrid")
  )
}

# Generate separation reason table with more detail
generate_separation_reason <- function() {
  tibble(
    Separationtypeid = 1:12,  # Added 2 more reasons
    separationreason = c(
      "Voluntary - Career Opportunity",
      "Voluntary - Relocation",
      "Voluntary - Retirement",
      "Voluntary - Personal",
      "Voluntary - Health",
      "Voluntary - Work-Life Balance",  # New
      "Involuntary - Performance",
      "Involuntary - Conduct",
      "Involuntary - Restructuring",
      "Involuntary - Position Elimination",  # New
      "End of Contract",
      "Other"
    )
  )
}

# Enhanced employee data generation with more varied distributions
generate_employees <- function(bu_data, num_employees = 1000) {
  start_date <- as.Date("2018-01-01")
  end_date <- as.Date("2023-12-31")
  
  # Updated to include non-binary
  genders <- c("Male", "Female", "Non-Binary", "Not Specified")
  gender_ids <- c(1, 2, 3, 4)
  names(gender_ids) <- genders
  
  # Custom probability distributions for more realistic data
  gender_probs <- c(0.48, 0.48, 0.02, 0.02)
  
  ethnic_groups <- c("A", "B", "H", "W", "O", "T", "N")
  ethnic_probs <- c(0.15, 0.13, 0.18, 0.45, 0.04, 0.03, 0.02)  # Custom distribution
  
  fp_options <- c("F", "P", "C", "I", "T")
  fp_probs <- c(0.65, 0.15, 0.1, 0.05, 0.05)  # Mostly full time
  
  # BU weights to create clustering
  bu_weights <- rep(1, nrow(bu_data))
  names(bu_weights) <- bu_data$bu
  
  # Give extra weight to certain business units
  for (i in 1:length(bu_weights)) {
    if (grepl("Sales|IT", names(bu_weights)[i])) {
      bu_weights[i] <- bu_weights[i] * 2  # 2x more employees in Sales and IT
    }
    if (grepl("Executive", names(bu_weights)[i])) {
      bu_weights[i] <- bu_weights[i] * 0.3  # Fewer executives
    }
  }
  
  # Normalize weights
  bu_weights <- bu_weights / sum(bu_weights)
  
  employees <- tibble()
  
  for (i in 1:num_employees) {
    gender <- random_choice(genders, prob = gender_probs)
    
    # Age distribution with slight curve (more mid-career)
    if (runif(1) < 0.7) {
      age <- sample(25:45, 1)  # 70% chance of being 25-45
    } else {
      age <- sample(c(18:24, 46:65), 1)  # 30% chance of being 18-24 or 46-65
    }
    
    # Determine age group
    age_group_id <- case_when(
      age <= 24 ~ 1,
      age <= 34 ~ 2,
      age <= 44 ~ 3,
      age <= 54 ~ 4,
      TRUE ~ 5
    )
    
    # Adjusted hire date distribution - more recent hires
    days_back <- rexp(1, 1/500)  # Exponential distribution favoring recent dates
    days_back <- min(days_back, as.numeric(end_date - start_date))
    hire_date <- end_date - days_back
    
    # Ensure hire date is not before start date
    hire_date <- max(hire_date, start_date)
    
    # Determine if terminated - higher rate for certain conditions
    term_probability <- 0.25  # Base probability
    
    # Adjust termination probability based on factors
    if (age < 25 || age > 55) {
      term_probability <- term_probability * 1.5  # Higher turnover for youngest and oldest
    }
    
    is_terminated <- runif(1) < term_probability
    term_date <- NULL
    term_reason <- NULL
    
    if (is_terminated) {
      # Modified termination date distribution - higher likelihood of leaving in first year
      tenure_weight <- rexp(1, 1/180)  # Days after hire with exponential decay
      max_tenure <- as.numeric(end_date - hire_date)
      tenure_days <- min(tenure_weight, max_tenure)
      term_date <- hire_date + tenure_days
      
      # Modified termination reason distribution
      if (age < 30) {
        # Younger employees more likely to leave for career opportunity
        term_reason <- sample(1:12, 1, prob = c(0.3, 0.15, 0.05, 0.1, 0.05, 0.15, 0.05, 0.05, 0.05, 0.01, 0.03, 0.01))
      } else if (age > 50) {
        # Older employees more likely to retire
        term_reason <- sample(1:12, 1, prob = c(0.1, 0.1, 0.4, 0.05, 0.1, 0.05, 0.05, 0.05, 0.05, 0.01, 0.03, 0.01))
      } else {
        # Mid-career more typical distribution
        term_reason <- sample(1:12, 1, prob = c(0.2, 0.1, 0.05, 0.1, 0.05, 0.2, 0.1, 0.05, 0.08, 0.03, 0.02, 0.02))
      }
    }
    
    # Calculate tenure
    end_date_obj <- if (!is.null(term_date)) term_date else as.Date("2023-12-31")
    tenure_days <- as.integer(end_date_obj - hire_date)
    tenure_months <- as.integer(tenure_days / 30.44)
    
    # Determine if new hire (hired in last 90 days of data period)
    is_new_hire <- as.integer(as.Date("2023-12-31") - hire_date <= 90)
    
    # Determine if bad hire (terminated within 90 days)
    bad_hire <- as.integer(is_terminated && (term_date - hire_date) <= 90)
    
    # Assign business unit with weights
    bu_choice <- sample(
      bu_data$bu, 
      1, 
      prob = bu_weights
    )
    
    # Pay type based on business unit and age
    paytype_probs <- c(0.25, 0.5, 0.1, 0.05, 0.1)  # Base probabilities
    
    # Adjust pay type probabilities based on business unit
    if (grepl("Sales", bu_choice)) {
      paytype_probs <- c(0.1, 0.4, 0.4, 0.05, 0.05)  # More commission-based in Sales
    } else if (grepl("IT|R&D", bu_choice)) {
      paytype_probs <- c(0.1, 0.7, 0.05, 0.05, 0.1)  # More salary in IT/R&D
    } else if (grepl("Operations", bu_choice)) {
      paytype_probs <- c(0.6, 0.2, 0.05, 0.1, 0.05)  # More hourly in Operations
    }
    
    employees <- employees %>%
      bind_rows(tibble(
        date = as.Date("2023-12-31"),  # Current reporting date
        employeeid = i,
        gender = gender_ids[gender],
        age = age,
        ethnicgroup = random_choice(ethnic_groups, prob = ethnic_probs),
        fp = random_choice(fp_options, prob = fp_probs),
        termdate = if (is_terminated) term_date else NA,
        isnnewhire = is_new_hire,
        bu = bu_choice,
        hiredate = hire_date,
        paytypeid = sample(1:5, 1, prob = paytype_probs),
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
write_csv(age_groups, "data/hr/age_group.csv", na = "")
write_csv(business_units, "data/hr/BU.csv", na = "")
write_csv(ethnicity_data, "data/hr/ethnicity.csv", na = "")
write_csv(fp_data, "data/hr/fp.csv", na = "")
write_csv(gender_data, "data/hr/gender.csv", na = "")
write_csv(paytype_data, "data/hr/paytype.csv", na = "")
write_csv(separation_reason_data, "data/hr/separationreason.csv", na = "")
write_csv(employees_data, "data/hr/employees.csv", na = "")

# Generate basic statistics for the employees data
cat("\nEmployee Statistics:\n")
cat("Total Employees:", nrow(employees_data), "\n")
cat("Terminated Employees:", sum(!is.na(employees_data$termdate)), "\n")
cat("New Hires:", sum(employees_data$isnnewhire), "\n")
cat("Bad Hires:", sum(employees_data$badhire), "\n")
cat("Average Tenure (months):", mean(employees_data$tenuremonths), "\n")

# Enhanced visualization section
# ===============================

# 1. Distribution of employees by age group with visualization
age_distribution <- employees_data %>%
  group_by(agegroupid) %>%
  summarise(count = n()) %>%
  inner_join(age_groups, by = "agegroupid")

cat("\nAge Group Distribution:\n")
print(age_distribution)

# Create age distribution plot
age_plot <- ggplot(age_distribution, aes(x = age_category, y = count, fill = age_category)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Employee Distribution by Age Group",
       x = "Age Group",
       y = "Number of Employees") +
  theme(legend.position = "none")

# Save the plot
#ggsave("data/hr/age_distribution.png", age_plot, width = 8, height = 5)

# 2. Gender distribution with visualization
gender_distribution <- employees_data %>%
  group_by(gender) %>%
  summarise(count = n()) %>%
  inner_join(gender_data, by = c("gender" = "id"))

cat("\nGender Distribution:\n")
print(gender_distribution)

# Create gender distribution plot
gender_plot <- ggplot(gender_distribution, aes(x = gender.y, y = count, fill = gender.y)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Employee Distribution by Gender",
       x = "Gender",
       y = "Number of Employees") +
  theme(legend.position = "none")

# Save the plot
#ggsave("data/hr/gender_distribution.png", gender_plot, width = 8, height = 5)

# 3. Termination reasons distribution with visualization
if (sum(!is.na(employees_data$termreason)) > 0) {
  term_reasons <- employees_data %>%
    filter(!is.na(termreason)) %>%
    group_by(termreason) %>%
    summarise(count = n()) %>%
    inner_join(separation_reason_data, by = c("termreason" = "Separationtypeid"))
  
  cat("\nTermination Reasons Distribution:\n")
  print(term_reasons)
  
  # Create termination reasons plot - Top 5 reasons
  top_reasons <- term_reasons %>%
    arrange(desc(count)) %>%
    slice_head(n = 5)
  
  reason_plot <- ggplot(top_reasons, aes(x = reorder(separationreason, count), y = count, fill = separationreason)) +
    geom_bar(stat = "identity") +
    coord_flip() +  # Horizontal bars for readability
    theme_minimal() +
    labs(title = "Top 5 Termination Reasons",
         x = "Reason",
         y = "Number of Employees") +
    theme(legend.position = "none")
  
  # Save the plot
  #ggsave("data/hr/termination_reasons.png", reason_plot, width = 10, height = 6)
}

# 4. Business Unit distribution with visualization
bu_distribution <- employees_data %>%
  group_by(bu) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice_head(n = 10)  # Top 10 BUs

cat("\nTop 10 Business Units by Headcount:\n")
print(bu_distribution)

# Create BU distribution plot
bu_plot <- ggplot(bu_distribution, aes(x = reorder(bu, count), y = count, fill = bu)) +
  geom_bar(stat = "identity") +
  coord_flip() +  # Horizontal bars for readability
  theme_minimal() +
  labs(title = "Top 10 Business Units by Headcount",
       x = "Business Unit",
       y = "Number of Employees") +
  theme(legend.position = "none")

# Save the plot
#ggsave("data/hr/bu_distribution.png", bu_plot, width = 10, height = 6)

# 5. Ethnicity distribution with visualization
ethnicity_distribution <- employees_data %>%
  group_by(ethnicgroup) %>%
  summarise(count = n()) %>%
  inner_join(ethnicity_data, by = "ethnicgroup")

cat("\nEthnicity Distribution:\n")
print(ethnicity_distribution)

# Create ethnicity distribution plot
ethnicity_plot <- ggplot(ethnicity_distribution, aes(x = reorder(ethnicity, count), y = count, fill = ethnicity)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Employee Distribution by Ethnicity",
       x = "Ethnicity",
       y = "Number of Employees") +
  theme(legend.position = "none")

# Save the plot
#ggsave("data/hr/ethnicity_distribution.png", ethnicity_plot, width = 9, height = 6)

# 6. Heatmap of termination rate by age group and ethnicity
term_heatmap_data <- employees_data %>%
  group_by(agegroupid, ethnicgroup) %>%
  summarise(
    total = n(),
    terminated = sum(!is.na(termdate)),
    term_rate = terminated / total
  ) %>%
  inner_join(age_groups, by = "agegroupid") %>%
  inner_join(ethnicity_data, by = "ethnicgroup")

cat("\nTermination Rates by Age Group and Ethnicity:\n")
print(term_heatmap_data)

# Create termination rate heatmap
heatmap_plot <- ggplot(term_heatmap_data, aes(x = age_category, y = ethnicity, fill = term_rate)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "red") +
  theme_minimal() +
  labs(title = "Termination Rate by Age Group and Ethnicity",
       x = "Age Group",
       y = "Ethnicity",
       fill = "Term Rate")

# Save the plot
#ggsave("data/hr/termination_heatmap.png", heatmap_plot, width = 10, height = 7)

# 7. Tenure distribution histogram
tenure_plot <- ggplot(employees_data, aes(x = tenuremonths)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "black") +
  theme_minimal() +
  labs(title = "Employee Tenure Distribution",
       x = "Tenure (Months)",
       y = "Number of Employees")

# Save the plot
#ggsave("data/hr/tenure_distribution.png", tenure_plot, width = 8, height = 5)

# 8. New hire by business unit visualization
newhire_by_bu <- employees_data %>%
  filter(isnnewhire == 1) %>%
  group_by(bu) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice_head(n = 10)

cat("\nTop 10 Business Units with New Hires:\n")
print(newhire_by_bu)

# Create new hire by BU plot
newhire_plot <- ggplot(newhire_by_bu, aes(x = reorder(bu, count), y = count, fill = bu)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 10 Business Units with New Hires",
       x = "Business Unit",
       y = "Number of New Hires") +
  theme(legend.position = "none")

# Save the plot
#ggsave("data/hr/newhire_by_bu.png", newhire_plot, width = 10, height = 6)

# Create combined dashboard with multiple plots (2x4 grid)
dashboard <- gridExtra::grid.arrange(
  age_plot, gender_plot, 
  bu_plot, ethnicity_plot,
  reason_plot, heatmap_plot,
  tenure_plot, newhire_plot,
  ncol = 2
)

# Save the dashboard
#ggsave("data/hr/hr_dashboard.png", dashboard, width = 18, height = 20)

cat("\nAll visualizations saved to the data/hr/ directory\n")
