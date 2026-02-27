package com.example.oceanviewresort.dto;

/**
 * Data Transfer Object for user data sent to the API layer.
 * Does NOT include the password field.
 */
public class UserDTO {

    private int    id;
    private String username;
    private String fullName;
    private String email;
    private String role;

    public UserDTO() {}

    public UserDTO(int id, String username, String fullName, String email, String role) {
        this.id       = id;
        this.username = username;
        this.fullName = fullName;
        this.email    = email;
        this.role     = role;
    }

    // ── Getters ───────────────────────────────────────────────────────────────
    public int    getId()       { return id; }
    public String getUsername() { return username; }
    public String getFullName() { return fullName; }
    public String getEmail()    { return email; }
    public String getRole()     { return role; }

    // ── Setters ───────────────────────────────────────────────────────────────
    public void setId(int id)            { this.id = id; }
    public void setUsername(String u)    { this.username = u; }
    public void setFullName(String name) { this.fullName = name; }
    public void setEmail(String email)   { this.email = email; }
    public void setRole(String role)     { this.role = role; }
}
