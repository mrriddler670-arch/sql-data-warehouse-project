/* Group customers into three segments based on their spending behaviour:
- Vip: Customers with at least 12 months of history and spending more than Rs.5000.
- Regular: Customers with at least 12 months of history but spending Rs.5000 or less.
- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group 
*/
With Customer_spending As(
select 
c.customer_key,
sum(f.sales_amount) total_spending,
MIN(order_date) first_order,
MAX(order_date) last_order,
DATEDIFF (month,MIN(order_date),Max(order_date)) lifespan
from gold.fact_sales f
Left Join gold.dim_customers c
on f.customer_key = c.customer_key
group by c.customer_key
)


Select 
Customer_segment,
COUNT(customer_key) total_customers
from (
select
customer_key,
case when lifespan >= 12 AND total_spending > 5000 then 'VIP'
     when lifespan >= 12 And total_spending <= 5000 Then 'Regular'
     else 'New'
end customer_segment
from Customer_spending
) t
group by customer_segment
order by total_customers desc
