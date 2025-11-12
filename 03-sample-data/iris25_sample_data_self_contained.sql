-- ============================================================
-- Iris '25 Sample Data  (Self-Contained Version)
-- Includes minimal schema + data
-- Run standalone (no other files required)
-- ============================================================

-- Drop existing tables if any
DROP TABLE IF EXISTS UserSettings;
DROP TABLE IF EXISTS Note;
DROP TABLE IF EXISTS Progress;
DROP TABLE IF EXISTS BookAuthor;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS User;

-- ============================================================
-- SCHEMA CREATION
-- ============================================================

CREATE TABLE User (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  role VARCHAR(50),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Author (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL
);

CREATE TABLE Genre (
  genre_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Book (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  title VARCHAR(200) NOT NULL,
  genre_id INT NOT NULL,
  total_chapters INT,
  year_published INT,
  edition VARCHAR(50),
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE SET NULL,
  FOREIGN KEY (genre_id) REFERENCES Genre(genre_id) ON DELETE RESTRICT
);

CREATE TABLE BookAuthor (
  book_id INT,
  author_id INT,
  PRIMARY KEY (book_id, author_id),
  FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE,
  FOREIGN KEY (author_id) REFERENCES Author(author_id) ON DELETE CASCADE
);

CREATE TABLE Progress (
  user_id INT,
  book_id INT,
  percent_complete FLOAT DEFAULT 0 CHECK (percent_complete BETWEEN 0 AND 100),
  time_spent INT DEFAULT 0,
  last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, book_id),
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE
);

CREATE TABLE Note (
  note_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  book_id INT NOT NULL,
  chapter_number INT NOT NULL,
  page_number INT,
  content TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE
);

CREATE TABLE UserSettings (
  user_id INT PRIMARY KEY,
  dark_mode BOOLEAN,
  language VARCHAR(100),
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT INTO User (username, email, role, created_at) VALUES
('anvu', 'anvu@example.com', 'developer', '2025-11-01 09:45:00'),
('emma', 'emma@example.com', 'tester', '2025-11-02 14:10:00'),
('nori', 'nori@example.com', 'child', '2025-11-03 18:25:00');

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

INSERT INTO Genre (name) VALUES
('Computers & Technology'),
('Cookbooks / Food & Wine'),
('Literature & Fiction'),
('Politics / Social Sciences'),
('Arts & Design'),
('Education / Textbook');

INSERT INTO Book (user_id, title, genre_id, total_chapters, year_published, edition, added_at) VALUES
(1, 'Designing with the Mind in Mind', 1, 12, 2019, '3rd Edition', '2025-11-04 11:00:00'),
(1, 'Database System Concepts', 1, 16, 2020, '7th Edition', '2025-11-04 11:10:00'),
(1, 'SQL Pocket Guide', 1, 10, 2021, '4th Edition', '2025-11-05 09:30:00'),
(1, 'Beneath the Trees Where Nobody Sees', 3, 18, 2024, NULL, '2025-11-05 10:00:00'),
(2, 'Sabai: 100 Simple Thai Recipes', 2, 10, 2023, NULL, '2025-11-06 14:00:00'),
(2, 'Mastering the Art of French Cooking Vol. 1', 2, 24, 1983, NULL, '2025-11-07 08:45:00'),
(2, 'Mastering the Art of French Cooking Vol. 2', 2, 20, 1983, NULL, '2025-11-07 09:15:00'),
(2, 'The Food Lab', 2, 14, 2015, NULL, '2025-11-08 10:30:00'),
(3, 'Animal Farm', 4, 10, 2004, NULL, '2025-11-09 13:00:00'),
(3, 'Dragon Ball Vol. 1', 3, 8, 2003, NULL, '2025-11-09 13:15:00'),
(3, 'The Design of Everyday Things', 5, 12, 2013, 'Revised Edition', '2025-11-09 13:45:00');

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

INSERT INTO Progress (user_id, book_id, percent_complete, time_spent, last_updated) VALUES
(1, 2, 85, 320, '2025-11-10 15:30:00'),
(1, 3, 98, 270, '2025-11-10 16:00:00'),
(2, 5, 100, 500, '2025-11-10 18:00:00'),
(2, 6, 1, 5, '2025-11-10 18:10:00'),
(2, 8, 5, 25, '2025-11-10 18:15:00'),
(3, 4, 70, 180, '2025-11-11 09:00:00'),
(3, 10, 100, 240, '2025-11-11 09:15:00');

INSERT INTO Note (user_id, book_id, chapter_number, page_number, content, created_at) VALUES
(1, 2, 6, 254, 'Coding in MySQL is not that bad...', '2025-11-11 10:00:00'),
(1, 2, 9, 412, 'Servlet + SQL combo in Java...', '2025-11-11 10:15:00'),
(2, 5, 5, 87, 'Tom Yam Pla recipe note...', '2025-11-11 10:30:00'),
(3, 10, 3, 58, 'Woof woof woof!', '2025-11-11 10:45:00'),
(3, 10, 3, 69, 'Grrrrrrr', '2025-11-11 10:50:00');

INSERT INTO UserSettings (user_id, dark_mode, language) VALUES
(1, TRUE, 'English'),
(2, FALSE, 'Vietnamese, Cantonese, Traditional Chinese'),
(3, TRUE, 'Dognese, Shibanese');

-- ============================================================
-- End of iris25_sample_data_self_contained.sql
-- ============================================================
