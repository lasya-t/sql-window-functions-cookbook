-- Q3. Month-over-month revenue growth.
-- LAG() looks at the previous row in the window.
WITH monthly AS (
    SELECT date_trunc('month', order_date) AS month, SUM(revenue) AS revenue
    FROM order_revenue GROUP BY 1
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month), 1) AS mom_pct
FROM monthly
ORDER BY month;
