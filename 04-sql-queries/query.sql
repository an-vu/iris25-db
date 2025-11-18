-- ============================================================
-- A. Basic Retrieval and Filters (3 queries)
-- ============================================================

-- 1. List all books added after a specific date (simple SELECT + WHERE).
-- Books added after a given date
SELECT 
  book_id,
  title,
  added_at
FROM Book
WHERE added_at > '2025-11-05'
ORDER BY added_at;

-- 2. Show all notes for a given book and chapter (filter + order).
-- Notes for a specific book and chapter (example: Book 2, Chapter 6)
SELECT 
  note_id,
  user_id,
  page_number,
  content,
  created_at
FROM Note
WHERE book_id = 2
  AND chapter_number = 6
ORDER BY page_number;

-- 3. List all genres in alphabetical order (ORDER BY).
-- List all genres alphabetically
SELECT 
  genre_id,
  name
FROM Genre
ORDER BY name ASC;

-- ============================================================
-- B. Joins – All Join Types From Chapter 4 (10 queries)
-- ============================================================

-- 4. Natural Join
-- Natural join Book NATURAL JOIN Genre to show book titles with genre names.
-- Natural join Book and Genre
SELECT 
  title,
  name AS genre_name
FROM Book
NATURAL JOIN Genre;

-- 5. JOIN ... USING
-- Join BookAuthor USING (book_id) to list each book with its authors.
-- Join using (book_id)
SELECT 
  Book.title,
  Author.name AS author_name
FROM Book
JOIN BookAuthor USING (book_id)
JOIN Author USING (author_id);

-- 6. Inner Join (JOIN ... ON)
-- Inner join Note JOIN User ON user_id to show notes with usernames.
-- Inner join notes with users
SELECT 
  User.username,
  Note.book_id,
  Note.chapter_number,
  Note.page_number,
  Note.content
FROM Note
JOIN User ON Note.user_id = User.user_id;

-- 7. Left Outer Join
-- Show all books, and their progress if they have any.
-- Left outer join: all books, progress optional
SELECT 
  Book.title,
  Progress.percent_complete,
  Progress.time_spent
FROM Book
LEFT JOIN Progress ON Book.book_id = Progress.book_id
ORDER BY Book.book_id;

-- 8. Right Outer Join
-- Show all authors, even if they have no books listed.
-- Right outer join: all authors, books optional
SELECT 
  Author.name AS author_name,
  Book.title AS book_title
FROM BookAuthor
RIGHT JOIN Author ON BookAuthor.author_id = Author.author_id
LEFT JOIN Book ON BookAuthor.book_id = Book.book_id
ORDER BY Author.author_id;

-- 9. Full Outer Join (simulated)
-- Full outer join between Book and Progress using LEFT UNION RIGHT simulation.
-- Full outer join simulation: Book and Progress
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

-- 10. Self Join
-- Self join UserSettings to find users who share the same language.
-- Self join on UserSettings to find matching languages
SELECT 
  u1.user_id AS user_a,
  u2.user_id AS user_b,
  u1.language
FROM UserSettings u1
JOIN UserSettings u2 
  ON u1.language = u2.language
  AND u1.user_id < u2.user_id;

-- 11. Multi-way Join, Example 1
-- Book + BookAuthor + Author to show: book title, author name, genre name.
-- Multi-way join: book, author, genre
SELECT
  Book.title,
  Author.name AS author_name,
  Genre.name AS genre_name
FROM Book
JOIN BookAuthor ON Book.book_id = BookAuthor.book_id
JOIN Author ON BookAuthor.author_id = Author.author_id
JOIN Genre ON Book.genre_id = Genre.genre_id
ORDER BY Book.book_id;

-- 12. Multi-way Join, Example 2
-- Progress + Book + User to show: what each user is reading right now (status table).
-- Multi-way join: reading status
SELECT
  User.username,
  Book.title,
  Progress.percent_complete,
  Progress.time_spent
FROM Progress
JOIN User ON Progress.user_id = User.user_id
JOIN Book ON Progress.book_id = Book.book_id
ORDER BY User.user_id;

-- 13. Multi-way Join Example 3 Note + Book + User
-- Notes with book title and user name
SELECT
  User.username,
  Book.title,
  Note.chapter_number,
  Note.page_number,
  Note.content
FROM Note
JOIN User ON Note.user_id = User.user_id
JOIN Book ON Note.book_id = Book.book_id
ORDER BY Note.created_at;

