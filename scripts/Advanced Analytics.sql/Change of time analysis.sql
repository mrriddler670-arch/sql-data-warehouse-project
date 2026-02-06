-- Analyze sales performance over time in year.
select 
year(order_date) order_month,
sum(sales_amount) total_sales,
count(distinct customer_key) total_customers,
sum(quantity) total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date)

-- Analyze sales performance over time in month.
select 
Month(order_date) order_month,
sum(sales_amount) total_sales,
count(distinct customer_key) total_customers,
sum(quantity) total_quantity
from gold.fact_sales
where order_date is not null
group by month(order_date)
order by month(order_date)

-- Analyze sales performance over time of a month in specific year.
select 
year(order_date) order_year,
Month(order_date) order_month,
sum(sales_amount) total_sales,
count(distinct customer_key) total_customers,
sum(quantity) total_quantity
from gold.fact_sales
where order_date is not null
group by YEAR(order_date),month(order_date)
order by YEAR(order_date),month(order_date)

-- Analyze sales performance over time of a month in specific year use a function.
select 
Datetrunc(Month,order_date) order_date,
sum(sales_amount) total_sales,
count(distinct customer_key) total_customers,
sum(quantity) total_quantity
from gold.fact_sales
where order_date is not null
group by Datetrunc(Month,order_date) 
order by Datetrunc(Month,order_date)
