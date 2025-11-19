/* ============================================================
    Iris Reader '25 Database – Query Set
    By An Vu


    Run this whenever updating sample data

DROP DATABASE iris_reader;
CREATE DATABASE iris_reader;
USE iris_reader;
SOURCE /Users/an/Documents/School/2025/3-Fall 2025/CSCI 4850-8856 Database Management Systems/Project/GitHub/iris25-db/04-sql-queries/table_creation.sql;
SOURCE /Users/an/Documents/School/2025/3-Fall 2025/CSCI 4850-8856 Database Management Systems/Project/GitHub/iris25-db/04-sql-queries/data_insertion.sql;

   ============================================================ */


/* ============================================================
   0. Demo database
   ============================================================ */

-- Create a demo database so destructive queries don't touch the real one
CREATE DATABASE IF NOT EXISTS iris25_demo;
USE iris25_demo;

-- Load schema + sample data into the demo copy
SOURCE table_creation.sql;
SOURCE data_insertion.sql;

/* ============================================================
   1. Basic select + where + order by
   ============================================================ */

-- Show all books published after 2015, sorted by title
SELECT book_id, title, published_year
FROM Book
WHERE published_year > 2015
ORDER BY title ASC;

/* ============================================================
   2. DISTINCT + simple projection
   ============================================================ */

-- 2. All distinct genres that actually have books
SELECT DISTINCT g.name AS genre_name
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
ORDER BY genre_name;


/* ============================================================
   3. String operations with LIKE
   ============================================================ */

-- 3. Books with "SQL" anywhere in the title
SELECT book_id, title
FROM Book
WHERE title LIKE '%SQL%';


/* ============================================================
   4. Inner join 2 tables
   ============================================================ */

-- 4. Each book with its genre name
SELECT b.book_id, b.title, g.name AS genre_name
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
ORDER BY b.book_id;


/* ============================================================
   5. Inner join 3 tables
   ============================================================ */

-- 5. Book titles with their authors
SELECT b.book_id, b.title, a.name AS author_name
FROM Book b
JOIN BookAuthor ba ON b.book_id = ba.book_id
JOIN Author a ON ba.author_id = a.author_id
ORDER BY b.book_id, author_name;


/* ============================================================
   6. Left outer join
   ============================================================ */

-- 6. All books, show reading progress if it exists
SELECT 
  b.book_id,
  b.title,
  CONCAT(COALESCE(p.percent_complete, 0), '%') AS percent_complete
FROM Book b
LEFT JOIN Progress p 
  ON b.book_id = p.book_id
  AND p.username = 'anvu'
ORDER BY b.book_id;


/* ============================================================
   7. Right outer join
   ============================================================ */

-- 7. All users, show any progress rows if available
SELECT 
  u.username,
  b.title,
  p.percent_complete
FROM Progress p
RIGHT JOIN User u ON p.username = u.username
LEFT JOIN Book b ON p.book_id = b.book_id
ORDER BY u.username, b.title;


/* ============================================================
   8. Aggregation + GROUP BY
   ============================================================ */

-- 8. Number of books in each genre
SELECT 
  g.name AS genre_name,
  COUNT(*) AS book_count
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
GROUP BY g.name
ORDER BY book_count DESC;


/* ============================================================
   9. GROUP BY + HAVING
   ============================================================ */

-- 9. Genres that have at least 3 books
SELECT 
  g.name AS genre_name,
  COUNT(*) AS book_count
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
GROUP BY g.name
HAVING COUNT(*) >= 3
ORDER BY book_count DESC;


/* ============================================================
   10. Aggregate without group
   ============================================================ */

-- 10. Total counts for key tables
SELECT 
  (SELECT COUNT(*) FROM User)  AS user_count,
  (SELECT COUNT(*) FROM Book)  AS book_count,
  (SELECT COUNT(*) FROM Note)  AS note_count;


/* ============================================================
   11. Nested query with IN
   ============================================================ */

-- 11. Books that "anvu" has written at least one note for
SELECT b.book_id, b.title
FROM Book b
WHERE b.book_id IN (
  SELECT DISTINCT n.book_id
  FROM Note n
  WHERE n.username = 'anvu'
)
ORDER BY b.title;


/* ============================================================
   12. Nested query with NOT IN
   ============================================================ */

-- 12. Books that have no notes from any user
SELECT b.book_id, b.title
FROM Book b
WHERE b.book_id NOT IN (
  SELECT DISTINCT n.book_id
  FROM Note n
)
ORDER BY b.title;


/* ============================================================
   13. EXISTS correlated subquery
   ============================================================ */

-- 13. Users who finished at least one book (100 percent)
SELECT u.username
FROM User u
WHERE EXISTS (
  SELECT 1
  FROM Progress p
  WHERE p.username = u.username
    AND p.percent_complete = 100
);


