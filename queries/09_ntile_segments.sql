-- Q9. Split customers into revenue quartiles and profile each quartile.
WITH cust AS (
    SELECT customer_id, SUM(revenue) AS revenue, COUNT(*) AS orders
    FROM order_revenue GROUP BY customer_id
), q AS (
    SELECT *, NTILE(4) OVER (ORDER BY revenue DESC) AS quartile FROM cust
)
SELECT quartile, COUNT(*) AS customers, ROUND(AVG(revenue), 0) AS avg_revenue,
       ROUND(AVG(orders), 1) AS avg_orders,
       ROUND(100 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS pct_of_revenue
FROM q GROUP BY quartile ORDER BY quartile;
