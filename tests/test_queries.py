"""Every query runs, and key answers match an independent pandas calculation."""
import numpy as np
import pytest

from build_db import build
from run_all import QUERIES, run


@pytest.fixture(scope="module")
def con():
    return build()


@pytest.fixture(scope="module")
def rev(con):
    return con.execute("SELECT * FROM order_revenue").df()


@pytest.mark.parametrize("path", QUERIES, ids=lambda p: p.stem)
def test_query_runs(con, path):
    assert len(run(con, path)) > 0


def _q(con, prefix):
    return run(con, next(q for q in QUERIES if q.name.startswith(prefix)))


def test_running_total_ends_at_year_total(con, rev):
    df = _q(con, "01")
    year = rev[rev.order_date >= "2024-01-01"].revenue.sum()
    assert np.isclose(df.running_total.iloc[-1], year, atol=0.05)


def test_top3_per_state(con, rev):
    df = _q(con, "04")
    cust = con.execute("SELECT customer_id, state FROM customers").df()
    totals = rev.merge(cust).groupby(["state", "customer_id"]).revenue.sum().reset_index()
    for state, grp in df.groupby("state"):
        expected = totals[totals.state == state].nlargest(3, "revenue").customer_id.tolist()
        assert grp.sort_values("rnk").customer_id.tolist() == expected


def test_dedup_keeps_latest(con, rev):
    df = _q(con, "12")
    latest = rev.sort_values(["order_date", "order_id"]).groupby("customer_id").tail(1).set_index("customer_id")
    for _, row in df.iterrows():
        assert row.order_id == latest.loc[row.customer_id, "order_id"]


def test_quartiles_cover_all_revenue(con):
    df = _q(con, "09")
    assert np.isclose(df.pct_of_revenue.sum(), 100, atol=0.2)
    assert df.avg_revenue.is_monotonic_decreasing


def test_cumulative_customers_ends_at_total(con):
    df = _q(con, "15")
    assert df.cumulative_customers.iloc[-1] == con.execute("SELECT COUNT(DISTINCT customer_id) FROM orders").fetchone()[0]
