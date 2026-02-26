package com.example.oceanviewresort.model;

/**
 * Represents a user record from the `users` table.
 */
public class User {

    private int    id;
    private String username;
    private String password;
    private String role;
    private String email;
    private String fullName;

    public User() {}

    public User(int id, String username, String password, String role, String email, String fullName) {
        this.id       = id;
        this.username = username;
        this.password = password;
        this.role     = role;
        this.email    = email;
        this.fullName = fullName;
    }

    // ── Getters ──────────────────────────────────────────────

    public int    getId()       { return id;       }
    public String getUsername() { return username; }
    public String getPassword() { return password; }
    public String getRole()     { return role;     }
    public String getEmail()    { return email;    }
    public String getFullName() { return fullName; }

    // ── Setters ──────────────────────────────────────────────

    public void setId(int id)             { this.id       = id;       }
    public void setUsername(String u)     { this.username = u;        }
    public void setPassword(String p)     { this.password = p;        }
    public void setRole(String role)      { this.role     = role;     }
    public void setEmail(String email)    { this.email    = email;    }
    public void setFullName(String name)  { this.fullName = name;     }
}
