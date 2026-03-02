package com.example.oceanviewresort.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("ReservationService Validation Tests")
class ReservationServiceValidationTest {

    private ReservationService service;

    @BeforeEach
    void setUp() {
        service = new ReservationService();
    }

    @Test
    @DisplayName("addReservation rejects same-day check-in and check-out")
    void testSameDayCheckInOut() {
        String result = service.addReservation(
            "John Doe", "123 Main St", "0771234567",
            "Standard Room", "2026-03-01", "2026-03-01", 1, 0
        );
        assertEquals("error:Check-out must be after check-in.", result);
    }

    @Test
    @DisplayName("addReservation rejects check-out before check-in")
    void testCheckOutBeforeCheckIn() {
        String result = service.addReservation(
            "John Doe", "123 Main St", "0771234567",
            "Standard Room", "2026-03-05", "2026-03-01", 1, 0
        );
        assertEquals("error:Check-out must be after check-in.", result);
    }

    @Test
    @DisplayName("addReservation rejects invalid date format")
    void testInvalidDateFormat() {
        String result = service.addReservation(
            "John Doe", "123 Main St", "0771234567",
            "Standard Room", "01-03-2026", "05-03-2026", 1, 0
        );
        assertTrue(result.startsWith("error:"));
    }

    @Test
    @DisplayName("addReservation rejects null check-in date")
    void testNullCheckInDate() {
        String result = service.addReservation(
            "John Doe", "123 Main St", "0771234567",
            "Standard Room", null, "2026-03-05", 1, 0
        );
        assertTrue(result.startsWith("error:"));
    }

    @Test
    @DisplayName("addReservation rejects null check-out date")
    void testNullCheckOutDate() {
        String result = service.addReservation(
            "John Doe", "123 Main St", "0771234567",
            "Standard Room", "2026-03-01", null, 1, 0
        );
        assertTrue(result.startsWith("error:"));
    }
}
