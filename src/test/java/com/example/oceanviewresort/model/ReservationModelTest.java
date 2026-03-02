package com.example.oceanviewresort.model;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Reservation Model Tests")
class ReservationModelTest {

    private Reservation reservation;

    @BeforeEach
    void setUp() {
        reservation = new Reservation();
        reservation.setId(1);
        reservation.setReservationNumber("RES-001");
        reservation.setGuestName("John Doe");
        reservation.setAddress("123 Main St");
        reservation.setContactNumber("0771234567");
        reservation.setRoomType("Standard Room");
        reservation.setRoomId(3);
        reservation.setCheckInDate(LocalDate.of(2026, 3, 1));
        reservation.setCheckOutDate(LocalDate.of(2026, 3, 5));
        reservation.setTotalAmount(new BigDecimal("22000.00"));
        reservation.setStatus("active");
        reservation.setCreatedBy(1);
        reservation.setCreatedByName("Admin");
    }

    @Test
    @DisplayName("getId returns correct id")
    void testGetId() {
        assertEquals(1, reservation.getId());
    }

    @Test
    @DisplayName("getReservationNumber returns correct number")
    void testGetReservationNumber() {
        assertEquals("RES-001", reservation.getReservationNumber());
    }

    @Test
    @DisplayName("getGuestName returns correct name")
    void testGetGuestName() {
        assertEquals("John Doe", reservation.getGuestName());
    }

    @Test
    @DisplayName("getStatus returns active")
    void testGetStatus() {
        assertEquals("active", reservation.getStatus());
    }

    @Test
    @DisplayName("getCheckInDate returns correct date")
    void testGetCheckInDate() {
        assertEquals(LocalDate.of(2026, 3, 1), reservation.getCheckInDate());
    }

    @Test
    @DisplayName("getCheckOutDate returns correct date")
    void testGetCheckOutDate() {
        assertEquals(LocalDate.of(2026, 3, 5), reservation.getCheckOutDate());
    }

    @Test
    @DisplayName("getTotalAmount returns correct amount")
    void testGetTotalAmount() {
        assertEquals(new BigDecimal("22000.00"), reservation.getTotalAmount());
    }

    @Test
    @DisplayName("getRateForRoom returns 80.00 for Standard Room")
    void testRateStandard() {
        assertEquals(80.00, Reservation.getRateForRoom(Reservation.ROOM_STANDARD));
    }

    @Test
    @DisplayName("getRateForRoom returns 130.00 for Deluxe Room")
    void testRateDeluxe() {
        assertEquals(130.00, Reservation.getRateForRoom(Reservation.ROOM_DELUXE));
    }

    @Test
    @DisplayName("getRateForRoom returns 220.00 for Suite")
    void testRateSuite() {
        assertEquals(220.00, Reservation.getRateForRoom(Reservation.ROOM_SUITE));
    }

    @Test
    @DisplayName("getRateForRoom returns 300.00 for Ocean View Suite")
    void testRateOceanView() {
        assertEquals(300.00, Reservation.getRateForRoom(Reservation.ROOM_OCEAN_VIEW));
    }

    @Test
    @DisplayName("getRateForRoom returns -1 for unknown room type")
    void testRateUnknown() {
        assertEquals(-1, Reservation.getRateForRoom("Unknown"));
    }

    @Test
    @DisplayName("TAX_RATE constant equals 0.10")
    void testTaxRate() {
        assertEquals(0.10, Reservation.TAX_RATE);
    }

    @Test
    @DisplayName("Default constructor gives null status")
    void testDefaultConstructor() {
        Reservation r = new Reservation();
        assertNull(r.getStatus());
        assertEquals(0, r.getId());
    }
}
