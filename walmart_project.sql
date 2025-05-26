--DATA EXPLORATION

-- Retrieves all rows and columns from the walmart table
SELECT * FROM walmart;

-- Counts the total number of rows (transactions) in the walmart table
SELECT COUNT(*) FROM walmart;

-- Retrieves all unique payment methods used in the walmart table
SELECT DISTINCT payment_method FROM walmart;

-- Counts the total number of transactions for each unique payment method
SELECT
	DISTINCT payment_method,
	COUNT(*) AS "Total Transactions"
FROM walmart
GROUP BY payment_method;

-- Counts the number of unique branches in the walmart table
SELECT COUNT(DISTINCT branch) FROM walmart;

-- Retrieves the maximum, minimum, and average quantity (rounded) of items sold
SELECT MAX(quantity), MIN(quantity), ROUND(AVG(quantity)) FROM walmart;


-- Business Problems

--Q.1 Find different payment method, number of qty sold and number of transactions

SELECT
	DISTINCT(payment_method),
	COUNT(*) AS 'Total Transactions',
	COUNT(quantity) AS 'Number of quantity sold'
FROM walmart
GROUP BY payment_method;


--Q.2 Identify the highest-rated category in each branch, displaying the branch, category and avg rating

SELECT*
FROM
(
	SELECT
		branch,
		category,
		AVG(rating) AS Avg_Rating,
		RANK () OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank 
	FROM walmart
	GROUP BY branch, category
)
WHERE rank = 1;

--Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM
(
	SELECT
		branch,
		date,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'Day') AS day,
		COUNT(*) AS no_trans,
		RANK () OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY branch, date
)
WHERE rank =1

--Q.4  Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT
	payment_method,
	SUM(quantity) as Total_qty
FROM walmart
GROUP BY payment_method;




--Q.5 Determine the average, minimum, and maximum rating of category for each city. 
	-- List the city, average_rating, min_rating, and max_rating.

SELECT
	city,
	category,
	ROUND(AVG(rating)::NUMERIC,1) as avg_rating,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating
FROM walmart
GROUP BY city, category;


--Q.6 Calculate the total profit for each category by considering total_profit as
	-- (unit_price * quantity * profit_margin). 
	-- List category and total_profit, ordered from highest to lowest profit.

SELECT
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY category

--Q.7 Determine the most common payment method for each Branch. 
	-- Display Branch and the preferred_payment_method.

SELECT * FROM	
(
	SELECT
		branch,
		COUNT(*),
		payment_method AS preferred,
		RANK () OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY branch, preferred
)
WHERE rank = 1;

--Q.8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
	-- Find out each of the shift and number of invoices

SELECT 
	branch,
	CASE
		WHEN EXTRACT(HOUR FROM (time::time))< 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		ELSE 'EVENING'
	END	day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1,3 DESC;

--Q.9 Identify 5 branch with highest decrese ratio in 
	-- revevenue compare to last year(current year 2023 and last year 2022)
	-- rdr == last_rev-cr_rev/ls_rev*100

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

