-- ============================================================
-- OceanView Resort – Database Schema
-- Run this script once in MySQL before starting the application
-- ============================================================

CREATE DATABASE IF NOT EXISTS OceanView
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE OceanView;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(50)  NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role       VARCHAR(20)  NOT NULL DEFAULT 'user',
    email      VARCHAR(100),
    full_name  VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default admin account  (password: admin123)
INSERT INTO users (username, password, role, email, full_name)
VALUES ('admin', 'admin123', 'admin', 'admin@oceanviewresort.com', 'Admin User')
ON DUPLICATE KEY UPDATE username = username;
