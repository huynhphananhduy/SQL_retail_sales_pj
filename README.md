# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis    
**Database**: `sql_project1`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for me because I am starting my journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning & Preparation**: 
   - Identified and handled missing or null values across critical columns.
   - Fixed column typographical errors (renamed `quantiy` to `quantity`) to ensure schema consistency and query accuracy.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `sql_project1`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
create database sql_project1;

-- create table
drop table if exists Retail_Sales; 
create table Retail_Sales 
(
	transactions_id	int primary key, 
	sale_date date, 
	sale_time time,
	customer_id	int,
	gender	varchar(10),
	age	int,
	category varchar(30),	
	quantiy	int,
	price_per_unit	float,
	cogs	float,
	total_sale float
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.
- **Schema Standardization**: Correct typographical errors in column names (renaming `quantiy` to `quantity`) to ensure data consistency.

```sql
-- first observation of the new table 
select *
from retail_sales
limit 10

-- count total rows
select count(*)
from retail_sales

-- Standardize column name: fix typo 'quantiy' to 'quantity'
alter table retail_sales
rename column quantiy to quantity

-- finding where customer's buying history is null and cleaning it 
-- ( I choose to delete the entire rows that contain too many null values )
select *
from retail_sales
where transactions_id is null
or sale_date is null
or customer_id is null
or gender is null
or category is null
or quantity is null
or price_per_unit is null
or cogs is null
or total_sale is null

-- ----- --
delete from retail_sales
where quantity is null
and price_per_unit is null
and cogs is null
and total_sale is null

-- how many sales records do we have left ?
select count(*) total_sales
from retail_sales

-- how many customers do we have left ?
select count(distinct customer_id) total_customers
from retail_sales

-- how many categories do we have ?
select distinct category 
from retail_sales

-- THIS IS THE END OF DATA EXPLORATION!!
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05'**:
```sql
select *
from retail_sales
where sale_date = '2022-11-05'
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
select *
from retail_sales
where 1 = 1
and category = 'Clothing'
and quantity >= 4
and (extract(month from sale_date) = 11 and extract(year from sale_date) = 2022)

-- ==> I noticed that there are no transactions with a quantity greater than 4
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category**:
```sql
select category 
	, sum(total_sale) total_sale
from retail_sales
group by 1
order by 2 desc

-- ==> I noticed that 'Electronics' category contributed the most to company's revenue
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category**:
```sql
select avg(age) average_age
from retail_sales
where category= 'Beauty'

-- ==> Middle-aged customers (around 40 years old) are the primary buyers of 'Beauty' category
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000**:
```sql
select transactions_id
	, total_sale
from retail_sales
where total_sale > 1000
order by 2 desc, 1

-- ==> A total of 306 transactions generated more than 1000 in sales
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category**:
```sql
select gender
	, category
	, count(transactions_id) as total_transactions
from retail_sales
group by 1,2
order by 1 desc, 3 desc

-- ==> 'Clothing' is the top-selling category for both genders
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
with best_month as
(select to_char(sale_date, 'YYYY-MM') year_month
	, round(avg(total_sale)::numeric,2) average_sale
	, rank() over(partition by extract(year from sale_date) order by(avg(total_sale)) desc) ranking_
from retail_sales
group by 1, extract(year from sale_date))
select best_month.*
from best_month
where ranking_ = 1

-- ==> July 2022 and February 2023 recorded the highest average revenues, at nearly $541.34 and $535.53 respectively
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales for each year**:
```sql
select year_
	, customer_id
	, sale
from 
(select extract(year from sale_date) year_
	, customer_id
	, sum(total_sale) as sale
	, rank() over(partition by extract(year from sale_date) order by sum(total_sale) desc) as rank_
from retail_sales
group by 1,2) t 
where rank_ <= 5

-- ==> High-value customers spending expanded significantly in 2023, with top 5 individual spending range
-- from $21,525 to $35,380, compared to $8180-$10,590 in 2022
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category**:
```sql
select category
	, count(distinct customer_id) unique_customers
from retail_sales
group by 1
 
-- ==> The number of unique customers is relatively evenly distributed across all three product categories, ranging from 141 to 149
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
select case 
	when extract(hour from sale_time) < 12 then 'Morning'
	when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
	when extract(hour from sale_time) > 17 then 'Evening'
	end as Shift
	, count(transactions_id) as orders
from retail_sales
group by 1

-- ==> Order volume peaked significantly during the evening shift, 
-- reaching 1,062 orders (accounting for over 50% of total orders)

	-- ----- -- Is there any seasonal trend ?
	select case 
		when extract(hour from sale_time) < 12 then 'Morning'
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		when extract(hour from sale_time) > 17 then 'Evening'
		end as Shift
		, extract(year from sale_date) year_
		, extract(month from sale_date) month_
		, count(transactions_id) as orders
	from retail_sales
	group by 1,2,3
	order by 2, 4 desc

-- ==> In Q4 (October to December), evening orders consistently spiked across all three months, 
-- indicating a strong year-end shopping trend during night hours
```

## Findings

- **Customer Demographics & Behavior**: Middle-aged customers (around 40 years old) are the primary buyers in the 'Beauty' category. Meanwhile, 'Clothing' serves as the top-selling category across both genders, with unique customer reach evenly distributed across all three product categories (ranging from 141 to 149 unique buyers).
- **Category & High-Value Transactions**: 'Electronics' contributed the most to overall revenue. Furthermore, a total of 306 transactions generated more than $1,000 in sales.
- **Top Customer Growth**: High-value customer spending expanded significantly in 2023, with the top 5 individual spendings ranging from $21,525 to $35,380, compared to $8,180–$10,590 in 2022.
- **Sales Trends & Peak Months**: July 2022 and February 2023 recorded the highest average monthly revenues, reaching nearly $541.34 and $535.53 respectively.
- **Operational Shifts & Seasonality (Key Insight)**: Order volume peaked significantly during the evening shift (>5 PM), reaching 1,062 orders and accounting for over 50% of total transactions. Specifically in Q4 (October to December), evening orders consistently spiked across all three months, indicating a strong year-end night-time shopping behavior.

## Reports

- **Sales & Category Summary**: Detailed breakdown of overall revenue by category, highlighting 'Electronics' as the primary revenue generator and 'Clothing' as the top volume category for both male and female buyers.
- **Customer Segmentation Report**: Analysis of customer demographics (focusing on middle-aged Beauty buyers), unique customer distribution, and VIP customer spending trends year-over-year.
- **Time-Based & Shift Analysis**: Summary of monthly average sales performance alongside time-of-day order distributions, pinpointing the evening shift as the dominant operational window—especially during the Q4 peak season.

## Conclusion

This project provides a comprehensive business-driven SQL analysis of retail sales data, unlocking actionable insights into customer purchasing patterns, category performance, and operational trends. The key takeaway reveals that customer engagement is heavily concentrated in the evening hours (over 50% of orders), with a pronounced seasonal surge in Q4. These findings strongly suggest that business strategy should prioritize inventory management, targeted marketing promotions, and operational support during evening peak hours to maximize year-end revenue potential.



## Author - Huynh Phan Anh Duy 

This project is part of my Data Analyst Portfolio, showcasing practical SQL analytical skills, database management, and business insight derivation.

- **LinkedIn**: www.linkedin.com/in/huynh-phan-anh-duy-1128d
- **GitHub**: https://github.com/huynhphananhduy
- **Email**: anhduy281107@gmail.com
