-- Q10. Monthly signup cohorts: % of each cohort ordering N months after signup.
WITH activity AS (
    SELECT c.customer_id,
           date_trunc('month', c.signup_date) AS cohort,
           date_diff('month', date_trunc('month', c.signup_date), date_trunc('month', o.order_date)) AS month_n
    FROM customers c JOIN orders o USING (customer_id)
), sizes AS (
    SELECT date_trunc('month', signup_date) AS cohort, COUNT(*) AS cohort_size FROM customers GROUP BY 1
)
SELECT a.cohort, s.cohort_size,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN month_n = 1 THEN customer_id END) / s.cohort_size, 1) AS m1_pct,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN month_n = 3 THEN customer_id END) / s.cohort_size, 1) AS m3_pct,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN month_n = 6 THEN customer_id END) / s.cohort_size, 1) AS m6_pct
FROM activity a JOIN sizes s USING (cohort)
WHERE a.cohort <= DATE '2024-06-01'
GROUP BY a.cohort, s.cohort_size
ORDER BY a.cohort;
