"""Create a small retail warehouse in DuckDB: customers, products, orders, order_items."""
from pathlib import Path

import duckdb
import numpy as np
import pandas as pd


def build(db_path: str | Path = ":memory:", seed: int = 0) -> duckdb.DuckDBPyConnection:
    rng = np.random.default_rng(seed)
    n_cust, n_orders = 2_000, 30_000

    customers = pd.DataFrame(
        {
            "customer_id": np.arange(1, n_cust + 1),
            "state": rng.choice(["PA", "NJ", "NY", "DE", "MD"], n_cust),
            "signup_date": pd.Timestamp("2023-01-01") + pd.to_timedelta(rng.integers(0, 700, n_cust), unit="D"),
        }
    )
    products = pd.DataFrame(
        {
            "product_id": np.arange(1, 41),
            "category": np.repeat(["Phones", "Tablets", "Wearables", "Accessories"], 10),
            "price": np.concatenate([
                rng.uniform(400, 1300, 10), rng.uniform(250, 900, 10),
                rng.uniform(150, 450, 10), rng.uniform(10, 90, 10),
            ]).round(2),
        }
    )
    cust_ids = rng.integers(1, n_cust + 1, n_orders)
    signup = customers.set_index("customer_id").loc[cust_ids, "signup_date"].to_numpy()
    orders = pd.DataFrame(
        {
            "order_id": np.arange(1, n_orders + 1),
            "customer_id": cust_ids,
            "order_date": signup + pd.to_timedelta(rng.integers(0, 365, n_orders), unit="D"),
        }
    )
    orders = orders[orders["order_date"] < "2025-01-01"].reset_index(drop=True)
    n_items = rng.integers(1, 4, len(orders))
    items = pd.DataFrame(
        {
            "order_id": np.repeat(orders["order_id"].to_numpy(), n_items),
            "product_id": rng.integers(1, 41, n_items.sum()),
            "qty": rng.integers(1, 3, n_items.sum()),
        }
    )

    con = duckdb.connect(str(db_path))
    for name, df in [("customers", customers), ("products", products), ("orders", orders), ("order_items", items)]:
        con.register("tmp", df)
        con.execute(f"CREATE OR REPLACE TABLE {name} AS SELECT * FROM tmp")
        con.unregister("tmp")
    con.execute("ALTER TABLE orders ALTER order_date TYPE DATE")
    con.execute("ALTER TABLE customers ALTER signup_date TYPE DATE")
    con.execute("""
        CREATE OR REPLACE VIEW order_revenue AS
        SELECT o.order_id, o.customer_id, o.order_date, SUM(i.qty * p.price) AS revenue
        FROM orders o JOIN order_items i USING (order_id) JOIN products p USING (product_id)
        GROUP BY ALL
    """)
    return con


if __name__ == "__main__":
    build("retail.duckdb")
    print("wrote retail.duckdb")
