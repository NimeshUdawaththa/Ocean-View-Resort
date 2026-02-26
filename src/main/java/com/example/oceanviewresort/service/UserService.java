package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
}
