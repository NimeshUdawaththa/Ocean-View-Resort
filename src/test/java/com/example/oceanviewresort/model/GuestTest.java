package com.example.oceanviewresort.model;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Guest Model Tests")
class GuestTest {

    private Guest guest;

    @BeforeEach
    void setUp() {
        guest = new Guest();
        guest.setId(1);
        guest.setFullName("John Doe");
        guest.setMobileNumber("0771234567");
        guest.setEmail("john@oceanview.com");
        guest.setAddress("123 Main St");
        guest.setNicNumber("991234567V");
        guest.setNotes("VIP guest");
        guest.setCreatedBy(2);
        guest.setCreatedAt("2026-03-01");
    }

    @Test
    @DisplayName("getId returns correct id")
    void testGetId() {
        assertEquals(1, guest.getId());
    }

    @Test
    @DisplayName("getFullName returns correct name")
    void testGetFullName() {
        assertEquals("John Doe", guest.getFullName());
    }

    @Test
    @DisplayName("getMobileNumber returns correct mobile")
    void testGetMobileNumber() {
        assertEquals("0771234567", guest.getMobileNumber());
    }

    @Test
    @DisplayName("getEmail returns correct email")
    void testGetEmail() {
        assertEquals("john@oceanview.com", guest.getEmail());
    }

    @Test
    @DisplayName("getNicNumber returns correct NIC")
    void testGetNicNumber() {
        assertEquals("991234567V", guest.getNicNumber());
    }

    @Test
    @DisplayName("getAddress returns correct address")
    void testGetAddress() {
        assertEquals("123 Main St", guest.getAddress());
    }

    @Test
    @DisplayName("getNotes returns correct notes")
    void testGetNotes() {
        assertEquals("VIP guest", guest.getNotes());
    }

    @Test
    @DisplayName("getCreatedBy returns correct creator id")
    void testGetCreatedBy() {
        assertEquals(2, guest.getCreatedBy());
    }

    @Test
    @DisplayName("Default constructor gives null fields")
    void testDefaultConstructor() {
        Guest g = new Guest();
        assertNull(g.getFullName());
        assertNull(g.getEmail());
        assertEquals(0, g.getId());
    }

    @Test
    @DisplayName("All-arg constructor sets all fields")
    void testAllArgConstructor() {
        Guest g = new Guest(5, "Jane", "0779876543", "jane@test.com",
                            "456 Road", "985678V", "notes", 1, "2026-01-01");
        assertEquals(5,              g.getId());
        assertEquals("Jane",          g.getFullName());
        assertEquals("0779876543",     g.getMobileNumber());
        assertEquals("jane@test.com",  g.getEmail());
    }
}
