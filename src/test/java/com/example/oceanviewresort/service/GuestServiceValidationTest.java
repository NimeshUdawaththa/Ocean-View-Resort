package com.example.oceanviewresort.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("GuestService Validation Tests")
class GuestServiceValidationTest {

    private GuestService service;

    @BeforeEach
    void setUp() {
        service = new GuestService();
    }

    // ── registerGuest validation ───────────────────────────────────────────────

    @Test
    @DisplayName("registerGuest rejects blank full name")
    void testRegisterBlankFullName() {
        String result = service.registerGuest("", "0771234567", null, "", "", "", 1);
        assertEquals("Full name is required.", result);
    }

    @Test
    @DisplayName("registerGuest rejects null full name")
    void testRegisterNullFullName() {
        String result = service.registerGuest(null, "0771234567", null, "", "", "", 1);
        assertEquals("Full name is required.", result);
    }

    @Test
    @DisplayName("registerGuest rejects whitespace-only full name")
    void testRegisterWhitespaceFullName() {
        String result = service.registerGuest("   ", "0771234567", null, "", "", "", 1);
        assertEquals("Full name is required.", result);
    }

    @Test
    @DisplayName("registerGuest rejects blank mobile number")
    void testRegisterBlankMobile() {
        String result = service.registerGuest("John Doe", "", null, "", "", "", 1);
        assertEquals("Mobile number is required.", result);
    }

    @Test
    @DisplayName("registerGuest rejects null mobile number")
    void testRegisterNullMobile() {
        String result = service.registerGuest("John Doe", null, null, "", "", "", 1);
        assertEquals("Mobile number is required.", result);
    }

    @Test
    @DisplayName("registerGuest rejects whitespace-only mobile number")
    void testRegisterWhitespaceMobile() {
        String result = service.registerGuest("John Doe", "   ", null, "", "", "", 1);
        assertEquals("Mobile number is required.", result);
    }

    // ── updateGuest validation ─────────────────────────────────────────────────

    @Test
    @DisplayName("updateGuest rejects blank full name")
    void testUpdateBlankFullName() {
        String result = service.updateGuest(1, "", "0771234567", null, "", "", "");
        assertEquals("Full name is required.", result);
    }

    @Test
    @DisplayName("updateGuest rejects null full name")
    void testUpdateNullFullName() {
        String result = service.updateGuest(1, null, "0771234567", null, "", "", "");
        assertEquals("Full name is required.", result);
    }

    @Test
    @DisplayName("updateGuest rejects blank mobile number")
    void testUpdateBlankMobile() {
        String result = service.updateGuest(1, "John Doe", "", null, "", "", "");
        assertEquals("Mobile number is required.", result);
    }

    @Test
    @DisplayName("updateGuest rejects null mobile number")
    void testUpdateNullMobile() {
        String result = service.updateGuest(1, "John Doe", null, null, "", "", "");
        assertEquals("Mobile number is required.", result);
    }
}
