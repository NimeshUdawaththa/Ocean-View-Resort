package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.List;

/**
 * Service layer handling user-related business logic.
 */
public class UserService {

    /**
     * Validates login credentials against the database.
     *
     * @param username  the username entered by the user
     * @param password  the plain-text password entered by the user
     * @return a User object if credentials are valid, null otherwise
     */
    public User authenticate(String username, String password) {
        String sql = "SELECT id, username, password, role, email, full_name " +
                     "FROM users WHERE username = ? AND password = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
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

        } catch (SQLException e) {
            System.err.println("[UserService] DB error during authentication: " + e.getMessage());
        }

        return null;   // authentication failed
    }

    /**
     * Creates a new reception-role user.  (used by Manager)
     */
    public String addReception(String username, String password, String email, String fullName) {
        return addUser(username, password, email, fullName, User.ROLE_RECEPTION);
    }

    /**
     * Creates a user with any role.  (used by Admin)
     *
     * @param role  one of User.ROLE_* constants
     * @return "ok" | "duplicate" | "error"
     */
    public String addUser(String username, String password, String email, String fullName, String role) {
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
            System.err.println("[UserService] DB error while adding user: " + e.getMessage());
            return "error";
        }
    }

    /**
     * Returns all manager and reception users (excludes admin).
     */
    public List<User> getManagedUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, username, password, role, email, full_name " +
                     "FROM users WHERE role IN ('manager','reception') ORDER BY role, full_name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new User(
                    rs.getInt("id"),
                    rs.getString("username"),
                    rs.getString("password"),
                    rs.getString("role"),
                    rs.getString("email"),
                    rs.getString("full_name")
                ));
            }
        } catch (SQLException e) {
            System.err.println("[UserService] DB error in getManagedUsers: " + e.getMessage());
        }
        return list;
    }

    /**
     * Updates a user's details. Password is only updated if a non-blank value is supplied.
     * @return "ok" | "duplicate" | "error"
     */
    public String updateUser(int id, String username, String password,
                             String email, String fullName, String role) {
        String sql;
        boolean updatePassword = password != null && !password.isBlank();

        if (updatePassword) {
            sql = "UPDATE users SET username=?, password=?, email=?, full_name=?, role=? WHERE id=?";
        } else {
            sql = "UPDATE users SET username=?, email=?, full_name=?, role=? WHERE id=?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            if (updatePassword) {
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
            System.err.println("[UserService] DB error in updateUser: " + e.getMessage());
            return "error";
        }
    }

    /**
     * Deletes a user by id. Admin (role='admin') cannot be deleted.
     * @return "ok" | "protected" | "error"
     */
    public String deleteUser(int id) {
        // Safety: never delete an admin
        String checkSql = "SELECT role FROM users WHERE id = ?";
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
            System.err.println("[UserService] DB error in deleteUser: " + e.getMessage());
            return "error";
        }
    }
}