-- ============================================================
-- C. Aggregation + Grouping + HAVING (5 queries)
-- ============================================================

-- 14. Count how many books each user has added.
-- Count how many books each user added
SELECT 
  User.user_id,
  User.username,
  COUNT(Book.book_id) AS books_added
FROM User
LEFT JOIN Book ON User.user_id = Book.user_id
GROUP BY User.user_id, User.username
ORDER BY books_added DESC;

-- 15. Compute average percent_complete per genre.
-- Average reading progress per genre
SELECT 
  Genre.name AS genre_name,
  AVG(Progress.percent_complete) AS avg_completion
FROM Genre
JOIN Book ON Genre.genre_id = Book.genre_id
JOIN Progress ON Book.book_id = Progress.book_id
GROUP BY Genre.genre_id, Genre.name
ORDER BY avg_completion DESC;

-- 16. Total time_spent per user (SUM).
-- Total reading time spent per user
SELECT 
  User.username,
  SUM(Progress.time_spent) AS total_minutes
FROM User
JOIN Progress ON User.user_id = Progress.user_id
GROUP BY User.user_id, User.username
ORDER BY total_minutes DESC;

-- 17. Count notes per user per book with HAVING count > X.
-- Count notes per user per book, only show heavy note-takers
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

-- 18. Which genre has the most books (ORDER BY + LIMIT).
-- Genre with the most books
SELECT 
  Genre.name AS genre_name,
  COUNT(Book.book_id) AS num_books
FROM Genre
JOIN Book ON Genre.genre_id = Book.genre_id
GROUP BY Genre.genre_id
ORDER BY num_books DESC
LIMIT 1;

-- ============================================================
-- D. Set Operations (3 queries)
-- ============================================================

-- 19. UNION: Combine book titles from genre A and genre B.
-- UNION: Combine book titles from two genres
-- Books from genre 1 OR genre 2, no duplicates due to UNION.
SELECT title FROM Book WHERE genre_id = 1
UNION
SELECT title FROM Book WHERE genre_id = 2
ORDER BY title;

-- 20. INTERSECT (simulated): Books that appear in both Note and Progress.
-- INTERSECT (simulated): Books that have both notes AND progress
SELECT DISTINCT b.title
FROM Book b
WHERE b.book_id IN (SELECT book_id FROM Note)
  AND b.book_id IN (SELECT book_id FROM Progress);

-- 21. MINUS (simulated): Books that have no notes.
-- MINUS (simulated): Books with no notes
SELECT b.title
FROM Book b
WHERE NOT EXISTS (
    SELECT 1
    FROM Note n
    WHERE n.book_id = b.book_id
)
ORDER BY b.title;

-- ============================================================
-- E. Subqueries / Nested Queries (5 queries)
-- ============================================================

-- 22. Books whose percent_complete is above the overall average.
-- Books with percent_complete above overall average
SELECT b.book_id, b.title, p.percent_complete
FROM Book b
JOIN Progress p ON b.book_id = p.book_id
WHERE p.percent_complete >
      (SELECT AVG(percent_complete) FROM Progress);

-- 23. Users who wrote more notes than the average note-writer.
-- Users who wrote more notes than the average note count per user
SELECT u.user_id, u.username, COUNT(n.note_id) AS note_count
FROM User u
JOIN Note n ON u.user_id = n.user_id
GROUP BY u.user_id
HAVING COUNT(n.note_id) >
       (SELECT AVG(note_count)
        FROM (
            SELECT COUNT(*) AS note_count
            FROM Note
            GROUP BY user_id
        ) AS temp);

-- 24. Books belonging to genres that have more than 3 books.
-- Books from genres that have more than 3 books total
SELECT b.book_id, b.title
FROM Book b
WHERE b.genre_id IN (
    SELECT genre_id
    FROM Book
    GROUP BY genre_id
    HAVING COUNT(*) > 3
);

-- 25. Authors who appear in 2 or more books (HAVING subquery).
-- Authors who appear in two or more books
SELECT a.author_id, a.name, COUNT(*) AS appearances
FROM Author a
JOIN BookAuthor ba ON a.author_id = ba.author_id
GROUP BY a.author_id
HAVING COUNT(*) >= 2;

-- 26. Books that have no progress record using NOT EXISTS.
-- Books with no progress record
SELECT b.book_id, b.title
FROM Book b
WHERE NOT EXISTS (
    SELECT 1
    FROM Progress p
    WHERE p.book_id = b.book_id
);