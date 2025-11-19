/* ============================================================
    Iris Reader '25 Database – Query Set

    A. Basic Retrieval and Filters
    B. Joins – All Join Types From Chapter 4
    C. Aggregation + Grouping + HAVING

    Run this whenever updating sample data

DROP DATABASE iris_reader;
CREATE DATABASE iris_reader;
USE iris_reader;
SOURCE /Users/an/Documents/School/2025/3-Fall 2025/CSCI 4850-8856 Database Management Systems/Project/GitHub/iris25-db/04-sql-queries/table_creation.sql;
SOURCE /Users/an/Documents/School/2025/3-Fall 2025/CSCI 4850-8856 Database Management Systems/Project/GitHub/iris25-db/04-sql-queries/data_insertion.sql;

   ============================================================ */

/* ============================================================
   A. Basic Retrieval and Filters (3 queries)
   ============================================================ */

-- 1. Show all books added after a given date.
--    Uses a simple WHERE filter on added_at and ORDER BY to sort the results.
SELECT 
  book_id, title, added_at
FROM Book

WHERE added_at > '2024-03-02'
ORDER BY added_at;

-- 2. Show all notes for Book 2, Chapter 6, and sort by page number.
--    Uses basic retrieval with WHERE filtering on book_id and chapter_number.
SELECT 
  note_id, user_id, page_number, content, created_at
FROM Note

WHERE book_id = 2
  AND chapter_number = 6
ORDER BY page_number
\G -- Use \G to run the query and print vertical output, no need to use ; when using \G.

-- 3. Show all genres in alphabetical order.
--    Simple SELECT on one table with ORDER BY name (no filtering or joins).
SELECT 
  genre_id, name
FROM Genre

ORDER BY name;

/* ============================================================
   B. Constraint Enforcement Master Block
   ============================================================ */

-- 4. Demonstrates:
--    PRIMARY KEY enforcement
--    UNIQUE constraint enforcement
--    CHECK constraint enforcement
--    FOREIGN KEY constraint enforcement

-- Create table with PK, UNIQUE, CHECK
CREATE TABLE DemoConstraints (
  id INT PRIMARY KEY,
  code VARCHAR(10) UNIQUE,
  rating INT CHECK (rating BETWEEN 1 AND 5)
);

-- Valid insert
INSERT INTO DemoConstraints VALUES (1, 'A1', 5);

-- PRIMARY KEY violation (should FAIL)
INSERT INTO DemoConstraints VALUES (1, 'B1', 3);

-- UNIQUE constraint violation (should FAIL)
INSERT INTO DemoConstraints VALUES (2, 'A1', 4);

-- CHECK constraint violation (should FAIL)
INSERT INTO DemoConstraints VALUES (3, 'C1', 12);


-- Parent + Child tables for FOREIGN KEY demonstration
CREATE TABLE ParentDemo (
  parent_id INT PRIMARY KEY
);

CREATE TABLE ChildDemo (
  child_id INT PRIMARY KEY,
  parent_id INT,
  FOREIGN KEY (parent_id) REFERENCES ParentDemo(parent_id)
);

-- Valid parent + valid child
INSERT INTO ParentDemo VALUES (100);
INSERT INTO ChildDemo VALUES (1, 100);

-- FOREIGN KEY violation (should FAIL)
INSERT INTO ChildDemo VALUES (2, 999);


-- Cleanup
DROP TABLE ChildDemo;
DROP TABLE ParentDemo;
DROP TABLE DemoConstraints;

/* ============================================================
   B. Joins – All Join Types From Chapter 4 (10 queries)
   ============================================================ */

-- 5. Show each book with its genre name.
--    NATURAL JOIN joins tables automatically on same-named columns
SELECT
  title, name AS genre_name
FROM Book

NATURAL JOIN Genre;

-- 6. Show each book with its author(s)
--    JOIN USING joins tables by matching columns with the same name
--    USING(book_id) links Book to BookAuthor
--    USING(author_id) links BookAuthor to Author
SELECT
  CASE 
    WHEN ROW_NUMBER() OVER (PARTITION BY b.book_id ORDER BY a.name) = 1 
      THEN b.title
    ELSE ''
  END AS title,
  a.name AS author_name
FROM Book b

JOIN BookAuthor ba USING (book_id)
JOIN Author a USING (author_id)
ORDER BY b.book_id, a.name;

