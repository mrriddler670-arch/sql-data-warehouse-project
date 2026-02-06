/*
==============================================================================================
Customer Report 
==============================================================================================
Purpose:
        - This Report consolidates Key Customer metrics and behaviors

Highlights:
        1.Gathers essential fields such as names,ages, and transaction details.
        2.Segments customers into categories (VIP,Regular,New) and age groups.
        3.Aggregates customer - level metrics:
             - total orders
             - total sales
             - total quantity purchased
             - total products 
             - lifespan (in months)
        4.Calulates valuable KPIs:
             - recency (months since last order)
             - average order value
             - average monthly spend
===============================================================================================
*/
Create View gold.report_customers as
With base_query As
/*---------------------------------------------------------------------------------------------
1)Base Query: Retrieves core columns from tables
----------------------------------------------------------------------------------------------*/
(
Select 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ',c.last_name) customer_name,
DATEDIFF(year,c.birthdate,GETDATE()) age
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
where order_date is not null)

, customer_aggregation as (
/*------------------------------------------------------------------------------------------------------
2)Customer Aggregations: Summarizes key metrics at the customer level
-------------------------------------------------------------------------------------------------------*/
select 
customer_key,
customer_number,
customer_name,
age,
Count(Distinct order_number) total_orders,
sum(sales_amount) total_sales,
SUM(quantity) total_quantity,
Count(distinct product_key) total_products,
max(order_date) last_order_date,
Datediff(month, min(order_date), Max(order_date)) life_span
from base_query
group by 
customer_key,
customer_number,
customer_name,
age 
)

Select 
customer_key,
customer_number,
customer_name,
age,
        Case 
        when age < 20  THEN 'Under 20'
        when age between 20 and 29 THEN '20-29'
        when age between 30 and 39 THEN '30-39'
        when age between 40 and 49 THEN '40-49'
        else '50 and above'
        End Age_group,
        Case 
        when life_span >= 12 AND total_sales > 5000 THEN 'VIP'
        when life_span >= 12 AND total_sales <= 5000 THEN 'Regular'
        else 'NEW'
        End customer_segment,
last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) receny,
total_orders,
total_sales,
total_quantity,
total_products,
life_span,

-- Compuate average order value(AOV)
CASE WHEN total_orders = 0 THEN 0
     ELSE total_sales/total_orders 
End  as avg_order_value,

-- Compuate average monthly spend
CASE WHEN life_span = 0 THEN total_sales
     ELSE  total_sales/life_span
End As avg_monthly_spend
from
customer_aggregation
