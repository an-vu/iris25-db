/* ============================================================
    Iris Reader '25 Database – Query Set
    By An Vu

    Run this whenever updating sample data (reset demo DB)

    DROP DATABASE iris_reader;
    CREATE DATABASE iris_reader;
    USE iris_reader;
    SOURCE /path/to/table_creation.sql;
    SOURCE /path/to/data_insertion.sql;

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

-- NOTE:
-- SOURCE only works when the .sql files are in the current MySQL directory
-- (current working directory of the mysql client when launched)
-- otherwise use absolute paths (path/to/file)


/* ============================================================
   1. Basic select + where + order by
   ============================================================ */

-- Show all books published after 2015, sorted by title
SELECT book_id, title, year_published
FROM Book
WHERE year_published > 2015
ORDER BY title ASC;


/* ============================================================
   2. DISTINCT + simple projection
   ============================================================ */

-- All distinct genres that actually have books
SELECT DISTINCT g.name AS genre_name
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
ORDER BY genre_name;


/* ============================================================
   3. String operations with LIKE
   ============================================================ */

-- Books with "SQL" anywhere in the title
SELECT book_id, title
FROM Book
WHERE title LIKE '%SQL%';


/* ============================================================
   4. Inner join 2 tables
   ============================================================ */

-- Each book with its genre name
SELECT b.book_id, b.title, g.name AS genre_name
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
ORDER BY b.book_id;


/* ============================================================
   5. Inner join 3 tables
   ============================================================ */

-- Book titles with their authors
SELECT b.book_id, b.title, a.name AS author_name
FROM Book b
JOIN BookAuthor ba ON b.book_id = ba.book_id
JOIN Author a ON ba.author_id = a.author_id
ORDER BY b.book_id, author_name;


/* ============================================================
   6. Left outer join
   ============================================================ */

-- All books, show reading progress if it exists
SELECT 
  b.book_id,
  b.title,
  CONCAT(COALESCE(p.percent_complete, 0), '%') AS percent_complete
FROM Book b
LEFT JOIN Progress p
  ON b.book_id = p.book_id
  AND p.user_id = 1
ORDER BY b.book_id;

/* ============================================================
   7. Right outer join
   ============================================================ */

-- All users, show any progress rows if available
SELECT 
  u.username,
  b.title,
  CONCAT(COALESCE(p.percent_complete, 0), '%') AS percent_complete
FROM Progress p
RIGHT JOIN User u
  ON p.user_id = u.user_id
LEFT JOIN Book b
  ON p.book_id = b.book_id
ORDER BY u.username, b.title;


/* ============================================================
   8. Aggregation + GROUP BY
   ============================================================ */

-- Number of books in each genre
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

-- Total counts for key tables
SELECT 
  (SELECT COUNT(*) FROM User)  AS user_count,
  (SELECT COUNT(*) FROM Book)  AS book_count,
  (SELECT COUNT(*) FROM Note)  AS note_count;


/* ============================================================
   11. Nested query with IN
   ============================================================ */

-- Books that user "anvu" has written at least one note for
SELECT b.book_id, b.title
FROM Book b
WHERE b.book_id IN (
  SELECT DISTINCT n.book_id
  FROM Note n
  JOIN User u ON n.user_id = u.user_id
  WHERE u.username = 'anvu'
)
ORDER BY b.title;


/* ============================================================
   12. Nested query with NOT IN
   ============================================================ */

-- Books that have no notes from any user
SELECT b.book_id, b.title
FROM Book b
WHERE b.book_id NOT IN (
  SELECT DISTINCT n.book_id
  FROM Note n
)
ORDER BY b.book_id;


/* ============================================================
   13. EXISTS correlated subquery
   ============================================================ */

-- Users who finished at least one book (100%)
SELECT u.username
FROM User u
WHERE EXISTS (
  SELECT 1
  FROM Progress p
  WHERE p.user_id = u.user_id
    AND p.percent_complete = 100
);


/* ============================================================
   14. NOT EXISTS correlated subquery
   ============================================================ */

-- Users with no progress records at all (will show an empty set since all users have some records here)
SELECT u.username
FROM User u
WHERE NOT EXISTS (
  SELECT 1
  FROM Progress p
  WHERE p.user_id = u.user_id
);


/* ============================================================
   15. Subquery in FROM (derived table)
   ============================================================ */

