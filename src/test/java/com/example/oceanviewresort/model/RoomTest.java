package com.example.oceanviewresort.model;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Room Model Tests")
class RoomTest {

    private Room room;

    @BeforeEach
    void setUp() {
        room = new Room();
        room.setId(1);
        room.setRoomNumber("101");
        room.setRoomType("Standard");
        room.setDescription("Ocean view room");
        room.setRatePerNight(new BigDecimal("5000.00"));
        room.setStatus("available");
        room.setFloor(1);
        room.setCreatedAt("2026-03-01");
    }

    @Test
    @DisplayName("getId returns correct id")
    void testGetId() {
        assertEquals(1, room.getId());
    }

    @Test
    @DisplayName("getRoomNumber returns correct room number")
    void testGetRoomNumber() {
        assertEquals("101", room.getRoomNumber());
    }

    @Test
    @DisplayName("getRoomType returns correct type")
    void testGetRoomType() {
        assertEquals("Standard", room.getRoomType());
    }

    @Test
    @DisplayName("getRatePerNight returns correct rate")
    void testGetRatePerNight() {
        assertEquals(new BigDecimal("5000.00"), room.getRatePerNight());
    }

    @Test
    @DisplayName("getStatus returns correct status")
    void testGetStatus() {
        assertEquals("available", room.getStatus());
    }

    @Test
    @DisplayName("getFloor returns correct floor")
    void testGetFloor() {
        assertEquals(1, room.getFloor());
    }

    @Test
    @DisplayName("STATUS_AVAILABLE constant equals available")
    void testStatusAvailableConstant() {
        assertEquals("available", Room.STATUS_AVAILABLE);
    }

    @Test
    @DisplayName("STATUS_OCCUPIED constant equals occupied")
    void testStatusOccupiedConstant() {
        assertEquals("occupied", Room.STATUS_OCCUPIED);
    }

    @Test
    @DisplayName("STATUS_MAINTENANCE constant equals maintenance")
    void testStatusMaintenanceConstant() {
        assertEquals("maintenance", Room.STATUS_MAINTENANCE);
    }

    @Test
    @DisplayName("Status can be updated with setter")
    void testSetStatus() {
        room.setStatus("occupied");
        assertEquals("occupied", room.getStatus());
    }

    @Test
    @DisplayName("Default constructor gives null/zero fields")
    void testDefaultConstructor() {
        Room r = new Room();
        assertNull(r.getRoomNumber());
        assertNull(r.getStatus());
        assertEquals(0, r.getId());
    }
}
