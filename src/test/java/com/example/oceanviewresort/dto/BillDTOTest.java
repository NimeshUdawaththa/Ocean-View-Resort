package com.example.oceanviewresort.dto;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("BillDTO Tests")
class BillDTOTest {

    private BillDTO bill;

    @BeforeEach
    void setUp() {
        bill = new BillDTO(
            "RES-001",
            "John Doe",
            "123 Main St",
            "0771234567",
            "Standard Room",
            "2026-03-01",
            "2026-03-05",
            4L,
            "80.00",
            "320.00",
            "10%",
            "32.00",
            "352.00",
            "active"
        );
    }

    @Test
    @DisplayName("getReservationNumber returns correct value")
    void testGetReservationNumber() {
        assertEquals("RES-001", bill.getReservationNumber());
    }

    @Test
    @DisplayName("getGuestName returns correct value")
    void testGetGuestName() {
        assertEquals("John Doe", bill.getGuestName());
    }

    @Test
    @DisplayName("getRoomType returns correct value")
    void testGetRoomType() {
        assertEquals("Standard Room", bill.getRoomType());
    }

    @Test
    @DisplayName("getNights returns correct night count")
    void testGetNights() {
        assertEquals(4L, bill.getNights());
    }

    @Test
    @DisplayName("getRatePerNight returns correct rate string")
    void testGetRatePerNight() {
        assertEquals("80.00", bill.getRatePerNight());
    }

    @Test
    @DisplayName("getSubtotal returns correct subtotal string")
    void testGetSubtotal() {
        assertEquals("320.00", bill.getSubtotal());
    }

    @Test
    @DisplayName("getTaxRate returns tax rate string")
    void testGetTaxRate() {
        assertEquals("10%", bill.getTaxRate());
    }

    @Test
    @DisplayName("getTax returns correct tax string")
    void testGetTax() {
        assertEquals("32.00", bill.getTax());
    }

    @Test
    @DisplayName("getTotal returns correct total string")
    void testGetTotal() {
        assertEquals("352.00", bill.getTotal());
    }

    @Test
    @DisplayName("subtotal and tax strings are not null")
    void testSubtotalAndTaxNotNull() {
        assertNotNull(bill.getSubtotal());
        assertNotNull(bill.getTax());
    }

    @Test
    @DisplayName("getStatus returns active")
    void testGetStatus() {
        assertEquals("active", bill.getStatus());
    }

    @Test
    @DisplayName("guestEmail is null by default")
    void testGuestEmailDefaultNull() {
        assertNull(bill.getGuestEmail());
    }

    @Test
    @DisplayName("setGuestEmail stores email correctly")
    void testSetGuestEmail() {
        bill.setGuestEmail("john@example.com");
        assertEquals("john@example.com", bill.getGuestEmail());
    }
}
