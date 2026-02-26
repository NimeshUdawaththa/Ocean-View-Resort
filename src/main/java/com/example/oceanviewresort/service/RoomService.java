package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.Room;
import com.example.oceanviewresort.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomService {

    // ── Add Room ─────────────────────────────────────────────────────────────
    /**
     * @return null on success, or an error message string on failure.
     */
    public String addRoom(String roomNumber, String roomType, String description,
                          double ratePerNight, String status, int floor) {
        if (roomNumber == null || roomNumber.isBlank()) return "Room number is required.";
        if (roomType   == null || roomType.isBlank())   return "Room type is required.";
        if (ratePerNight <= 0)                          return "Rate must be greater than 0.";

        String sql = "INSERT INTO rooms (room_number, room_type, description, rate_per_night, status, floor) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomNumber.trim());
            ps.setString(2, roomType.trim());
            ps.setString(3, description != null ? description.trim() : "");
            ps.setBigDecimal(4, BigDecimal.valueOf(ratePerNight));
            ps.setString(5, status != null ? status : Room.STATUS_AVAILABLE);
            ps.setInt(6, floor > 0 ? floor : 1);
            ps.executeUpdate();
            return null;  // success
        } catch (SQLIntegrityConstraintViolationException e) {
            return "Room number \"" + roomNumber + "\" already exists.";
        } catch (SQLException e) {
            System.err.println("[RoomService] addRoom error: " + e.getMessage());
            return "Database error: " + e.getMessage();
        }
    }

    // ── Update Room ──────────────────────────────────────────────────────────
    public String updateRoom(int id, String roomNumber, String roomType, String description,
                             double ratePerNight, String status, int floor) {
        if (roomNumber == null || roomNumber.isBlank()) return "Room number is required.";
        if (ratePerNight <= 0)                          return "Rate must be greater than 0.";

        String sql = "UPDATE rooms SET room_number=?, room_type=?, description=?, " +
                     "rate_per_night=?, status=?, floor=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomNumber.trim());
            ps.setString(2, roomType.trim());
            ps.setString(3, description != null ? description.trim() : "");
            ps.setBigDecimal(4, BigDecimal.valueOf(ratePerNight));
            ps.setString(5, status);
            ps.setInt(6, floor > 0 ? floor : 1);
            ps.setInt(7, id);
            int updated = ps.executeUpdate();
            return updated > 0 ? null : "Room not found.";
        } catch (SQLIntegrityConstraintViolationException e) {
            return "Room number \"" + roomNumber + "\" already exists.";
        } catch (SQLException e) {
            System.err.println("[RoomService] updateRoom error: " + e.getMessage());
            return "Database error: " + e.getMessage();
        }
    }

    // ── Delete Room ──────────────────────────────────────────────────────────
    public String deleteRoom(int id) {
        String sql = "DELETE FROM rooms WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            int deleted = ps.executeUpdate();
            return deleted > 0 ? null : "Room not found.";
        } catch (SQLException e) {
            System.err.println("[RoomService] deleteRoom error: " + e.getMessage());
            return "Database error: " + e.getMessage();
        }
    }

    // ── Get room by id ────────────────────────────────────────────────────────
    public Room getRoomById(int id) {
        String sql = "SELECT * FROM rooms WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[RoomService] getRoomById error: " + e.getMessage());
        }
        return null;
    }

    // ── List all rooms ────────────────────────────────────────────────────────
    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM rooms ORDER BY floor, room_number";
        try (Connection conn = DBConnection.getConnection();
             Statement  st   = conn.createStatement();
             ResultSet  rs   = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[RoomService] getAllRooms error: " + e.getMessage());
        }
        return list;
    }

    // ── List rooms filtered by status ─────────────────────────────────────────
    public List<Room> getRoomsByStatus(String status) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM rooms WHERE status = ? ORDER BY floor, room_number";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[RoomService] getRoomsByStatus error: " + e.getMessage());
        }
        return list;
    }

    // ── Map result set row ────────────────────────────────────────────────────
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
