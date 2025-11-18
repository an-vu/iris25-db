-- ============================================================
-- Iris '25 Sample Data
-- Run iris25_sql_specification_ddl.sql first to set up the schema.
-- Then execute iris25_sample_data.sql to populate it.
-- ============================================================

-- ===== USERS =====
INSERT INTO User (username, email, role, created_at)
VALUES
('anvu', 'anvu@gmail.com', 'developer', '2020-10-01 09:43:23'),
('emma', 'emma@icloud.com', 'tester', '2025-08-12 14:12:04'),
('nori', 'nori@yahoo.com', 'child', '2018-11-29 18:24:15');

-- ===== AUTHORS =====
INSERT INTO Author (name) VALUES
('Jeff Johnson'),
('Abraham Silberschatz'),
('Henry F. Korth'),
('S. Sudarshan'),
('Alice Zhao'),
('Patrick Horvath'),
('Pailin Chongchitnant'),
('Julia Child'),
('Louisette Bertholle'),
('Simone Beck'),
('J. Kenji López-Alt'),
('George Orwell'),
('Russell Baker'),
('Akira Toriyama'),
('Don Norman'),
('Haoyu Wang');

-- ===== GENRES =====
INSERT INTO Genre (name) VALUES
('Computers & Technology'),
('Cookbooks / Food & Wine'),
('Literature & Fiction'),
('Politics / Social Sciences'),
('Arts & Design'),
('Education / Textbook');

-- ===== BOOKS =====
INSERT INTO Book (user_id, title, genre_id, total_chapters, year_published, edition, added_at)
VALUES
(1, 'Designing with the Mind in Mind: Simple Guide to Understanding User Interface Design Guidelines', 1, 12, 2019, '3rd Edition', '2024-03-14 09:17:22'),
(1, 'Database System Concepts', 1, 16, 2020, '7th Edition', '2023-12-28 16:42:05'),
(1, 'SQL Pocket Guide: A Guide to SQL Usage', 1, 10, 2021, '4th Edition', '2024-05-03 08:55:49'),
(1, 'Beneath the Trees Where Nobody Sees', 3, 18, 2024, NULL, '2025-02-11 14:26:11'),

(2, 'Sabai: 100 Simple Thai Recipes for Any Day of the Week', 2, 10, 2023, NULL, '2024-11-19 18:04:57'),
(2, 'Mastering the Art of French Cooking, Volume 1: A Cookbook', 2, 24, 1983, NULL, '2025-01-07 07:31:09'),
(2, 'Mastering the Art of French Cooking, Volume 2: A Classic Continued', 2, 20, 1983, NULL, '2025-02-02 15:18:44'),

(2, 'The Food Lab: Better Home Cooking Through Science', 2, 14, 2015, NULL, '2016-09-12 12:09:30'),
(3, 'Animal Farm: 75th Anniversary Edition Mass Market', 4, 10, 2004, NULL, '2018-10-03 21:47:02'),
(3, 'Dragon Ball, Volume 1: The Monkey King (Shonen Jump Graphic Novel)', 3, 8, 2003, NULL, '2023-03-22 10:06:51'),
(3, 'The Design of Everyday Things: Revised and Expanded Edition', 5, 12, 2013, 'Revised Edition', '2025-04-10 19:22:36');

-- ===== BOOKAUTHOR =====
INSERT INTO BookAuthor (book_id, author_id) VALUES
(1, 1),
(2, 2), (2, 3), (2, 4),
(3, 5),
(4, 6),
(5, 7),
(6, 8), (6, 9), (6, 10),
(7, 8), (7, 10),
(8, 11),
(9, 12), (9, 13),
(10, 14),
(11, 15);

-- ===== PROGRESS =====
INSERT INTO Progress (user_id, book_id, percent_complete, time_spent, last_updated)
VALUES
(1, 2, 82, 243, '2025-10-12 14:47:33'),
(1, 3, 98, 352, '2024-12-05 08:26:51'),

(2, 5, 100, 420, '2023-11-18 19:12:09'),
(2, 6, 1, 5, '2022-03-07 06:54:22'),
(2, 8, 4, 42, '2004-06-19 17:08:40'),

(3, 4, 67, 194, '2017-01-22 10:39:58'),
(3, 10, 100, 568, '2020-05-14 21:03:17');


-- ===== NOTES =====
INSERT INTO Note (user_id, book_id, chapter_number, page_number, content, created_at)
VALUES
(1, 2, 6, 254, 'Coding in MySQL is not that bad, but I think the E-R model can make things more complicated.', '2024-10-31 06:41:28'),
(1, 2, 6, 262, 'I keep forgetting what the diamond shape means because I barely ever use it...', '2024-12-1 18:13:22'),
(1, 2, 9, 412, 'I learned Servlet + SQL combo in Advanced Java Programming. I wonder if Servlet could work with Python because Java is scary.', '2022-07-11 05:12:01'),

(2, 5, 3, 87, 'Tom Yam Pla: clear broth fish soup with lemongrass and kaffir lime leaves.', '2022-08-1 12:42:10'),
(2, 5, 5, 145, 'Tom Kha Gai: white broth chicken soup with coconut and galangal.', '2022-08-18 2:15:03'),
(2, 5, 7, 192, 'Red snapper is a good choice for Tom Yam Pla.', '2023-09-22 17:14:22'),
(2, 5, 9, 245, 'Thai chili powder can get really spicy so start light.', '2023-06-12 5:01:13'),

(3, 10, 3, 58, 'Woof woof woof!', '2014-05-12 07:25:03'),
(3, 10, 3, 69, 'Grrrrrrr', '2019-12-15 22:59:04');

-- ===== USER SETTINGS =====
INSERT INTO UserSettings (user_id, dark_mode, language)
VALUES
(1, TRUE, 'English'),
(2, FALSE, 'English'),
(3, TRUE, 'Shibanese');

-- ============================================================
-- End of iris25_sample_data.sql
-- ============================================================