/* ============================================================
   14. NOT EXISTS correlated subquery
   ============================================================ */

-- 14. Users with no progress records at all
SELECT u.username
FROM User u
WHERE NOT EXISTS (
  SELECT 1
  FROM Progress p
  WHERE p.username = u.username
);


/* ============================================================
   15. Subquery in FROM (derived table)
   ============================================================ */

-- 15. Users whose average progress is above 50 percent
SELECT t.username, t.avg_percent
FROM (
  SELECT username, AVG(percent_complete) AS avg_percent
  FROM Progress
  GROUP BY username
) AS t
WHERE t.avg_percent > 50
ORDER BY t.avg_percent DESC;


/* ============================================================
   16. Scalar subquery in SELECT
   ============================================================ */

-- 16. Each book with how many notes it has
SELECT 
  b.book_id,
  b.title,
  (
    SELECT COUNT(*)
    FROM Note n
    WHERE n.book_id = b.book_id
  ) AS note_count
FROM Book b
ORDER BY note_count DESC, b.title;


/* ============================================================
   17. Set operation using UNION
   ============================================================ */

-- 17. All books that "anvu" has either notes or progress on
SELECT DISTINCT b.book_id, b.title
FROM Book b
WHERE b.book_id IN (
  SELECT p.book_id
  FROM Progress p
  WHERE p.username = 'anvu'
)
UNION
SELECT DISTINCT b.book_id, b.title
FROM Book b
WHERE b.book_id IN (
  SELECT n.book_id
  FROM Note n
  WHERE n.username = 'anvu'
)
ORDER BY title;


/* ============================================================
   18. EXCEPT style using LEFT JOIN + IS NULL
   ============================================================ */

-- 18. Books in "Database" genre where "anvu" has no progress
SELECT b.book_id, b.title
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
LEFT JOIN Progress p 
  ON p.book_id = b.book_id
  AND p.username = 'anvu'
WHERE g.name = 'Database'
  AND p.book_id IS NULL
ORDER BY b.title;


/* ============================================================
   19. WITH clause (CTE)
   ============================================================ */

-- 19. Users whose total reading time is above the average total time
WITH user_totals AS (
  SELECT username, SUM(time_spent) AS total_minutes
  FROM Progress
  GROUP BY username
),
avg_total AS (
  SELECT AVG(total_minutes) AS avg_minutes
  FROM user_totals
)
SELECT u.username, u.total_minutes
FROM user_totals u, avg_total a
WHERE u.total_minutes > a.avg_minutes
ORDER BY u.total_minutes DESC;


/* ============================================================
   20. View definition + query on view
   ============================================================ */

-- 20a. Create view of each user's book progress
CREATE VIEW UserBookProgress AS
SELECT 
  p.username,
  b.book_id,
  b.title,
  p.percent_complete,
  p.time_spent
FROM Progress p
JOIN Book b ON p.book_id = b.book_id;

-- 20b. Query the view for one user
SELECT *
FROM UserBookProgress
WHERE username = 'anvu'
ORDER BY percent_complete DESC;


/* ============================================================
   21. INSERT … VALUES
   ============================================================ */

-- 21. Insert a new book
INSERT INTO Book (book_id, title, genre_id, uploader_username, published_year)
VALUES (101, 'SQL For Iris Reader', 3, 'anvu', 2025);


/* ============================================================
   22. INSERT … SELECT (insert from another table)
   ============================================================ */

-- 22. For all books in genre "Algorithms", 
-- create a starting progress row for user "anvu" at 0 percent
INSERT INTO Progress (username, book_id, percent_complete, time_spent)
SELECT 
  'anvu' AS username,
  b.book_id,
  0 AS percent_complete,
  0 AS time_spent
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
WHERE g.name = 'Algorithms'
  AND NOT EXISTS (
    SELECT 1
    FROM Progress p
    WHERE p.username = 'anvu'
      AND p.book_id = b.book_id
  );


/* ============================================================
   23. UPDATE with CASE + subquery
   ============================================================ */

-- 23. Give a small boost to progress based on current level
UPDATE Progress p
SET percent_complete = CASE
  WHEN percent_complete < 25 THEN percent_complete + 10
  WHEN percent_complete BETWEEN 25 AND 75 THEN percent_complete + 5
  ELSE percent_complete
END
WHERE username = 'anvu'
  AND p.book_id IN (
    SELECT book_id
    FROM Book
    WHERE published_year >= 2020
  );


/* ============================================================
   24. DELETE with subquery
   ============================================================ */

-- 24. Delete notes older than 1 year for books the user never made progress on
DELETE FROM Note n
WHERE n.username = 'anvu'
  AND n.created_at < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
  AND n.book_id NOT IN (
    SELECT DISTINCT p.book_id
    FROM Progress p
    WHERE p.username = 'anvu'
  );
