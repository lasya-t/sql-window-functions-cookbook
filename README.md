# SQL Window Functions Cookbook

15 business questions answered with window functions, each in its own `.sql` file with a comment explaining the technique. The queries run against a small retail warehouse (customers, products, orders, order items), and the tests check the key answers against an independent pandas calculation.

The queries run on DuckDB, and all but a few work unchanged on Postgres or Snowflake. `QUALIFY` is DuckDB/Snowflake syntax; on Postgres, wrap the query in a subquery and filter with `WHERE` instead.

## The questions

| # | Question | Technique |
|---|---|---|
| 01 | Daily revenue with a running total | `SUM() OVER (ORDER BY)` |
| 02 | 7-day moving average | frame `ROWS BETWEEN 6 PRECEDING AND CURRENT ROW` |
| 03 | Month-over-month growth | `LAG()` |
| 04 | Top 3 customers per state | `ROW_NUMBER()` + `QUALIFY` |
| 05 | Ties: row_number vs rank vs dense_rank | named `WINDOW` clause |
| 06 | First and last order per customer | `FIRST_VALUE` / `LAST_VALUE` with a full frame |
| 07 | Average days between repeat orders | `LAG()` per customer |
| 08 | Product share of category, category share of total | `SUM() OVER (PARTITION BY)` and `OVER ()` |
| 09 | Revenue quartiles and what each contributes | `NTILE(4)` |
| 10 | Signup cohort retention (month 1, 3, 6) | cohort bucketing + `date_diff` |
| 11 | Longest streaks of high-value days | gaps and islands: `date − ROW_NUMBER()` |
| 12 | Keep only the latest record per key (dedup) | `ROW_NUMBER() ... = 1` |
| 13 | Top 1% orders within each month | `PERCENT_RANK`, `CUME_DIST` |
| 14 | New vs returning customer revenue | first-order flag with `ROW_NUMBER()` |
| 15 | Cumulative distinct customers | running sum of first-order counts (most engines don't support `COUNT(DISTINCT) OVER`) |

## Example output

```
=== Q05. ROW_NUMBER vs RANK vs DENSE_RANK on tied values
   category  product_id  units  row_number  rank  dense_rank
Accessories          31   1811           1     1           1
Accessories          35   1810           2     2           2
Accessories          33   1810           3     2           2     <- tie
Accessories          40   1789           4     4           3

=== Q09. Revenue quartiles
 quartile  customers  avg_revenue  avg_orders  pct_of_revenue
        1        494      26049.0        17.6            41.5
        4        493       5501.0         4.9             8.7
```

The top quarter of customers brings in 41.5% of revenue.

## Common mistakes the queries show how to avoid
- `LAST_VALUE` without `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` just returns the current row (Q06).
- Window functions run after `GROUP BY`, so `SUM(SUM(x)) OVER ()` is valid and useful (Q01, Q09).
- `RANK` leaves gaps after ties and `DENSE_RANK` doesn't. Choose based on whether "top 3" should mean 3 rows or 3 values (Q05).

## How to run

```bash
pip install -r requirements.txt
python run_all.py              # all queries
python run_all.py --only 11    # one query
python build_db.py             # write retail.duckdb to explore in the DuckDB CLI
pytest
```

## Next steps
- Add sessionization and funnel queries on event data
- Add a Postgres docker-compose so every query is tested on both engines
