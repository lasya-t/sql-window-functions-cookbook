-- Q13. Percentile rank of each order's value within its month (is this a big order for that month?).
SELECT order_id, date_trunc('month', order_date) AS month, ROUND(revenue, 2) AS revenue,
       ROUND(PERCENT_RANK() OVER (PARTITION BY date_trunc('month', order_date) ORDER BY revenue), 3) AS pct_rank,
       ROUND(CUME_DIST()    OVER (PARTITION BY date_trunc('month', order_date) ORDER BY revenue), 3) AS cume_dist
FROM order_revenue
QUALIFY pct_rank >= 0.99
ORDER BY month, revenue DESC;
