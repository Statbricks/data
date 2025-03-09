# HR Analytics Synthetic Dataset

## Overview

This synthetic dataset is designed for Power BI training in HR analytics. It contains realistic but fictional employee data that allows for comprehensive workforce analysis and dashboard creation. The dataset follows a star schema design with one fact table (employees) and seven dimension tables.

## Table Structure

### Fact Table

#### `employees`
The main fact table containing employee records with the following fields:

| Field | Description | Data Type |
|-------|-------------|-----------|
| date | Current reporting date (fixed at 2023-12-31) | Date |
| employeeid | Unique identifier for each employee | Integer |
| gender | Employee gender (references gender.id) | Integer |
| age | Employee age in years | Integer |
| ethnicgroup | Employee ethnicity code (references ethnicity.ethnicgroup) | Text |
| fp | Employment type code (F=Full-time, P=Part-time, etc.) | Text |
| termdate | Date of termination (if applicable, NULL if still employed) | Date |
| isnnewhire | Flag indicating if employee was hired in last 90 days (1=Yes, 0=No) | Integer |
| bu | Business unit name (references BU.bu) | Text |
| hiredate | Date employee was hired | Date |
| paytypeid | Payment type code (references paytype.paytypeid) | Integer |
| termreason | Reason for termination code (references separationreason.Separationtypeid) | Integer |
| agegroupid | Age group code (references age_group.agegroupid) | Integer |
| tenuredays | Number of days employee has been with company | Integer |
| tenuremonths | Number of months employee has been with company | Integer |
| badhire | Flag indicating if employee was terminated within 90 days (1=Yes, 0=No) | Integer |

### Dimension Tables

#### `age_group`
Age range categorization:

| Field | Description | Data Type |
|-------|-------------|-----------|
| agegroupid | Unique identifier for each age group | Integer |
| age_category | Age range description (e.g., "18-24", "25-34") | Text |

#### `BU` (Business Units)
Organizational structure information:

| Field | Description | Data Type |
|-------|-------------|-----------|
| bu | Business unit name | Text |
| regionseq | Region sequence number | Integer |
| vp | Vice President name for the business unit | Text |
| region | Geographic region | Text |

#### `ethnicity`
Employee ethnicity classifications:

| Field | Description | Data Type |
|-------|-------------|-----------|
| ethnicgroup | Single-character ethnicity code | Text |
| ethnicity | Full ethnicity description | Text |

#### `fp` (Full-time/Part-time)
Employment type classifications:

| Field | Description | Data Type |
|-------|-------------|-----------|
| fp | Single-character employment type code | Text |
| fpdescription | Full employment type description | Text |

#### `gender`
Gender classifications:

| Field | Description | Data Type |
|-------|-------------|-----------|
| id | Unique identifier for gender | Integer |
| gender | Gender description | Text |
| sort | Sort order value | Integer |

#### `paytype`
Employee payment classifications:

| Field | Description | Data Type |
|-------|-------------|-----------|
| paytypeid | Unique identifier for pay type | Integer |
| paytype | Payment type description (e.g., "Hourly", "Salary") | Text |

#### `separationreason`
Termination reason classifications:

| Field | Description | Data Type |
|-------|-------------|-----------|
| Separationtypeid | Unique identifier for separation reason | Integer |
| separationreason | Full description of termination reason | Text |

## Data Relationships

The dataset follows a star schema with the following relationships:

- employees.agegroupid → age_group.agegroupid
- employees.bu → BU.bu
- employees.ethnicgroup → ethnicity.ethnicgroup
- employees.fp → fp.fp
- employees.gender → gender.id
- employees.paytypeid → paytype.paytypeid
- employees.termreason → separationreason.Separationtypeid

## Data Distribution

- **Date Range**: Employee data spans from 2018-01-01 to 2023-12-31
- **Employee Count**: 1,000 synthetic employee records
- **Demographics**: Realistic distribution across age groups, gender, and ethnicity
- **Termination Rate**: Approximately 25% of employees have termination records
- **New Hires**: About 6-8% of employees are flagged as new hires
- **Bad Hires**: Approximately 1-2% of employees are flagged as bad hires (terminated within 90 days)

## Sample Analyses

This dataset supports various HR analytics scenarios, including:

1. **Workforce Demographics Analysis**
   - Distribution of employees by age, gender, ethnicity
   - Department and regional representation

2. **Turnover Analysis**
   - Voluntary vs. involuntary termination rates
   - Termination reasons by department and demographics
   - Seasonal termination patterns

3. **New Hire Analysis**
   - Quality of hire (bad hire rates)
   - New hire retention by department
   - Demographic profile of new hires

4. **Tenure Analysis**
   - Average tenure by department, role, and demographics
   - Factors correlating with longer tenure

5. **Diversity and Inclusion**
   - Representation across departments and roles
   - Trends in hiring and termination by demographic group

## Data Generation

This synthetic dataset was generated programmatically to provide realistic HR patterns while maintaining privacy since no real employee data is used. The generation logic includes:

- Realistic business unit structures with regional distribution
- Age distributions that follow typical workforce patterns
- Termination patterns that reflect real-world voluntary and involuntary separation reasons
- Tenure calculations based on hire and termination dates
- Employment type distribution across departments

## Using This Data

When working with this dataset in Power BI:

1. Import all CSV files maintaining the provided field names and data types
2. Establish relationships as described in the "Data Relationships" section
3. Create date table to enable proper time intelligence functions
4. Create calculated measures for key HR metrics (turnover rate, headcount growth, etc.)
5. Develop visualizations that provide actionable workforce insights

This dataset is ideal for learning and demonstrating HR analytics concepts, dashboard design, DAX formula writing, and data modeling in Power BI.