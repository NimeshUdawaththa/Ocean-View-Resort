package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for the `users` table.
 * Handles all SQL operations; returns model (entity) objects.
 */
public class UserDAO {

    // ── Authenticate ──────────────────────────────────────────────────────────
    public User authenticate(String username, String password) {
        String sql = "SELECT id, username, password, role, email, full_name " +
                     "FROM users WHERE username = ? AND password = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO] authenticate error: " + e.getMessage());
        }
        return null;
    }

    // ── Insert user ───────────────────────────────────────────────────────────
    public String insertUser(String username, String password,
                             String email, String fullName, String role) {
        String sql = "INSERT INTO users (username, password, role, email, full_name) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, role);
            ps.setString(4, email);
            ps.setString(5, fullName);
            ps.executeUpdate();
            return "ok";
        } catch (SQLIntegrityConstraintViolationException e) {
            return "duplicate";
        } catch (SQLException e) {
            System.err.println("[UserDAO] insertUser error: " + e.getMessage());
            return "error";
        }
    }

    // ── Find all managed users (manager + reception) ──────────────────────────
    public List<User> findManagedUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, username, password, role, email, full_name " +
                     "FROM users WHERE role IN ('manager','reception') " +
                     "ORDER BY role, full_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[UserDAO] findManagedUsers error: " + e.getMessage());
        }
        return list;
    }

    // ── Update user ───────────────────────────────────────────────────────────
    public String updateUser(int id, String username, String password,
                             String email, String fullName, String role) {
        boolean updatePwd = password != null && !password.isBlank();
        String sql = updatePwd
            ? "UPDATE users SET username=?, password=?, email=?, full_name=?, role=? WHERE id=?"
            : "UPDATE users SET username=?, email=?, full_name=?, role=? WHERE id=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            if (updatePwd) {
                ps.setString(2, password);
                ps.setString(3, email);
                ps.setString(4, fullName);
                ps.setString(5, role);
                ps.setInt(6, id);
            } else {
                ps.setString(2, email);
                ps.setString(3, fullName);
                ps.setString(4, role);
                ps.setInt(5, id);
            }
            ps.executeUpdate();
            return "ok";
        } catch (SQLIntegrityConstraintViolationException e) {
            return "duplicate";
        } catch (SQLException e) {
            System.err.println("[UserDAO] updateUser error: " + e.getMessage());
            return "error";
        }
    }

    // ── Delete user (admin-protected) ─────────────────────────────────────────
    public String deleteUser(int id) {
        String checkSql  = "SELECT role FROM users WHERE id = ?";
        String deleteSql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setInt(1, id);
                try (ResultSet rs = check.executeQuery()) {
                    if (!rs.next()) return "error";
                    if (User.ROLE_ADMIN.equals(rs.getString("role"))) return "protected";
                }
            }
            try (PreparedStatement del = conn.prepareStatement(deleteSql)) {
                del.setInt(1, id);
                del.executeUpdate();
            }
            return "ok";
        } catch (SQLException e) {
            System.err.println("[UserDAO] deleteUser error: " + e.getMessage());
            return "error";
        }
    }

    // ── Row mapper ────────────────────────────────────────────────────────────
    private User mapRow(ResultSet rs) throws SQLException {
        return new User(
            rs.getInt("id"),
            rs.getString("username"),
            rs.getString("password"),
            rs.getString("role"),
            rs.getString("email"),
            rs.getString("full_name")
        );
    }
}
