-- Q11. Gaps and islands: longest streaks of consecutive days with at least one order over $3,000.
-- Trick: date minus ROW_NUMBER() is constant within a run of consecutive dates.
WITH days AS (
    SELECT DISTINCT order_date AS d FROM order_revenue WHERE revenue > 3000
), grp AS (
    SELECT d, d - CAST(ROW_NUMBER() OVER (ORDER BY d) AS INTEGER) AS island FROM days
)
SELECT MIN(d) AS streak_start, MAX(d) AS streak_end, COUNT(*) AS days
FROM grp GROUP BY island
ORDER BY days DESC, streak_start
LIMIT 5;
