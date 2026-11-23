-- Q6. Each customer's first and most recent order, and days between them.
SELECT DISTINCT customer_id,
       FIRST_VALUE(order_date) OVER w AS first_order,
       LAST_VALUE(order_date)  OVER w AS last_order,
       LAST_VALUE(order_date)  OVER w - FIRST_VALUE(order_date) OVER w AS days_active
FROM orders
-- LAST_VALUE needs the full frame, otherwise it just returns the current row
WINDOW w AS (PARTITION BY customer_id ORDER BY order_date
             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
ORDER BY customer_id;
