-- Q7. Average gap between consecutive orders per customer (repeat-purchase cadence).
WITH gaps AS (
    SELECT customer_id,
           order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS gap_days
    FROM orders
)
SELECT customer_id, COUNT(gap_days) + 1 AS orders, ROUND(AVG(gap_days), 1) AS avg_gap_days
FROM gaps
GROUP BY customer_id
HAVING COUNT(gap_days) >= 3
ORDER BY avg_gap_days
LIMIT 20;
