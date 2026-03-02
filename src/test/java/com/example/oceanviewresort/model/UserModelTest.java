package com.example.oceanviewresort.model;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("User Model Tests")
class UserModelTest {

    private User user;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setId(1);
        user.setUsername("admin01");
        user.setPassword("secret");
        user.setRole("admin");
        user.setEmail("admin@resort.com");
        user.setFullName("Admin User");
    }

    @Test
    @DisplayName("getId returns correct id")
    void testGetId() {
        assertEquals(1, user.getId());
    }

    @Test
    @DisplayName("getUsername returns correct username")
    void testGetUsername() {
        assertEquals("admin01", user.getUsername());
    }

    @Test
    @DisplayName("getPassword returns correct password")
    void testGetPassword() {
        assertEquals("secret", user.getPassword());
    }

    @Test
    @DisplayName("getRole returns correct role")
    void testGetRole() {
        assertEquals("admin", user.getRole());
    }

    @Test
    @DisplayName("getEmail returns correct email")
    void testGetEmail() {
        assertEquals("admin@resort.com", user.getEmail());
    }

    @Test
    @DisplayName("getFullName returns correct full name")
    void testGetFullName() {
        assertEquals("Admin User", user.getFullName());
    }

    @Test
    @DisplayName("ROLE_ADMIN constant equals admin")
    void testRoleAdminConstant() {
        assertEquals("admin", User.ROLE_ADMIN);
    }

    @Test
    @DisplayName("ROLE_MANAGER constant equals manager")
    void testRoleManagerConstant() {
        assertEquals("manager", User.ROLE_MANAGER);
    }

    @Test
    @DisplayName("ROLE_RECEPTION constant equals reception")
    void testRoleReceptionConstant() {
        assertEquals("reception", User.ROLE_RECEPTION);
    }

    @Test
    @DisplayName("Default constructor gives null username")
    void testDefaultConstructor() {
        User u = new User();
        assertNull(u.getUsername());
        assertEquals(0, u.getId());
    }
}
