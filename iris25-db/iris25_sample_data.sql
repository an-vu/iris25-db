-- ============================================================
-- Iris '25 Sample Data
-- Run iris25_sql_specification_ddl.sql first to set up the schema.
-- Then execute iris25_sample_data.sql to populate it.
-- ============================================================

-- ===== USERS =====
INSERT INTO User (username, email, role, created_at)
VALUES
('anvu', 'anvu@example.com', 'developer', '2025-11-01 09:45:00'),
('emma', 'emma@example.com', 'tester', '2025-11-02 14:10:00'),
('nori', 'nori@example.com', 'child', '2025-11-03 18:25:00');

-- ===== AUTHORS =====
INSERT INTO Author (name) VALUES
('Jeff Johnson PhD'),
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
('Don Norman');

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
(1, 'Designing with the Mind in Mind: Simple Guide to Understanding User Interface Design Guidelines', 1, 12, 2019, '3rd Edition', '2025-11-04 11:00:00'),
(1, 'Database System Concepts', 1, 16, 2020, '7th Edition', '2025-11-04 11:10:00'),
(1, 'SQL Pocket Guide: A Guide to SQL Usage', 1, 10, 2021, '4th Edition', '2025-11-05 09:30:00'),
(1, 'Beneath the Trees Where Nobody Sees', 3, 18, 2024, NULL, '2025-11-05 10:00:00'),
(2, 'Sabai: 100 Simple Thai Recipes for Any Day of the Week', 2, 10, 2023, NULL, '2025-11-06 14:00:00'),
(2, 'Mastering the Art of French Cooking, Volume 1: A Cookbook', 2, 24, 1983, NULL, '2025-11-07 08:45:00'),
(2, 'Mastering the Art of French Cooking, Vol. 2: A Classic Continued', 2, 20, 1983, NULL, '2025-11-07 09:15:00'),
(2, 'The Food Lab: Better Home Cooking Through Science', 2, 14, 2015, NULL, '2025-11-08 10:30:00'),
(3, 'Animal Farm: 75th Anniversary Edition Mass Market', 4, 10, 2004, NULL, '2025-11-09 13:00:00'),
(3, 'Dragon Ball, Vol. 1: The Monkey King (Shonen Jump Graphic Novel)', 3, 8, 2003, NULL, '2025-11-09 13:15:00'),
(3, 'The Design of Everyday Things: Revised and Expanded Edition', 5, 12, 2013, 'Revised Edition', '2025-11-09 13:45:00');

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
(1, 2, 85, 320, '2025-11-10 15:30:00'),
(1, 3, 98, 270, '2025-11-10 16:00:00'),
(2, 5, 100, 500, '2025-11-10 18:00:00'),
(2, 6, 1, 5, '2025-11-10 18:10:00'),
(2, 8, 5, 25, '2025-11-10 18:15:00'),
(3, 4, 70, 180, '2025-11-11 09:00:00'),
(3, 10, 100, 240, '2025-11-11 09:15:00');

-- ===== NOTES =====
INSERT INTO Note (user_id, book_id, chapter_number, page_number, content, created_at)
VALUES
(1, 2, 6, 254, 'Coding in MySQL is not that bad, but I think the E-R model can make things more complicated. I still forget what the diamond means because I hardly ever use it.', '2025-11-11 10:00:00'),
(1, 2, 9, 412, 'I learned Servlet + SQL combo in Advanced Java Programming. I wonder if Servlet could work with Python because Java is scary.', '2025-11-11 10:15:00'),
(2, 5, 5, 87, 'Tom Yam Pla: clear broth fish soup with lemongrass and kaffir lime leaves. Tom Kha Gai: white broth chicken soup with coconut and galangal. Red snapper is a good choice for Tom Yam Pla. Thai chili powder can get really spicy so start light.', '2025-11-11 10:30:00'),
(3, 10, 3, 58, 'Woof woof woof!', '2025-11-11 10:45:00'),
(3, 10, 3, 69, 'Grrrrrrr', '2025-11-11 10:50:00');

-- ===== USER SETTINGS =====
INSERT INTO UserSettings (user_id, dark_mode, language)
VALUES
(1, TRUE, 'English'),
(2, FALSE, 'Vietnamese, Cantonese, Traditional Chinese'),
(3, TRUE, 'Dognese, Shibanese');

-- ============================================================
-- End of iris25_sample_data.sql
-- ============================================================
