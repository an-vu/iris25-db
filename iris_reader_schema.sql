-- ============================================================
-- Iris Reader '25 Database Schema
-- Author: [Your Name]
-- Target DBMS: MySQL
-- Description: SQL DDL for all tables and relationships
-- ============================================================

-- Drop existing tables (safeguard for re-runs)
DROP TABLE IF EXISTS UserSettings;
DROP TABLE IF EXISTS Note;
DROP TABLE IF EXISTS Progress;
DROP TABLE IF EXISTS BookAuthor;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS User;

-- ============================================================
-- 1. User Table
-- ============================================================
CREATE TABLE User (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  role VARCHAR(50),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. Author Table
-- ============================================================
CREATE TABLE Author (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL
);

-- ============================================================
-- 3. Genre Table
-- ============================================================
CREATE TABLE Genre (
  genre_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- 4. Book Table
-- ============================================================
CREATE TABLE Book (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  title VARCHAR(200) NOT NULL,
  genre_id INT NOT NULL,
  total_chapters INT,
  year_published INT,
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE SET NULL,
  FOREIGN KEY (genre_id) REFERENCES Genre(genre_id) ON DELETE RESTRICT
);

-- ============================================================
-- 5. BookAuthor (Bridge Table for M:N)
-- ============================================================
CREATE TABLE BookAuthor (
  book_id INT,
  author_id INT,
  PRIMARY KEY (book_id, author_id),
  FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE,
  FOREIGN KEY (author_id) REFERENCES Author(author_id) ON DELETE CASCADE
);

-- ============================================================
-- 6. Progress (Bridge Table for User ↔ Book)
-- ============================================================
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

-- ============================================================
-- 7. Note Table
-- ============================================================
CREATE TABLE Note (
  note_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  book_id INT NOT NULL,
  chapter_number INT NOT NULL,
  content TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE
);

-- ============================================================
-- 8. UserSettings (1:1 with User)
-- ============================================================
CREATE TABLE UserSettings (
  user_id INT PRIMARY KEY,
  dark_mode BOOLEAN,
  language VARCHAR(50),
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- ============================================================
-- End of Schema
-- ============================================================
