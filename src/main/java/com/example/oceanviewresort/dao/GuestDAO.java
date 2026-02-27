package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Guest;
import com.example.oceanviewresort.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the `guests` table.
 * Guests are uniquely identified by mobile_number and email.
 */
public class GuestDAO {

    // ── Insert ────────────────────────────────────────────────────────────────
    /**
     * @return null on success, "duplicate_mobile", "duplicate_email", or "error:…"
     */
    public String insert(String fullName, String mobileNumber, String email,
                         String address, String nicNumber, String notes, int createdBy) {
        String sql = "INSERT INTO guests " +
                     "(full_name, mobile_number, email, address, nic_number, notes, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, mobileNumber);
            ps.setString(3, email != null && !email.isBlank() ? email : null);
            ps.setString(4, address);
            ps.setString(5, nicNumber);
            ps.setString(6, notes);
            ps.setInt(7, createdBy);
            ps.executeUpdate();
            return null; // success
        } catch (SQLIntegrityConstraintViolationException e) {
            String msg = e.getMessage().toLowerCase();
            if (msg.contains("mobile_number")) return "duplicate_mobile";
            if (msg.contains("email"))         return "duplicate_email";
            return "duplicate_mobile"; // fallback
        } catch (SQLException e) {
            System.err.println("[GuestDAO] insert error: " + e.getMessage());
            return "error:" + e.getMessage();
        }
    }

    // ── Find by id ────────────────────────────────────────────────────────────
    public Guest findById(int id) {
        String sql = "SELECT * FROM guests WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[GuestDAO] findById error: " + e.getMessage());
        }
        return null;
    }

    // ── Find by mobile number ─────────────────────────────────────────────────
    public Guest findByMobile(String mobileNumber) {
        String sql = "SELECT * FROM guests WHERE mobile_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, mobileNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[GuestDAO] findByMobile error: " + e.getMessage());
        }
        return null;
    }

    // ── Find by email ─────────────────────────────────────────────────────────
    public Guest findByEmail(String email) {
        String sql = "SELECT * FROM guests WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[GuestDAO] findByEmail error: " + e.getMessage());
        }
        return null;
    }

    // ── Find all ──────────────────────────────────────────────────────────────
    public List<Guest> findAll() {
        List<Guest> list = new ArrayList<>();
        String sql = "SELECT * FROM guests ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[GuestDAO] findAll error: " + e.getMessage());
        }
        return list;
    }

    // ── Search by keyword (name / mobile / email / NIC) ──────────────────────────
    public List<Guest> search(String keyword) {
        List<Guest> list = new ArrayList<>();
        String sql = "SELECT * FROM guests " +
                     "WHERE full_name LIKE ? OR mobile_number LIKE ? OR email LIKE ? OR nic_number LIKE ? " +
                     "ORDER BY full_name";
        String pattern = "%" + keyword + "%";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            ps.setString(4, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[GuestDAO] search error: " + e.getMessage());
        }
        return list;
    }

    // ── Update ─────────────────────────────────────────────────────────────
    /** @return null on success, "duplicate_mobile", "duplicate_email", or "error:…" */
    public String update(int id, String fullName, String mobileNumber, String email,
                         String address, String nicNumber, String notes) {
        String sql = "UPDATE guests SET full_name=?, mobile_number=?, email=?, " +
                     "address=?, nic_number=?, notes=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, mobileNumber);
            ps.setString(3, email != null && !email.isBlank() ? email : null);
            ps.setString(4, address);
            ps.setString(5, nicNumber);
            ps.setString(6, notes);
            ps.setInt(7, id);
            ps.executeUpdate();
            return null;
        } catch (SQLIntegrityConstraintViolationException e) {
            String msg = e.getMessage().toLowerCase();
            if (msg.contains("mobile_number")) return "duplicate_mobile";
            if (msg.contains("email"))         return "duplicate_email";
            return "duplicate_mobile";
        } catch (SQLException e) {
            System.err.println("[GuestDAO] update error: " + e.getMessage());
            return "error:" + e.getMessage();
        }
    }

    // ── Delete ─────────────────────────────────────────────────────────────
    public boolean delete(int id) {
        String sql = "DELETE FROM guests WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[GuestDAO] delete error: " + e.getMessage());
            return false;
        }
    }

    // ── Row mapper ───────────────────────────────────────────────────────────
    private Guest mapRow(ResultSet rs) throws SQLException {
        return new Guest(
            rs.getInt("id"),
            rs.getString("full_name"),
            rs.getString("mobile_number"),
            rs.getString("email"),
            rs.getString("address"),
            rs.getString("nic_number"),
            rs.getString("notes"),
            rs.getInt("created_by"),
            rs.getString("created_at")
        );
    }
}
