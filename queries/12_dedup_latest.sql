-- Q12. Deduplicate: keep only the latest record per key.
-- Classic CDC / slowly changing source pattern. Here: each customer's most recent order.
SELECT *
FROM order_revenue
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC, order_id DESC) = 1
ORDER BY customer_id
LIMIT 20;
