package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Room;
import com.example.oceanviewresort.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the `rooms` table.
 * Handles all SQL operations; returns model (entity) objects.
 */
public class RoomDAO {

    // ── Insert ────────────────────────────────────────────────────────────────
    public String insert(String roomNumber, String roomType, String description,
                         BigDecimal ratePerNight, String status, int floor) {
        String sql = "INSERT INTO rooms " +
                     "(room_number, room_type, description, rate_per_night, status, floor) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomNumber);
            ps.setString(2, roomType);
            ps.setString(3, description != null ? description : "");
            ps.setBigDecimal(4, ratePerNight);
            ps.setString(5, status != null ? status : Room.STATUS_AVAILABLE);
            ps.setInt(6, floor > 0 ? floor : 1);
            ps.executeUpdate();
            return null; // success
        } catch (SQLIntegrityConstraintViolationException e) {
            return "Room number \"" + roomNumber + "\" already exists.";
        } catch (SQLException e) {
            System.err.println("[RoomDAO] insert error: " + e.getMessage());
            return "Database error: " + e.getMessage();
        }
    }

    // ── Update ────────────────────────────────────────────────────────────────
    public String update(int id, String roomNumber, String roomType, String description,
                         BigDecimal ratePerNight, String status, int floor) {
        String sql = "UPDATE rooms SET room_number=?, room_type=?, description=?, " +
                     "rate_per_night=?, status=?, floor=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomNumber);
            ps.setString(2, roomType);
            ps.setString(3, description != null ? description : "");
            ps.setBigDecimal(4, ratePerNight);
            ps.setString(5, status);
            ps.setInt(6, floor > 0 ? floor : 1);
            ps.setInt(7, id);
            int updated = ps.executeUpdate();
            return updated > 0 ? null : "Room not found.";
        } catch (SQLIntegrityConstraintViolationException e) {
            return "Room number \"" + roomNumber + "\" already exists.";
        } catch (SQLException e) {
            System.err.println("[RoomDAO] update error: " + e.getMessage());
            return "Database error: " + e.getMessage();
        }
    }

    // ── Delete ────────────────────────────────────────────────────────────────
    public String delete(int id) {
        String sql = "DELETE FROM rooms WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            int deleted = ps.executeUpdate();
            return deleted > 0 ? null : "Room not found.";
        } catch (SQLException e) {
            System.err.println("[RoomDAO] delete error: " + e.getMessage());
            return "Database error: " + e.getMessage();
        }
    }

    // ── Find by id ────────────────────────────────────────────────────────────
    public Room findById(int id) {
        String sql = "SELECT * FROM rooms WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[RoomDAO] findById error: " + e.getMessage());
        }
        return null;
    }

    // ── Find all ──────────────────────────────────────────────────────────────
    public List<Room> findAll() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM rooms ORDER BY floor, room_number";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[RoomDAO] findAll error: " + e.getMessage());
        }
        return list;
    }

    // ── Update status only ────────────────────────────────────────────────────
    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE rooms SET status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[RoomDAO] updateStatus error: " + e.getMessage());
            return false;
        }
    }

    // ── Find by status ────────────────────────────────────────────────────────
    public List<Room> findByStatus(String status) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM rooms WHERE status = ? ORDER BY floor, room_number";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[RoomDAO] findByStatus error: " + e.getMessage());
        }
        return list;
    }

    // ── Row mapper ────────────────────────────────────────────────────────────
    private Room mapRow(ResultSet rs) throws SQLException {
        return new Room(
            rs.getInt("id"),
            rs.getString("room_number"),
            rs.getString("room_type"),
            rs.getString("description"),
            rs.getBigDecimal("rate_per_night"),
            rs.getString("status"),
            rs.getInt("floor"),
            rs.getString("created_at")
        );
    }
}
