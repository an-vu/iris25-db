/* ============================================================
   Iris Reader '25 Database – Query Set
   Prerequisites:
     MUST run:
       1) iris25_sql_specification_ddl.sql
       2) iris25_sample_data.sql
   ============================================================ */


/* ============================================================
   A. Basic Retrieval and Filters (3 queries)
   ============================================================ */

-- 1. Show all books added after a given date
SELECT 
  book_id, title, added_at
FROM Book
WHERE added_at > '2025-11-05'
ORDER BY added_at;

-- 2. Show all notes for Book 2, Chapter 6
SELECT 
  note_id, user_id, page_number, content, created_at
FROM Note
WHERE book_id = 2
  AND chapter_number = 6
ORDER BY page_number;

-- 3. Show all genres in alphabetical order
SELECT 
  genre_id, name
FROM Genre
ORDER BY name;


/* ============================================================
   B. Joins – All Join Types From Chapter 4 (10 queries)
   ============================================================ */

-- 4. Natural join: Show each book with its genre name
SELECT 
  title, name AS genre_name
FROM Book
NATURAL JOIN Genre;

-- 5. JOIN USING: Show each book with its author(s)
SELECT 
  Book.title,
  Author.name AS author_name
FROM Book
JOIN BookAuthor USING (book_id)
JOIN Author USING (author_id);

-- 6. Inner join: Show notes along with the username who wrote them
SELECT 
  User.username,
  Note.book_id,
  Note.chapter_number,
  Note.page_number,
  Note.content
FROM Note
JOIN User ON Note.user_id = User.user_id;

-- 7. Left outer join: Show all books, include progress if available
SELECT 
  Book.title,
  Progress.percent_complete,
  Progress.time_spent
FROM Book
LEFT JOIN Progress ON Book.book_id = Progress.book_id
ORDER BY Book.book_id;

-- 8. Right outer join: Show all authors, even those with zero books
SELECT 
  Author.name AS author_name,
  Book.title AS book_title
FROM BookAuthor
RIGHT JOIN Author ON BookAuthor.author_id = Author.author_id
LEFT JOIN Book ON BookAuthor.book_id = Book.book_id
ORDER BY Author.author_id;

-- 9. Full outer join (simulated): Show all books and all progress entries,
--    including unmatched rows on either side
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
  u1.user_id AS user_a,
  u2.user_id AS user_b,
  u1.language
FROM UserSettings u1
JOIN UserSettings u2 
  ON u1.language = u2.language
  AND u1.user_id < u2.user_id;

-- 11. Multi-way join: Show each book with its author and genre
SELECT
  Book.title,
  Author.name AS author_name,
  Genre.name AS genre_name
FROM Book
JOIN BookAuthor ON Book.book_id = BookAuthor.book_id
JOIN Author ON BookAuthor.author_id = Author.author_id
JOIN Genre ON Book.genre_id = Genre.genre_id
ORDER BY Book.book_id;

-- 12. Multi-way join: Show what each user is reading and their progress
SELECT
  User.username,
  Book.title,
  Progress.percent_complete,
  Progress.time_spent
FROM Progress
JOIN User ON Progress.user_id = User.user_id
JOIN Book ON Progress.book_id = Book.book_id
ORDER BY User.user_id;

-- 13. Multi-way join:
--     Show each note with the book title and username who wrote it
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


/* ============================================================
   C. Aggregation + Grouping + HAVING (5 queries)
   ============================================================ */

-- 14. Show how many books each user added
SELECT 
  User.user_id,
  User.username,
  COUNT(Book.book_id) AS books_added
FROM User
LEFT JOIN Book ON User.user_id = Book.user_id
GROUP BY User.user_id, User.username
ORDER BY books_added DESC;

-- 15. Show average percent_complete for each genre
SELECT 
  Genre.name AS genre_name,
  AVG(Progress.percent_complete) AS avg_completion
FROM Genre
JOIN Book ON Genre.genre_id = Book.genre_id
JOIN Progress ON Book.book_id = Progress.book_id
GROUP BY Genre.genre_id, Genre.name
ORDER BY avg_completion DESC;

-- 16. Show the total reading minutes logged by each user
SELECT 
  User.username,
  SUM(Progress.time_spent) AS total_minutes
FROM User
JOIN Progress ON User.user_id = Progress.user_id
GROUP BY User.user_id, User.username
ORDER BY total_minutes DESC;

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

-- 18. Show the genre with the most books
SELECT 
  Genre.name AS genre_name,
  COUNT(Book.book_id) AS num_books
FROM Genre
JOIN Book ON Genre.genre_id = Book.genre_id
GROUP BY Genre.genre_id
ORDER BY num_books DESC
LIMIT 1;


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
SELECT b.book_id, b.title, p.percent_complete
FROM Book b
JOIN Progress p ON b.book_id = p.book_id
WHERE p.percent_complete >
      (SELECT AVG(percent_complete) FROM Progress);

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
SELECT b.book_id, b.title
FROM Book b
WHERE b.genre_id IN (
    SELECT genre_id
    FROM Book
    GROUP BY genre_id
    HAVING COUNT(*) > 3
);

-- 25. Show authors who contributed to 2 or more books
SELECT a.author_id, a.name, COUNT(*) AS appearances
FROM Author a
JOIN BookAuthor ba ON a.author_id = ba.author_id
GROUP BY a.author_id
HAVING COUNT(*) >= 2;

-- 26. Show books that do not have any progress record
SELECT b.book_id, b.title
FROM Book b
WHERE NOT EXISTS (
    SELECT 1 FROM Progress p WHERE p.book_id = b.book_id
);