-- 7. INNER JOIN
--    Show notes along with the username who wrote them
--      INNER JOIN keeps only matching rows:
--      Note -> User (same user_id) and Note -> Book (same book_id).
--      We get only notes that have a valid user and a valid book.
SELECT 
  CONCAT(
    u.username, ' wrote "', 
    n.content, '" at page ', 
    n.page_number, 
    ' in chapter ', 
    n.chapter_number, 
    ' of ', 
    b.title
  ) AS note
FROM Note n

INNER JOIN User u ON n.user_id = u.user_id
INNER JOIN Book b ON n.book_id = b.book_id
\G

-- 8. LEFT OUTER JOIN + ORDER BY
--    Show all books, include progress if available
--      LEFT OUTER JOIN keeps all books, even ones with no progress.
--      If a book has no matching row in Progress, percent/time show as NULL.
SELECT 
  Book.title,
  CONCAT(Progress.percent_complete, '%') AS percent_complete,
  CONCAT(
    FLOOR(Progress.time_spent / 60), 'h ',
    MOD(Progress.time_spent, 60), 'm'
  ) AS time_spent
FROM Book

LEFT JOIN Progress ON Book.book_id = Progress.book_id
ORDER BY Book.book_id;

-- 9. RIGHT OUTER JOIN + ORDER BY
--    Show all authors, even those with zero books
--      RIGHT JOIN Author keeps all authors, even those with zero books.
--      If an author has no BookAuthor rows, BookAuthor fields become NULL.
--      LEFT JOIN Book attaches book titles when available, NULL otherwise.
SELECT 
  Author.name AS author_name,
  Book.title AS book_title
FROM BookAuthor

RIGHT JOIN Author ON BookAuthor.author_id = Author.author_id
LEFT JOIN Book ON BookAuthor.book_id = Book.book_id
ORDER BY Author.author_id;

-- 10. Full outer join (simulated) + UNION
--     Show all books and all progress entries, including unmatched rows on either side

(
  SELECT 
    Book.book_id,
    Book.title,
    Progress.percent_complete
  FROM Book

  LEFT JOIN Progress ON Book.book_id = Progress.book_id
)
UNION
(
  SELECT
    Book.book_id,
    Book.title,
    Progress.percent_complete
  FROM Book

  RIGHT JOIN Progress ON Book.book_id = Progress.book_id
);

-- 10. Self join: Show pairs of users who share the same language setting
SELECT 
  ua.username AS user_a_name,
  ub.username AS user_b_name,
  u1.language AS shared_language
FROM UserSettings u1
JOIN UserSettings u2 
  ON u1.language = u2.language
 AND u1.user_id < u2.user_id
JOIN User ua ON u1.user_id = ua.user_id
JOIN User ub ON u2.user_id = ub.user_id \G

-- 11. Multi-way join: Show each book with its author and genre
SELECT
  Book.title,
  CASE 
    WHEN COUNT(Author.author_id) = 1 THEN GROUP_CONCAT(Author.name)
    ELSE CONCAT(
      -- all authors except last
      SUBSTRING_INDEX(GROUP_CONCAT(Author.name ORDER BY Author.author_id SEPARATOR ', '), ', ', 
        COUNT(Author.author_id) - 1),
      ' & ',
      -- last author only
      SUBSTRING_INDEX(GROUP_CONCAT(Author.name ORDER BY Author.author_id SEPARATOR ', '), ', ', -1)
    )
  END AS authors,
  Genre.name AS genre_name
FROM Book
JOIN BookAuthor USING (book_id)
JOIN Author USING (author_id)
JOIN Genre USING (genre_id)
GROUP BY Book.book_id
ORDER BY Book.book_id \G

/* ============================================================
   C. Aggregation + Grouping + HAVING (5 queries)
   ============================================================ */

-- 14. Show how many books each user added
--     Using aggregation COUNT(Book.book_id) with LEFT JOIN: Count how many books each user added.
SELECT 
  User.user_id,
  User.username,
  COUNT(Book.book_id) AS books_added
FROM User
LEFT JOIN Book ON User.user_id = Book.user_id
GROUP BY User.user_id, User.username
ORDER BY books_added DESC;

-- 15. Show average percent_complete for each genre
--     Uses multi-way JOIN (Genre → Book → Progress) and aggregation.
--     ROUND + CONCAT format the percentage to two decimals with a % sign.
SELECT 
  Genre.name AS genre_name,
  CONCAT(ROUND(AVG(Progress.percent_complete), 2), '%') AS avg_completion
