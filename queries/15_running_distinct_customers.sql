-- Q15. Cumulative distinct customers over time (no COUNT(DISTINCT) OVER in most engines,
-- so count each customer once on their first order date, then take a running sum).
WITH firsts AS (
    SELECT customer_id, MIN(order_date) AS first_date FROM orders GROUP BY customer_id
)
SELECT date_trunc('month', first_date) AS month,
       COUNT(*) AS new_customers,
       CAST(SUM(COUNT(*)) OVER (ORDER BY date_trunc('month', first_date)) AS BIGINT) AS cumulative_customers
FROM firsts GROUP BY 1 ORDER BY 1;
