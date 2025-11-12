-- ============================================================
-- Iris '25 Sample Instances
-- Displays example rows from each table after loading data
-- ============================================================

-- ===== USERS =====
SELECT * FROM User LIMIT 3;

-- Expected Output:
-- +---------+----------+-------------------+------------+---------------------+
-- | user_id | username | email             | role       | created_at          |
-- +---------+----------+-------------------+------------+---------------------+
-- | 1       | anvu     | anvu@example.com  | developer  | 2025-11-01 09:45:00 |
-- | 2       | emma     | emma@example.com  | tester     | 2025-11-02 14:10:00 |
-- | 3       | nori     | nori@example.com  | child      | 2025-11-03 18:25:00 |
-- +---------+----------+-------------------+------------+---------------------+


-- ===== AUTHORS =====
SELECT * FROM Author LIMIT 5;

-- Expected Output:
-- +-----------+----------------------+
-- | author_id | name                 |
-- +-----------+----------------------+
-- | 1         | Jeff Johnson PhD     |
-- | 2         | Abraham Silberschatz |
-- | 3         | Henry F. Korth       |
-- | 4         | S. Sudarshan         |
-- | 5         | Alice Zhao           |
-- +-----------+----------------------+


-- ===== GENRES =====
SELECT * FROM Genre;

-- Expected Output:
-- +----------+-----------------------------+
-- | genre_id | name                        |
-- +----------+-----------------------------+
-- | 1        | Computers & Technology      |
-- | 2        | Cookbooks / Food & Wine     |
-- | 3        | Literature & Fiction        |
-- | 4        | Politics / Social Sciences  |
-- | 5        | Arts & Design               |
-- | 6        | Education / Textbook        |
-- +----------+-----------------------------+


-- ===== BOOKS =====
SELECT book_id, title, genre_id, year_published, total_chapters
FROM Book LIMIT 5;

-- Expected Output (trimmed):
-- +----------+--------------------------------------------------------------+-----------+----------------+----------------+
-- | book_id  | title                                                        | genre_id  | year_published | total_chapters |
-- +----------+--------------------------------------------------------------+-----------+----------------+----------------+
-- | 1        | Designing with the Mind in Mind                              | 1         | 2019           | 12             |
-- | 2        | Database System Concepts                                     | 1         | 2020           | 16             |
-- | 3        | SQL Pocket Guide                                             | 1         | 2021           | 10             |
-- | 4        | Beneath the Trees Where Nobody Sees                          | 3         | 2024           | 18             |
-- | 5        | Sabai: 100 Simple Thai Recipes for Any Day of the Week       | 2         | 2023           | 10             |
-- +----------+--------------------------------------------------------------+-----------+----------------+----------------+


-- ===== BOOKAUTHOR =====
SELECT * FROM BookAuthor LIMIT 5;

-- Expected Output:
-- +----------+-----------+
-- | book_id  | author_id |
-- +----------+-----------+
-- | 1        | 1         |
-- | 2        | 2         |
-- | 2        | 3         |
-- | 2        | 4         |
-- | 3        | 5         |
-- +----------+-----------+


-- ===== PROGRESS =====
SELECT user_id, book_id, percent_complete, time_spent
FROM Progress LIMIT 5;

-- Expected Output:
-- +----------+----------+-----------------+------------+
-- | user_id  | book_id  | percent_complete| time_spent |
-- +----------+----------+-----------------+------------+
-- | 1        | 2        | 85              | 320        |
-- | 1        | 3        | 98              | 270        |
-- | 2        | 5        | 100             | 500        |
-- | 2        | 6        | 1               | 5          |
-- | 2        | 8        | 5               | 25         |
-- +----------+----------+-----------------+------------+


-- ===== NOTES =====
SELECT note_id, user_id, book_id, chapter_number, page_number
FROM Note LIMIT 5;

-- Expected Output:
-- +----------+----------+----------+----------------+-------------+
-- | note_id  | user_id  | book_id  | chapter_number | page_number |
-- +----------+----------+----------+----------------+-------------+
-- | 1        | 1        | 2        | 6              | 254         |
-- | 2        | 1        | 2        | 9              | 412         |
-- | 3        | 2        | 5        | 5              | 87          |
-- | 4        | 3        | 10       | 3              | 58          |
-- | 5        | 3        | 10       | 3              | 69          |
-- +----------+----------+----------+----------------+-------------+


-- ===== USER SETTINGS =====
SELECT * FROM UserSettings;

-- Expected Output:
-- +----------+-----------+-------------------------------------------+
-- | user_id  | dark_mode | language                                  |
-- +----------+-----------+-------------------------------------------+
-- | 1        | TRUE      | English                                   |
-- | 2        | FALSE     | Vietnamese, Cantonese, Traditional Chinese |
-- | 3        | TRUE      | Dognese, Shibanese                        |
-- +----------+-----------+-------------------------------------------+

-- ============================================================
-- End of iris25_sample_instances.sql
-- ============================================================
