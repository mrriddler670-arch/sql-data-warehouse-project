-- Calculate the total sales per month
-- and the running total of sales over time

select 
order_date,
total_sales,
sum(total_sales) over (order by order_date) running_total_sales
from
(Select
DATETRUNC(month,order_date) order_date,
SUM(sales_amount) total_sales
from
gold.fact_sales
where order_date is not null
group by DATETRUNC(month,order_date)
)t

-- limit the running total for only one year
select 
order_date,
total_sales,
sum(total_sales) over (Partition by order_date order by order_date) running_total_sales
from
(Select
DATETRUNC(month,order_date) order_date,
SUM(sales_amount) total_sales
from
gold.fact_sales
where order_date is not null
group by DATETRUNC(month,order_date)
)t

-- Moving Average
select 
order_date,
total_sales,
sum(total_sales) over (order by order_date) running_total_sales,
avg(avg_price) over (order by order_date) moving_average_price
from
(Select
DATETRUNC(month,order_date) order_date,
SUM(sales_amount) total_sales,
AVG(price) avg_price
from
gold.fact_sales
where order_date is not null
group by DATETRUNC(month,order_date)
)t
