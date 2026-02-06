/* Analyze the yearly performance of products by compairing their sales to both 
the average sales performance of the product and the pervious year's sales */

With yearly_product_sales as (
select
YEAR(f.order_date) order_year,
p.product_name,
SUM(f.sales_amount) current_sales 
from gold.fact_sales f
left join gold.dim_products p
on f.product_key = p.product_key
where order_date is not null
group by 
YEAR(f.order_date),
p.product_name
)

select 
order_year,
product_name,
current_sales,
avg(current_sales) over (partition by product_name) avg_sales,
current_sales - avg(current_sales) over (partition by product_name) diff_avg,
case when current_sales - avg(current_sales) over (partition by product_name) > 0 then 'Above Avg'
     when current_sales - avg(current_sales) over (partition by product_name) < 0 then 'Below Avg'
     else 'Avg'
end avg_change,
-- Year - over - year analysis
lag(current_sales) over (partition by product_name order by order_year) py_sales,
current_sales - lag(current_sales) over (partition by product_name order by order_year) diff_py,
case when current_sales - lag(current_sales) over (partition by product_name order by order_year) > 0 then 'Increase'
     when current_sales - lag(current_sales) over (partition by product_name order by order_year) < 0 then 'Decrease'
     else 'No Change'
end py_change
from yearly_product_sales 

