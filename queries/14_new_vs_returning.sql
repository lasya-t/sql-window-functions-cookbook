-- Q14. Monthly revenue from new vs returning customers.
-- An order is "new" if it is the customer's first order ever.
WITH tagged AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date, order_id) = 1 AS is_first
    FROM order_revenue
)
SELECT date_trunc('month', order_date) AS month,
       ROUND(SUM(CASE WHEN is_first THEN revenue END), 0)     AS new_customer_revenue,
       ROUND(SUM(CASE WHEN NOT is_first THEN revenue END), 0) AS returning_revenue,
       ROUND(100 * SUM(CASE WHEN NOT is_first THEN revenue END) / SUM(revenue), 1) AS returning_pct
FROM tagged GROUP BY 1 ORDER BY 1;
