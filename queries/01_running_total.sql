-- Q1. Daily revenue with a running total for the year.
-- Window: SUM() OVER (ORDER BY ...) with the default frame = all rows up to the current one.
SELECT order_date,
       ROUND(SUM(revenue), 2)                                  AS daily_revenue,
       ROUND(SUM(SUM(revenue)) OVER (ORDER BY order_date), 2)  AS running_total
FROM order_revenue
WHERE order_date >= DATE '2024-01-01'
GROUP BY order_date
ORDER BY order_date;
