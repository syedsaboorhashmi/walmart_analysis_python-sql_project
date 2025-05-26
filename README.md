# Walmart Data Analysis: End-to-End SQL + Python Project

## Project Overview

This project delivers a comprehensive data analysis workflow aimed at uncovering valuable business insights from Walmart’s sales data. It leverages Python for data manipulation and analysis, employs SQL for complex data queries, and applies systematic problem-solving methods to address important business challenges.

---

## Project Steps

### 1. Environment Preparation
   - **Tools Utilized**: Visual Studio Code, Python, SQL (MySQL & PostgreSQL)
   - **Objective**: Set up a well-organized workspace in VS Code, ensuring all directories and files are structured for efficient data analysis.

### 2. Kaggle API Configuration
   - **API Access**: Retrieve your Kaggle API credentials from your Kaggle account settings.
   - **Setup**: Place the `kaggle.json` file in your `.kaggle` directory and use the command line to download datasets with `kaggle datasets download -d <dataset-path>`.

### 3. Acquire Walmart Sales Data
   - **Source**: Download the Walmart sales dataset using the Kaggle API.
   - **Reference**: [Walmart Sales Dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets)

### 4. Install Dependencies & Import Data
   - **Install Packages**: Use pip to install required libraries:
     ```bash
     pip install pandas sqlalchemy psycopg2
     ```
   - **Data Loading**: Import the dataset into a Pandas DataFrame:
     ```python
     import pandas as pd
     df = pd.read_csv('Walmart.csv', encoding_errors='ignore')
     df.info()
     df.head()
     ```

### 5. Initial Data Exploration
   - **Purpose**: Get familiar with the dataset by examining its structure, column types, and summary statistics.
   - **Techniques**: Use methods like:
     ```python
     df.info()
     df.describe()
     df.head()
     ```

### 6. Data Cleaning Process
   - **Duplicate Removal**: Detect and eliminate duplicate records:
     ```python
     df.duplicated().sum()
     df.drop_duplicates(inplace=True)
     ```
   - **Missing Data Handling**: Identify and address null values:
     ```python
     df.isnull().sum()
     df.dropna(inplace=True)
     ```
   - **Data Type Corrections**: Convert columns to suitable data types:
     ```python
     # Remove '$' from unit_price and convert to float
     df['unit_price'] = df['unit_price'].str.replace('$', '')
     df['unit_price'] = df['unit_price'].astype(float)
     ```
   - **Validation**: Re-examine the cleaned data:
     ```python
     df.info()
     ```

### 7. Feature Engineering
   - **New Calculations**: Add a `total` column by multiplying `unit_price` and `quantity`:
     ```python
     df['total'] = df['unit_price'] * df['quantity']
     ```
   - **Column Standardization**: Convert all column names to lowercase:
     ```python
     df.columns = df.columns.str.lower()
     ```

### 8. Export Cleaned Data
   - **CSV Output**: Save the cleaned DataFrame as a new CSV file:
     ```python
     df.to_csv('walmart_clean_data.csv', index=False)
     ```

### 9. Database Integration
   - **Database Connection**: Establish a connection to PostgreSQL using SQLAlchemy:
     ```python
     from sqlalchemy import create_engine
     engine_psql = create_engine("postgresql+psycopg2://postgres:YOUR_PASSWORD@localhost:YOUR_PORT/walmart_db")
     ```
   - **Data Upload**: Transfer the cleaned dataset into PostgreSQL:
     ```python
     df.to_sql(name='walmart', con=engine_psql, if_exists='append', index=False)
     ```
   - **Verification**: Run sample queries in PostgreSQL to ensure the data has been imported correctly.

### 10. SQL-Based Business Analysis
   - **Advanced Querying**: Use SQL to answer key business questions, such as:
     - Analyzing revenue by branch and product category.
     - Determining top-performing categories and branches.
     - Examining sales by time, city, and payment method.
     - Identifying peak sales periods and customer trends.
     - Evaluating profit margins across different segments.


## Data Exploration in SQL

**1. Retrieve all rows and columns from the walmart table**
```sql
SELECT * FROM walmart;
```
*Insight:* View the entire dataset for a complete overview.

---

**2. Count the total number of rows (transactions) in the walmart table**
```sql
SELECT COUNT(*) FROM walmart;
```
*Insight:* Shows the total number of transactions recorded.

---

