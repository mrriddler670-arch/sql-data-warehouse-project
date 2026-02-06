/*
==============================================================================================
Product Report
==============================================================================================
Purpose:
	- This report consolidates key product metrics and behaviors.

Highlights:
	1.Gathers essential fields such as product name,category,subcategory and cost.
	2.Segments products by revenue to identity High-Performers,Mid_Range or Low-Performers.
	3.Aggergates product-level metrics:
	- total orders
	- total sales
	- total quantity sold
	- total customers (unique)
	- lifespan (in months)
	4. Calculates valualbe KPIs:
	- recency (monthssince last sale)
	- average order revenue (AOR)
	- average monthly revenue
==============================================================================================
*/

Create View gold.report_products as
With base_query As

/*---------------------------------------------------------------------------------------------
1)Base Query: Retrieves core columns from tables
----------------------------------------------------------------------------------------------*/
(
Select 
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
where order_date is not null) -- only consider valid sales dates

, product_aggregation as (
/*------------------------------------------------------------------------------------------------------
2)Product Aggregations: Summarizes key metrics at the product level
-------------------------------------------------------------------------------------------------------*/
select 
product_key,
product_name,
category,
subcategory,
cost,
Datediff(month, min(order_date), Max(order_date)) life_span,
MAX(order_date) last_sale_date,
Count(Distinct order_number) total_orders,
Count(Distinct customer_key) total_customers,
sum(sales_amount) total_sales,
SUM(quantity) total_quantity,
ROUND(AVG(CAST(sales_amount as FLOAT) / NULLIF(quantity,0)),1) avg_selling_price
from base_query
group by 
product_key,
product_name,
category,
subcategory,
cost
)

/*--------------------------------------------------------------------------------------------
3) Fianl Query: Combines all product results into one output
---------------------------------------------------------------------------------------------*/
Select 
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
DATEDIFF(MONTH,last_sale_date, GETDATE()) receny_in_months,
        Case 
        when total_sales > 50000  THEN 'High-Performer'
        when total_sales  >= 10000 Then 'Mid-Range'
        else 'Low-Perfomer'
        End as product_Segment,
life_span,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,

-- Compuate average order Revenue (AOR)
CASE WHEN total_orders = 0 THEN 0
     ELSE total_sales/total_orders 
End  as avg_order_value,

-- Compuate monthly revenue
CASE WHEN life_span = 0 THEN total_sales
     ELSE  total_sales/life_span
End As avg_monthly_revenue
from
product_aggregation
