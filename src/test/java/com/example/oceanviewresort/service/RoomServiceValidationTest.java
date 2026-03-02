package com.example.oceanviewresort.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("RoomService Validation Tests")
class RoomServiceValidationTest {

    private RoomService service;

    @BeforeEach
    void setUp() {
        service = new RoomService();
    }

    // ── addRoom validation ────────────────────────────────────────────────────

    @Test
    @DisplayName("addRoom rejects blank room number")
    void testAddBlankRoomNumber() {
        String result = service.addRoom("", "Standard Room", "", 100.0, "available", 1);
        assertEquals("Room number is required.", result);
    }

    @Test
    @DisplayName("addRoom rejects null room number")
    void testAddNullRoomNumber() {
        String result = service.addRoom(null, "Standard Room", "", 100.0, "available", 1);
        assertEquals("Room number is required.", result);
    }

    @Test
    @DisplayName("addRoom rejects blank room type")
    void testAddBlankRoomType() {
        String result = service.addRoom("101", "", "", 100.0, "available", 1);
        assertEquals("Room type is required.", result);
    }

    @Test
    @DisplayName("addRoom rejects null room type")
    void testAddNullRoomType() {
        String result = service.addRoom("101", null, "", 100.0, "available", 1);
        assertEquals("Room type is required.", result);
    }

    @Test
    @DisplayName("addRoom rejects zero rate per night")
    void testAddZeroRate() {
        String result = service.addRoom("101", "Standard Room", "", 0.0, "available", 1);
        assertEquals("Rate must be greater than 0.", result);
    }

    @Test
    @DisplayName("addRoom rejects negative rate per night")
    void testAddNegativeRate() {
        String result = service.addRoom("101", "Standard Room", "", -50.0, "available", 1);
        assertEquals("Rate must be greater than 0.", result);
    }

    // ── updateRoom validation ─────────────────────────────────────────────────

    @Test
    @DisplayName("updateRoom rejects blank room number")
    void testUpdateBlankRoomNumber() {
        String result = service.updateRoom(1, "", "Standard Room", "", 100.0, "available", 1);
        assertEquals("Room number is required.", result);
    }

    @Test
    @DisplayName("updateRoom rejects null room number")
    void testUpdateNullRoomNumber() {
        String result = service.updateRoom(1, null, "Standard Room", "", 100.0, "available", 1);
        assertEquals("Room number is required.", result);
    }

    @Test
    @DisplayName("updateRoom rejects zero rate per night")
    void testUpdateZeroRate() {
        String result = service.updateRoom(1, "101", "Standard Room", "", 0.0, "available", 1);
        assertEquals("Rate must be greater than 0.", result);
    }

    @Test
    @DisplayName("updateRoom rejects negative rate per night")
    void testUpdateNegativeRate() {
        String result = service.updateRoom(1, "101", "Standard Room", "", -1.0, "available", 1);
        assertEquals("Rate must be greater than 0.", result);
    }
}