**3. Retrieve all unique payment methods used**
```sql
SELECT DISTINCT payment_method FROM walmart;
```
*Insight:* Identifies all payment methods available to customers.

---

**4. Count the total number of transactions for each unique payment method**
```sql
SELECT
    payment_method,
    COUNT(*) AS "Total Transactions"
FROM walmart
GROUP BY payment_method;
```
*Insight:* Reveals the popularity of each payment method.

---

**5. Count the number of unique branches**
```sql
SELECT COUNT(DISTINCT branch) FROM walmart;
```
*Insight:* Shows how many different branches are present in the dataset.

---

**6. Retrieve the maximum, minimum, and average quantity (rounded) of items sold**
```sql
SELECT MAX(quantity), MIN(quantity), ROUND(AVG(quantity)) FROM walmart;
```
*Insight:* Provides a summary of item quantities per transaction.

---

## Business Questions & SQL Solutions

### Q1. Find different payment methods, number of quantities sold, and number of transactions

```sql
SELECT
    payment_method,
    COUNT(*) AS "Total Transactions",
    SUM(quantity) AS "Number of quantity sold"
FROM walmart
GROUP BY payment_method;
```
*Insight:* Compares transaction volume and items sold by payment method.

---

### Q2. Identify the highest-rated category in each branch

```sql
SELECT branch, category, Avg_Rating FROM (
    SELECT
        branch,
        category,
        AVG(rating) AS Avg_Rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank 
    FROM walmart
    GROUP BY branch, category
) sub
WHERE rank = 1;
```
*Insight:* Highlights the top-rated product category for each branch.

---

### Q3. Identify the busiest day for each branch based on the number of transactions

```sql
SELECT branch, date, day, no_trans FROM (
    SELECT
        branch,
        date,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'Day') AS day,
        COUNT(*) AS no_trans,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, date
) sub
WHERE rank = 1;
```
*Insight:* Finds the single busiest day for each branch.

---

### Q4. Calculate the total quantity of items sold per payment method

```sql
SELECT
    payment_method,
    SUM(quantity) as Total_qty
FROM walmart
GROUP BY payment_method;
```
*Insight:* Shows which payment methods are associated with the highest sales volume.

---

### Q5. Determine the average, minimum, and maximum rating of each category for every city

```sql
SELECT
    city,
    category,
    ROUND(AVG(rating)::NUMERIC,1) as avg_rating,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating
FROM walmart
GROUP BY city, category;
```
*Insight:* Evaluates customer satisfaction by city and category.

---

### Q6. Calculate the total profit for each category

```sql
SELECT
    category,
    SUM(total) as total_revenue,
    SUM(total * profit_margin) as profit
FROM walmart
GROUP BY category
ORDER BY profit DESC;
```
*Insight:* Identifies the most profitable product categories.

---

### Q7. Determine the most common payment method for each branch

```sql
SELECT branch, preferred FROM (
    SELECT
        branch,
        payment_method AS preferred,
        COUNT(*) as cnt,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
    FROM walmart
    GROUP BY branch, payment_method
) sub
WHERE rank = 1;
```
*Insight:* Reveals the preferred payment method at each branch.

---

### Q8. Categorize sales into MORNING, AFTERNOON, EVENING shifts and count invoices

```sql
SELECT 
    branch,
    CASE
        WHEN EXTRACT(HOUR FROM (time::time)) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS invoice_count
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, invoice_count DESC;
```
*Insight:* Analyzes sales activity by time of day for each branch.

---

### Q9. Identify 5 branches with the highest revenue decrease ratio from 2022 to 2023

```sql
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
)
SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS cr_year_revenue,
    ROUND(
        (ls.revenue - cs.revenue)::NUMERIC / ls.revenue::NUMERIC * 100, 
        2
    ) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;
```
*Insight:* Pinpoints branches with the most significant revenue drops, helping target areas for improvement.

---

# Conclusion

This project demonstrates a complete end-to-end data analysis workflow, from data acquisition and cleaning to advanced SQL-based business insights, using real-world Walmart sales data. By leveraging Python for data wrangling and PostgreSQL for analytical queries, I have showcased my ability to extract actionable insights, solve business problems, and communicate findings clearly.

The skills and techniques applied throughout this project—including data preprocessing, feature engineering, database integration, and complex SQL analysis—reflect my readiness for data analyst and analyst roles. This work highlights my proficiency in handling large datasets, uncovering trends, and delivering data-driven recommendations that can support strategic business decisions.