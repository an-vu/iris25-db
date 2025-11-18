# Iris Reader ’25 Database

Relational schema, sample data, and SQL query set for **[Iris Reader ’25](https://github.com/an-vu/iris25)**.  
Originally built for CSCI 4850-8856 Database Management Systems Final Project.

The data model covers:
- Users
- Uploaded books
- Multi-author relationships
- Reading progress tracking
- Per-user notes (chapter + page level)
- User app settings (dark mode, language)

---

## Workflow

### 1. Start MySQL

```sh
mysql -u root -p
```

### 2. Reset the Database

- Always start clean to avoid stale or duplicate data.

```sql
DROP DATABASE IF EXISTS iris_reader;
CREATE DATABASE iris_reader;
USE iris_reader;
```

### 3. Load Schema + Sample Data

#### Option A — Standard Method

- Load DDL first, then data.

```sql
SOURCE iris25_sql_specification_ddl.sql;
SOURCE iris25_sample_data.sql;
```

#### Option B — Self-Contained Method (One File)

- Loads schema updates + sample data in a single file.

```sql
SOURCE iris25_sample_data_self_contained.sql;
```

### 4. Verify Tables and Row Counts

- Run these check to confirm the data loaded correctly:

```sql
SHOW TABLES;

SELECT COUNT(*) FROM User;
SELECT COUNT(*) FROM Book;
SELECT COUNT(*) FROM Author;
SELECT COUNT(*) FROM Genre;
SELECT COUNT(*) FROM BookAuthor;
SELECT COUNT(*) FROM Progress;
SELECT COUNT(*) FROM Note;
SELECT COUNT(*) FROM UserSettings;
```

- Expected counts:
  - User: 3
  -	Book: 11
  -	Author: 15
  -	Genre: 6
  -	BookAuthor: 17
  -	Progress: 7
  -	Note: 5
  -	UserSettings: 3

- If these match, the database is ready.

### 5. Running Queries

- Open query.sql, pick any query, and paste it directly into the MySQL terminal.

- No additional setup required.

---
