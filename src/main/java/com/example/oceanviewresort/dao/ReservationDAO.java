package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the `reservations` table.
 * Handles all SQL operations; returns model (entity) objects.
 */
public class ReservationDAO {

    // ── Insert ────────────────────────────────────────────────────────────────
    public boolean insert(String resNum, String guestName, String address,
                          String contactNumber, String roomType, int roomId,
                          LocalDate checkIn, LocalDate checkOut,
                          BigDecimal totalAmount, int createdBy) {
        String sql = "INSERT INTO reservations " +
            "(reservation_number, guest_name, address, contact_number, room_type, room_id, " +
            " check_in_date, check_out_date, total_amount, status, created_by) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, resNum);
            ps.setString(2, guestName);
            ps.setString(3, address);
            ps.setString(4, contactNumber);
            ps.setString(5, roomType);
            ps.setInt(6, roomId);
            ps.setDate(7, Date.valueOf(checkIn));
            ps.setDate(8, Date.valueOf(checkOut));
            ps.setBigDecimal(9, totalAmount);
            ps.setInt(10, createdBy);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] insert error: " + e.getMessage());
            return false;
        }
    }

    // ── Update ────────────────────────────────────────────────────────────────
    public boolean update(int id, LocalDate checkIn, LocalDate checkOut,
                          BigDecimal totalAmount, String address, String roomType, int roomId) {
        String sql = "UPDATE reservations SET check_in_date=?, check_out_date=?, " +
                     "total_amount=?, address=?, room_type=?, room_id=? WHERE id=? AND status='active'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(checkIn));
            ps.setDate(2, Date.valueOf(checkOut));
            ps.setBigDecimal(3, totalAmount);
            ps.setString(4, address);
            ps.setString(5, roomType);
            ps.setInt(6, roomId);
            ps.setInt(7, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] update error: " + e.getMessage());
            return false;
        }
    }

    // ── Sync guest info across all their reservations ─────────────────────────
    public void syncGuestInfo(String oldContactNumber, String newGuestName,
                               String newContactNumber, String newAddress) {
        String sql = "UPDATE reservations SET guest_name=?, contact_number=?, address=? "
                   + "WHERE contact_number=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newGuestName);
            ps.setString(2, newContactNumber);
            ps.setString(3, newAddress != null ? newAddress : "");
            ps.setString(4, oldContactNumber);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] syncGuestInfo error: " + e.getMessage());
        }
    }

    // ── Cancel ────────────────────────────────────────────────────────────────
    public boolean cancel(int id) {
        String sql = "UPDATE reservations SET status='cancelled' WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] cancel error: " + e.getMessage());
            return false;
        }
    }

    // ── Expire checked-out reservations (called by scheduler) ─────────────────
    /**
     * Finds every active reservation whose check-out date is in the past,
     * marks it as 'checked_out', and frees its room back to 'available'.
     * @return number of reservations expired
     */
    public int expireCheckedOut() {
        String freeRoomsSql =
            "UPDATE rooms SET status = 'available' " +
            "WHERE id IN (" +
            "  SELECT room_id FROM reservations " +
            "  WHERE status = 'active' AND check_out_date < CURDATE()" +
            "  AND room_id IS NOT NULL AND room_id > 0)";
        String expireSql =
            "UPDATE reservations SET status = 'checked_out' " +
            "WHERE status = 'active' AND check_out_date < CURDATE()";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (Statement st = conn.createStatement()) {
                st.executeUpdate(freeRoomsSql);
                int affected = st.executeUpdate(expireSql);
                conn.commit();
                if (affected > 0)
                    System.out.println("[ReservationDAO] Expired " + affected + " checked-out reservation(s).");
                return affected;
            } catch (SQLException e) {
                conn.rollback();
                System.err.println("[ReservationDAO] expireCheckedOut error: " + e.getMessage());
                return 0;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] expireCheckedOut connection error: " + e.getMessage());
            return 0;
        }
    }

    // ── Find by reservation number ────────────────────────────────────────────
    public Reservation findByNumber(String reservationNumber) {
        String sql = "SELECT r.*, u.full_name AS created_by_name " +
                     "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
                     "WHERE r.reservation_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reservationNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] findByNumber error: " + e.getMessage());
        }
        return null;
    }

    // ── Find by id ────────────────────────────────────────────────────────────
    public Reservation findById(int id) {
        String sql = "SELECT r.*, u.full_name AS created_by_name " +
                     "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
                     "WHERE r.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] findById error: " + e.getMessage());
        }
        return null;
    }

    // ── Find all ──────────────────────────────────────────────────────────────
    public List<Reservation> findAll() {
        return find(null);
    }

    // ── Find by user ──────────────────────────────────────────────────────────
    public List<Reservation> findByUser(int userId) {
        return find(userId);
    }

    // ── Find by contact number ──────────────────────────────────────────
    public List<Reservation> findByContactNumber(String contactNumber) {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.full_name AS created_by_name " +
                     "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
                     "WHERE r.contact_number = ? ORDER BY r.check_in_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, contactNumber);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] findByContactNumber error: " + e.getMessage());
        }
        return list;
    }

    // ── Shared query ──────────────────────────────────────────────────────────
    private List<Reservation> find(Integer userId) {
        List<Reservation> list = new ArrayList<>();
        String sql = userId == null
            ? "SELECT r.*, u.full_name AS created_by_name " +
              "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
              "ORDER BY r.created_at DESC"
            : "SELECT r.*, u.full_name AS created_by_name " +
              "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
              "WHERE r.created_by = ? ORDER BY r.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId != null) ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] find error: " + e.getMessage());
        }
        return list;
    }

    // ── Row mapper ────────────────────────────────────────────────────────────
    private Reservation mapRow(ResultSet rs) throws SQLException {
        Date ci = rs.getDate("check_in_date");
        Date co = rs.getDate("check_out_date");
        return new Reservation(
            rs.getInt("id"),
            rs.getString("reservation_number"),
            rs.getString("guest_name"),
            rs.getString("address"),
            rs.getString("contact_number"),
            rs.getString("room_type"),
            rs.getInt("room_id"),
            ci != null ? ci.toLocalDate() : null,
            co != null ? co.toLocalDate() : null,
            rs.getBigDecimal("total_amount"),
            rs.getString("status"),
            rs.getInt("created_by"),
            rs.getString("created_by_name"),
            rs.getString("created_at")
        );
    }
}
