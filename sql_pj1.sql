-- create database for my first sql project
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
	category varchar(25),	
	quantity	int,
	price_per_unit	float,
	cogs	float,
	total_sale float
)

-- first observation of the new table 
select *
from retail_sales
limit 10

-- count total rows
select count(*)
from retail_sales

-- change the column name from 'quantiy' to 'quantity' ( I mistakenly create a column named 'quantiy' )
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
where transactions_id is null
or sale_date is null
or customer_id is null
or gender is null
or category is null
or quantity is null
or price_per_unit is null
or cogs is null
or total_sale is null

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


-- DATA ANALYSIS!!

-- 1.Write a SQL query to retrieve all columns for sales made on '2022-11-05:
select *
from retail_sales
where sale_date = '2022-11-05'

-- 2.Write a SQL query to retrieve all transactions where the category is 'Clothing' 
-- and the quantity sold is more than 4 in the month of Nov-2022:
select *
from retail_sales
where 1 = 1
and category = 'Clothing'
and quantity >= 4
and (extract(month from sale_date) = 11 and extract(year from sale_date) = 2022)

-- ==> I noticed that there are no transactions with a quantity greater than 4

-- 3.Write a SQL query to calculate the total sales (total_sale) for each category:
select category 
	, sum(total_sale) total_sale
from retail_sales
group by 1
order by 2 desc

-- ==> I noticed that 'Electronics' category contributed the most to company's revenue

-- 4.Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category:
select avg(age) average_age
from retail_sales
where category= 'Beauty'

-- ==> Middle-aged customers (around 40 years old) are the primary buyers of 'Beauty' category

-- 5.Write a SQL query to find all transactions where the total_sale is greater than 1000:
select transactions_id
	, total_sale
from retail_sales
where total_sale > 1000
order by 2 desc, 1

-- ==> A total of 306 transactions generated more than 1000 in sales

--  6.Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category:
select gender
	, category
	, count(transactions_id) as total_transactions
from retail_sales
group by 1,2
order by 1 desc, 3 desc

-- ==> 'Clothing' is the top-selling category for both genders

-- 7.Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
with best_month as
(select to_char(sale_date, 'YYYY-MM') year_month
	, round(avg(total_sale)::numeric,2) average_sale
	, rank() over(partition by extract(year from sale_date) order by(avg(total_sale)) desc) ranking_
from retail_sales
group by 1, extract(year from sale_date))
select best_month.*
from best_month
where ranking_ = 1

-- ==> July 2022 and February 2023 recorded the highest average revenues, at nearly $541M and $535M respectively

-- 8.Write a SQL query to find the top 5 customers based on the highest total sales for each year:
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

-- 9.Write a SQL query to find the number of unique customers who purchased items from each category:
select category
	, count(distinct customer_id) unique_customers
from retail_sales
group by 1
 
-- ==> The number of unique customers evenly distributed across all three product categories, ranging from 141 to 149

-- 10.Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
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
-- indicating a strong year-end shopping trend during night hours. 

