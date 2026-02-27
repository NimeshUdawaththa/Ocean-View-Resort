package com.example.oceanviewresort.service;

import com.example.oceanviewresort.dao.UserDAO;
import com.example.oceanviewresort.dto.UserDTO;
import com.example.oceanviewresort.model.User;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service layer for user-related business logic.
 * Delegates all DB access to {@link UserDAO} and returns
 * {@link UserDTO} objects to the controller layer.
 */
public class UserService {

    private final UserDAO userDAO = new UserDAO();

    /**
     * Authenticates a user.  Returns the full {@link User} entity so that the
     * session can store role and fullName; password is never sent to the client.
     */
    public User authenticate(String username, String password) {
        return userDAO.authenticate(username, password);
    }

    /** Manager-facing shortcut: always creates a reception account. */
    public String addReception(String username, String password,
                               String email, String fullName) {
        return addUser(username, password, email, fullName, User.ROLE_RECEPTION);
    }

    /**
     * Creates a user with any role.
     * @return "ok" | "duplicate" | "error"
     */
    public String addUser(String username, String password,
                          String email, String fullName, String role) {
        return userDAO.insertUser(username, password, email, fullName, role);
    }

    /**
     * Returns all manager + reception users as transfer objects (no password).
     */
    public List<UserDTO> getManagedUsers() {
        return userDAO.findManagedUsers().stream()
            .map(u -> new UserDTO(
                u.getId(),
                u.getUsername(),
                u.getFullName(),
                u.getEmail() != null ? u.getEmail() : "",
                u.getRole()))
            .collect(Collectors.toList());
    }

    /**
     * Updates a user record.  Password is only changed when a non-blank value
     * is supplied.
     * @return "ok" | "duplicate" | "error"
     */
    public String updateUser(int id, String username, String password,
                             String email, String fullName, String role) {
        return userDAO.updateUser(id, username, password, email, fullName, role);
    }

    /**
     * Deletes a user.  Admin accounts are protected.
     * @return "ok" | "protected" | "error"
     */
    public String deleteUser(int id) {
        return userDAO.deleteUser(id);
    }
}
