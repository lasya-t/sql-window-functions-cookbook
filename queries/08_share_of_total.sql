-- Q8. Each category's share of total revenue, and each product's share within its category.
WITH prod AS (
    SELECT p.category, p.product_id, SUM(i.qty * p.price) AS revenue
    FROM order_items i JOIN products p USING (product_id)
    GROUP BY ALL
)
SELECT category, product_id, ROUND(revenue, 2) AS revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (PARTITION BY category), 1) AS pct_of_category,
       ROUND(100 * SUM(revenue) OVER (PARTITION BY category) / SUM(revenue) OVER (), 1) AS category_pct_of_total
FROM prod
ORDER BY category, revenue DESC;
