"""Run every query in queries/ against the sample warehouse and print a preview."""
import argparse
from pathlib import Path

from build_db import build

QUERIES = sorted(Path(__file__).with_name("queries").glob("*.sql"))


def run(con, path: Path):
    return con.execute(path.read_text()).df()


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--only", help="run one query by number, e.g. 11")
    p.add_argument("--rows", type=int, default=5)
    args = p.parse_args()

    con = build()
    for q in QUERIES:
        if args.only and not q.name.startswith(args.only.zfill(2)):
            continue
        title = q.read_text().splitlines()[0].lstrip("- ")
        df = run(con, q)
        print(f"\n=== {title}  ({len(df):,} rows)")
        print(df.head(args.rows).to_string(index=False))


if __name__ == "__main__":
    main()