-- Users whose average progress is above 50 percent
SELECT t.username, t.avg_percent
FROM (
  SELECT 
    u.username,
    AVG(p.percent_complete) AS avg_percent
  FROM Progress p
  JOIN User u ON p.user_id = u.user_id
  GROUP BY u.username
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
ORDER BY book_id ASC, b.title;


/* ============================================================
   17. Set operation using UNION
   ============================================================ */

-- All books that "anvu" has either notes or progress on
SELECT b.book_id, b.title
FROM Book b
WHERE b.book_id IN (
  SELECT p.book_id
  FROM Progress p
  JOIN User u ON u.user_id = p.user_id
  WHERE u.username = 'anvu'
)
UNION
SELECT b.book_id, b.title
FROM Book b
WHERE b.book_id IN (
  SELECT n.book_id
  FROM Note n
  JOIN User u ON u.user_id = n.user_id
  WHERE u.username = 'anvu'
)
ORDER BY title;


/* ============================================================
   18. EXCEPT style using LEFT JOIN + IS NULL
   ============================================================ */

-- Books in a given genre where "anvu" has no progress
SELECT b.book_id, b.title
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
LEFT JOIN Progress p
  ON p.book_id = b.book_id
  AND p.user_id = (SELECT user_id FROM User WHERE username = 'anvu')
WHERE g.name = 'Computers & Technology'
  AND p.book_id IS NULL
ORDER BY b.title;


/* ============================================================
   19. WITH clause (CTE)
   ============================================================ */

-- Users whose total reading time is above the average total time
WITH user_totals AS (
  SELECT 
    u.username,
    SUM(p.time_spent) AS total_minutes
  FROM Progress p
  JOIN User u ON p.user_id = u.user_id
  GROUP BY u.username
),
avg_total AS (
  SELECT AVG(total_minutes) AS avg_minutes
  FROM user_totals
)
SELECT ut.username, ut.total_minutes
FROM user_totals ut
CROSS JOIN avg_total a
WHERE ut.total_minutes > a.avg_minutes
ORDER BY ut.total_minutes DESC;


/* ============================================================
   20. View definition + query on view
   ============================================================ */

-- 20a. Create view of each user's book progress
DROP VIEW IF EXISTS UserBookProgress;

CREATE VIEW UserBookProgress AS
SELECT 
  u.username,
  b.book_id,
  b.title,
  p.percent_complete,
  p.time_spent
FROM Progress p
JOIN User u ON p.user_id = u.user_id
JOIN Book b ON p.book_id = b.book_id;

-- 20b. Query the view for one user
SELECT *
FROM UserBookProgress
WHERE username = 'anvu'
ORDER BY percent_complete DESC;


/* ============================================================
   21. INSERT … VALUES
   ============================================================ */

-- Insert a new book
INSERT INTO Book (user_id, title, genre_id, year_published)
VALUES (
  (SELECT user_id FROM User WHERE username = 'anvu'),
  'Iris Reader ''25 Manual',
  3,
  2025
);


/* ============================================================
   22. INSERT … SELECT (insert from another table)
   ============================================================ */

-- For all books in genre "Computers & Technology", 
-- create a starting progress row for user "anvu" at 0%
INSERT INTO Progress (user_id, book_id, percent_complete, time_spent)
SELECT 
  u.user_id,
  b.book_id,
  0 AS percent_complete,
  0 AS time_spent
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
JOIN User u ON u.username = 'anvu'
WHERE g.name = 'Computers & Technology'
  AND NOT EXISTS (
    SELECT 1
    FROM Progress p
    WHERE p.user_id = u.user_id
      AND p.book_id = b.book_id
  );



/* ============================================================
   23. UPDATE with CASE + subquery
   ============================================================ */

-- For user anvu, add a small amount of reading time to newer books,
-- with the amount depending on how far along they already are
UPDATE Progress p
JOIN User u ON p.user_id = u.user_id
SET p.time_spent = p.time_spent + CASE
  WHEN p.percent_complete = 0 THEN 15
  WHEN p.percent_complete BETWEEN 1 AND 50 THEN 10
  ELSE 5
END
WHERE u.username = 'anvu'
  AND p.book_id IN (
    SELECT b.book_id
    FROM Book b
    WHERE b.year_published >= 2020
  );


/* ============================================================
   24. DELETE with subquery
   ============================================================ */

-- Delete notes older than 1 year for books the user never made progress on
DELETE n
FROM Note n
JOIN User u ON n.user_id = u.user_id
WHERE u.username = 'anvu'
  AND n.created_at < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
  AND n.book_id NOT IN (
    SELECT p.book_id
    FROM Progress p
    WHERE p.user_id = u.user_id
  );

