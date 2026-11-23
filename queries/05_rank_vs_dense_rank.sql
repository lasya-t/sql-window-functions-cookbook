-- Q5. ROW_NUMBER vs RANK vs DENSE_RANK on tied values: products ranked by units sold within category.
SELECT p.category, i.product_id, CAST(SUM(i.qty) AS BIGINT) AS units,
       ROW_NUMBER() OVER w AS row_number,
       RANK()       OVER w AS rank,
       DENSE_RANK() OVER w AS dense_rank
FROM order_items i JOIN products p USING (product_id)
GROUP BY p.category, i.product_id
WINDOW w AS (PARTITION BY p.category ORDER BY SUM(i.qty) DESC)
ORDER BY p.category, row_number;
