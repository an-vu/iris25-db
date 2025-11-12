# Iris Reader '25 Database

Relational schema, sample data, and design collateral for the Iris Reader '25 project (CSCI 4850/8856 Database Management Systems). The data model captures users, the books they upload, multi-author relationships, reading progress, personal notes, and per-user app settings.

## Repository contents

| Path | Description |
| --- | --- |
| `README.md` | Project overview and setup guide (this file). |
| `iris25-db/iri25_sql_specification_ddl.sql` | Canonical MySQL DDL for all eight tables, keys, and referential rules. |
| `iris25-db/iris25_sample_data.sql` | Seed data that assumes the schema has already been created. |
| `iris25-db/iris25_sample_data (self_contained).sql` | Same seed data plus `ALTER TABLE` guards so you can run it standalone. |
| `iris25-db/iris25_schema.dbml` | dbdiagram.io-compatible model with inline commentary. |
| `iris25-db/iris25_schema_dbdiagram.io.dbml` | Raw export from dbdiagram.io (useful if you want to round-trip edits). |
| `iris25-db/iris25_schema_er_diagram.png` | PNG of the ER diagram for quick reference. |
| `iris25-db/An Vu 8856 Project Data Definition.pages` | Original data-definition write-up (Apple Pages). |
| `iris25-db/Project database Fall 2025-1.docx / .pdf` | Assignment brief / narrative that motivated the schema. |

## Schema at a glance

| Table | Purpose | Notable constraints |
| --- | --- | --- |
| `User` | App accounts (uploader/reader identity). | Unique `username` + `email`; timestamps default to `CURRENT_TIMESTAMP`. |
| `Author` | Canonical author names. | `name` is required. |
| `Genre` | Controlled vocabulary for shelving. | `name` unique to prevent duplicates. |
| `Book` | Catalog of uploaded titles. | Optional `user_id` (uploader), mandatory `genre_id`, FK deletes: set null / restrict. |
| `BookAuthor` | Bridge for `Book` ↔ `Author` (M:N). | Composite primary key (`book_id`, `author_id`) with cascading deletes. |
| `Progress` | Reading telemetry per user/book pair. | Composite PK, `percent_complete` constrained 0–100, cascades on delete. |
| `Note` | User-authored annotations tied to chapters/pages. | FK cascades to keep notes aligned with users/books. |
| `UserSettings` | 1:1 preferences (dark mode, language). | Shares PK with `User`; cascades on delete. |

See `iris25-db/iri25_sql_specification_ddl.sql` for the full DDL (including `DROP TABLE IF EXISTS` guards) and descriptive comments.

## Getting started

### Requirements
- MySQL 8.x (or compatible MariaDB build with CHECK constraint support).
- Local clone of this repository.

### 1. Create a sandbox database
```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS iris_reader CHARACTER SET utf8mb4;"
```

### 2. Apply the schema
```bash
mysql -u root -p iris_reader < iris25-db/iri25_sql_specification_ddl.sql
```

### 3. Load sample data (choose one)
- **Standard** (requires schema already applied):
  ```bash
  mysql -u root -p iris_reader < "iris25-db/iris25_sample_data.sql"
  ```
- **Self-contained** (runs `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` just in case):
  ```bash
  mysql -u root -p iris_reader < "iris25-db/iris25_sample_data (self_contained).sql"
  ```

After the import, you can sanity-check counts:
```sql
SELECT 'users' AS table_name, COUNT(*) FROM User
UNION ALL
SELECT 'books', COUNT(*) FROM Book
UNION ALL
SELECT 'notes', COUNT(*) FROM Note;
```

## Diagram and modeling assets
- Open `iris25_schema.dbml` or `iris25_schema_dbdiagram.io.dbml` at [dbdiagram.io](https://dbdiagram.io/) to regenerate editable diagrams.
- The rendered PNG `iris25_schema_er_diagram.png` is ready for slide decks or documentation if you only need a static view.

## Validation ideas & sample queries
- **Progress leaderboard:** `SELECT u.username, b.title, p.percent_complete FROM Progress p JOIN User u USING (user_id) JOIN Book b USING (book_id) ORDER BY p.percent_complete DESC;`
- **Notes per book:** `SELECT b.title, COUNT(*) AS notes FROM Note n JOIN Book b USING (book_id) GROUP BY b.book_id;`
- **Genre catalog health:** `SELECT g.name, COUNT(b.book_id) AS titles FROM Genre g LEFT JOIN Book b USING (genre_id) GROUP BY g.genre_id;`

Running a few of these after loading data ensures that referential integrity rules and seed content behave as expected.

## Next steps
1. Build stored procedures or views for common dashboard widgets (e.g., recently added books, “continue reading” queue).
2. Add test coverage by writing automated SQL scripts that assert row counts / FK behavior for future schema tweaks.
3. Extend the schema with authentication artifacts (password hashes, OAuth identities) if Iris Reader needs real login flows.