FROM Genre
JOIN Book ON Genre.genre_id = Book.genre_id
JOIN Progress ON Book.book_id = Progress.book_id
GROUP BY Genre.genre_id, Genre.name
ORDER BY AVG(Progress.percent_complete) DESC;

-- 16. Show the total reading minutes logged by each user
--     Uses aggregation (SUM) and GROUP BY to total reading time per user.
SELECT 
  User.username,
  CONCAT(
    FLOOR(SUM(Progress.time_spent) / 60), 'h ',
    MOD(SUM(Progress.time_spent), 60), 'm'
  ) AS total_time
FROM User
JOIN Progress ON User.user_id = Progress.user_id
GROUP BY User.user_id, User.username
ORDER BY SUM(Progress.time_spent) DESC;

-- 17. Show heavy note-writers:
--     Users who wrote more than 1 note per book
SELECT
  User.username,
  Book.title,
  COUNT(Note.note_id) AS notes_written
FROM Note
JOIN User ON Note.user_id = User.user_id
JOIN Book ON Note.book_id = Book.book_id
GROUP BY User.username, Book.title
HAVING COUNT(Note.note_id) > 1
ORDER BY notes_written DESC;

-- 18. Find the genre with the most books, count the book number, and list them
SELECT
  g.genre_id,
  g.name AS genre_name,
  COUNT(b.book_id) AS total_books,
  GROUP_CONCAT(b.title SEPARATOR '\n') AS titles
FROM Genre g
JOIN Book b ON b.genre_id = g.genre_id
WHERE g.genre_id = (
    SELECT 
      Genre.genre_id
    FROM Genre
    JOIN Book ON Genre.genre_id = Book.genre_id
    GROUP BY Genre.genre_id
    ORDER BY COUNT(Book.book_id) DESC
    LIMIT 1
)
GROUP BY g.genre_id, g.name \G

/* ============================================================
   D. Set Operations (3 queries)
   ============================================================ */

-- 19. Show books belonging to genre 1 OR genre 2 (UNION)
SELECT title FROM Book WHERE genre_id = 1
UNION
SELECT title FROM Book WHERE genre_id = 2
ORDER BY title;

-- 20. Show books that have both notes AND progress (INTERSECT simulation)
SELECT DISTINCT b.title
FROM Book b
WHERE b.book_id IN (SELECT book_id FROM Note)
  AND b.book_id IN (SELECT book_id FROM Progress);

-- 21. Show books that have zero notes (MINUS simulation)
SELECT b.title
FROM Book b
WHERE NOT EXISTS (SELECT 1 FROM Note n WHERE n.book_id = b.book_id)
ORDER BY b.title;


/* ============================================================
   E. Subqueries / Nested Queries (5 queries)
   ============================================================ */

-- 22. Show books with above-average percent_complete
SELECT 
  b.book_id,
  b.title,
  CONCAT(p.percent_complete, '%') AS percent_complete,
  CONCAT(ROUND(avgp.avg_percent, 2), '%') AS avg_percent
FROM Book b
JOIN Progress p ON b.book_id = p.book_id
CROSS JOIN (
  SELECT AVG(percent_complete) AS avg_percent
  FROM Progress
) AS avgp
WHERE p.percent_complete > avgp.avg_percent;

-- 23. Show users who wrote more notes than the average user
SELECT u.user_id, u.username, COUNT(n.note_id) AS note_count
FROM User u
JOIN Note n ON u.user_id = n.user_id
GROUP BY u.user_id
HAVING COUNT(n.note_id) >
       (SELECT AVG(note_count)
          FROM (SELECT COUNT(*) AS note_count
                FROM Note
                GROUP BY user_id) AS temp);

-- 24. Show books from genres containing more than 3 books
--     Uses subquery with GROUP BY + HAVING and a JOIN back to Genre.
SELECT 
  b.book_id,
  b.title,
  CONCAT(g.name, ' has ', gc.genre_count, ' books') AS genre_summary
FROM Book b
JOIN Genre g ON b.genre_id = g.genre_id
JOIN (
    SELECT 
      genre_id,
      COUNT(*) AS genre_count
    FROM Book
    GROUP BY genre_id
    HAVING COUNT(*) > 3
) AS gc ON b.genre_id = gc.genre_id
ORDER BY g.name, b.title;

-- 26. Show books that do not have any progress record
SELECT b.book_id, b.title
FROM Book b
WHERE NOT EXISTS (
    SELECT 1 FROM Progress p WHERE p.book_id = b.book_id
);