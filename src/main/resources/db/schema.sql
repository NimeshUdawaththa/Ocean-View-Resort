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

-- Insert default accounts (plain-text passwords for development)
INSERT INTO users (username, password, role, email, full_name) VALUES
    ('admin',     'admin123',     'admin',     'admin@oceanviewresort.com',     'Admin User'),
    ('manager',   'manager123',   'manager',   'manager@oceanviewresort.com',   'Resort Manager'),
    ('reception', 'reception123', 'reception', 'reception@oceanviewresort.com', 'Front Desk Staff')
ON DUPLICATE KEY UPDATE username = username;

-- Rooms table
CREATE TABLE IF NOT EXISTS rooms (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    room_number    VARCHAR(20)    NOT NULL UNIQUE,
    room_type      VARCHAR(50)    NOT NULL,
    description    TEXT,
    rate_per_night DECIMAL(10,2)  NOT NULL,
    status         VARCHAR(20)    NOT NULL DEFAULT 'available',
    floor          INT            DEFAULT 1,
    created_at     TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);

-- Default rooms
INSERT INTO rooms (room_number, room_type, description, rate_per_night, status, floor) VALUES
    ('101', 'Standard Room',    'Comfortable standard room with garden view',          80.00,  'available', 1),
    ('102', 'Standard Room',    'Comfortable standard room with garden view',          80.00,  'available', 1),
    ('201', 'Deluxe Room',      'Spacious deluxe room with city view balcony',        130.00, 'available', 2),
    ('202', 'Deluxe Room',      'Spacious deluxe room with city view balcony',        130.00, 'available', 2),
    ('301', 'Suite',            'Luxurious suite with separate living area',          220.00, 'available', 3),
    ('302', 'Suite',            'Luxurious suite with separate living area',          220.00, 'available', 3),
    ('401', 'Ocean View Suite', 'Premium ocean-facing suite with panoramic views',   300.00, 'available', 4),
    ('402', 'Ocean View Suite', 'Premium ocean-facing suite with panoramic views',   300.00, 'available', 4)
ON DUPLICATE KEY UPDATE room_number = room_number;

-- Reservations table
CREATE TABLE IF NOT EXISTS reservations (
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    reservation_number VARCHAR(20)  NOT NULL UNIQUE,
    guest_name         VARCHAR(100) NOT NULL,
    address            VARCHAR(255),
    contact_number     VARCHAR(30)  NOT NULL,
    room_type          VARCHAR(50)  NOT NULL,
    check_in_date      DATE         NOT NULL,
    check_out_date     DATE         NOT NULL,
    total_amount       DECIMAL(10,2),
    status             VARCHAR(20)  NOT NULL DEFAULT 'active',
    created_by         INT,
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);
