-- Q2. 7-day moving average of daily revenue (smooths weekday noise).
-- Window frame: ROWS BETWEEN 6 PRECEDING AND CURRENT ROW.
WITH daily AS (
    SELECT order_date, SUM(revenue) AS revenue FROM order_revenue GROUP BY order_date
)
SELECT order_date,
       ROUND(revenue, 2) AS revenue,
       ROUND(AVG(revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS ma_7d
FROM daily
ORDER BY order_date;
