# ============================================================
# Iris Reader '25 Database – Python Script
# By An Vu
#
# Prerequisites:
# - MySQL server must be running
# - Schema + sample data must be loaded into the target database
#
# In MySQL (one-time setup):
#   USE iris25_demo;
#   SOURCE /path/to/table_creation.sql;
#   SOURCE /path/to/data_insertion.sql;
#
# Verify:
#   SHOW TABLES;
#
# Run this script in a separate terminal (not mysql>):
#   python3 /path/to/run_queries.py
#
# Notes:
# - The script will read connection settings from environment variables:
#   IRIS_DB_HOST, IRIS_DB_USER, IRIS_DB_NAME, IRIS_DB_PASS
# - If IRIS_DB_PASS is not set, the script will prompt for the password.
#
# ============================================================

import os
import getpass
import mysql.connector
from mysql.connector import Error


def print_table(title: str, columns: list[str], rows: list[tuple]) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)

    if not rows:
        print("(no rows)")
        return

    widths = [len(col) for col in columns]
    for row in rows:
        for i, val in enumerate(row):
            widths[i] = max(widths[i], len(str(val)))

    header = " | ".join(col.ljust(widths[i]) for i, col in enumerate(columns))
    sep = "-+-".join("-" * w for w in widths)
    print(header)
    print(sep)

    for row in rows:
        line = " | ".join(str(val).ljust(widths[i]) for i, val in enumerate(row))
        print(line)


def run_select(cursor, title: str, sql: str, params: tuple = ()) -> None:
    cursor.execute(sql, params)
    rows = cursor.fetchall()
    cols = [d[0] for d in cursor.description] if cursor.description else []
    print_table(title, cols, rows)


def main() -> None:
    host = os.getenv("IRIS_DB_HOST", "localhost")
    user = os.getenv("IRIS_DB_USER", "root")
    db = os.getenv("IRIS_DB_NAME", "iris25_demo")

    pw = os.getenv("IRIS_DB_PASS")
    if not pw:
        pw = getpass.getpass(f"MySQL password for {user}@{host}: ")

    cfg = {
        "host": host,
        "user": user,
        "password": pw,
        "database": db,
    }

    try:
        conn = mysql.connector.connect(**cfg)
        cursor = conn.cursor()

        queries = [
            (
                "1) Basic SELECT + WHERE + ORDER BY (books after 2015)",
                """
                SELECT book_id, title, year_published
                FROM Book
                WHERE year_published > 2015
                ORDER BY title ASC;
                """,
                (),
            ),
            (
                "2) JOIN (book + genre)",
                """
                SELECT b.book_id, b.title, g.name AS genre_name
                FROM Book b
                JOIN Genre g ON b.genre_id = g.genre_id
                ORDER BY b.book_id;
                """,
                (),
            ),
            (
                "3) Aggregation (books per genre)",
                """
                SELECT g.name AS genre_name, COUNT(*) AS book_count
                FROM Book b
                JOIN Genre g ON b.genre_id = g.genre_id
                GROUP BY g.name
                ORDER BY book_count DESC;
                """,
                (),
            ),
            (
                "4) LEFT JOIN (all books + anvu progress if exists)",
                """
                SELECT 
                  b.book_id,
                  b.title,
                  CONCAT(COALESCE(p.percent_complete, 0), '%') AS percent_complete
                FROM Book b
                LEFT JOIN Progress p
                  ON b.book_id = p.book_id
                  AND p.user_id = (SELECT user_id FROM User WHERE username = %s)
                ORDER BY b.book_id;
                """,
                ("anvu",),
            ),
            (
                "5) EXISTS correlated subquery (users who finished a book)",
                """
                SELECT u.username
                FROM User u
                WHERE EXISTS (
                  SELECT 1
                  FROM Progress p
                  WHERE p.user_id = u.user_id
                    AND p.percent_complete = 100
                )
                ORDER BY u.username;
                """,
                (),
            ),
        ]

        for title, sql, params in queries:
            run_select(cursor, title, sql, params)

        cursor.close()
        conn.close()

    except Error as e:
        # Helpful hint for the most common failure
        if getattr(e, "errno", None) == 1045:
            print("MySQL error 1045: Access denied (bad username/password).")
            print("Tip: try logging in manually: /usr/local/mysql/bin/mysql -u root -p")
        else:
            print(f"MySQL error: {e}")
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
