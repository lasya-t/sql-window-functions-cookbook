-- Q4. Top 3 customers by lifetime revenue in each state.
-- ROW_NUMBER() partitioned by state, then filter with QUALIFY.
SELECT c.state, r.customer_id, ROUND(SUM(r.revenue), 2) AS lifetime_revenue,
       ROW_NUMBER() OVER (PARTITION BY c.state ORDER BY SUM(r.revenue) DESC) AS rnk
FROM order_revenue r JOIN customers c USING (customer_id)
GROUP BY c.state, r.customer_id
QUALIFY rnk <= 3
ORDER BY c.state, rnk;
