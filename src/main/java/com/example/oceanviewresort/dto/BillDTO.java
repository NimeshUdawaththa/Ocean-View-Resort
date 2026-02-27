package com.example.oceanviewresort.dto;

/**
 * Data Transfer Object for guest bill / invoice data.
 * All monetary values are pre-formatted as strings ("12.00").
 * Replaces the previous inner class ReservationService.BillResult.
 */
public class BillDTO {

    private String reservationNumber;
    private String guestName;
    private String address;
    private String contactNumber;
    private String roomType;
    private String checkInDate;
    private String checkOutDate;
    private long   nights;
    private String ratePerNight;
    private String subtotal;
    private String taxRate;
    private String tax;
    private String total;
    private String status;

    public BillDTO() {}

    public BillDTO(String reservationNumber, String guestName, String address,
                   String contactNumber, String roomType,
                   String checkInDate, String checkOutDate,
                   long nights, String ratePerNight,
                   String subtotal, String taxRate, String tax, String total,
                   String status) {
        this.reservationNumber = reservationNumber;
        this.guestName         = guestName;
        this.address           = address;
        this.contactNumber     = contactNumber;
        this.roomType          = roomType;
        this.checkInDate       = checkInDate;
        this.checkOutDate      = checkOutDate;
        this.nights            = nights;
        this.ratePerNight      = ratePerNight;
        this.subtotal          = subtotal;
        this.taxRate           = taxRate;
        this.tax               = tax;
        this.total             = total;
        this.status            = status;
    }

    // ── Getters ───────────────────────────────────────────────────────────────
    public String getReservationNumber() { return reservationNumber; }
    public String getGuestName()         { return guestName; }
    public String getAddress()           { return address; }
    public String getContactNumber()     { return contactNumber; }
    public String getRoomType()          { return roomType; }
    public String getCheckInDate()       { return checkInDate; }
    public String getCheckOutDate()      { return checkOutDate; }
    public long   getNights()            { return nights; }
    public String getRatePerNight()      { return ratePerNight; }
    public String getSubtotal()          { return subtotal; }
    public String getTaxRate()           { return taxRate; }
    public String getTax()               { return tax; }
    public String getTotal()             { return total; }
    public String getStatus()            { return status; }

    // ── Setters ───────────────────────────────────────────────────────────────
    public void setReservationNumber(String reservationNumber) { this.reservationNumber = reservationNumber; }
    public void setGuestName(String guestName)                 { this.guestName = guestName; }
    public void setAddress(String address)                     { this.address = address; }
    public void setContactNumber(String contactNumber)         { this.contactNumber = contactNumber; }
    public void setRoomType(String roomType)                   { this.roomType = roomType; }
    public void setCheckInDate(String checkInDate)             { this.checkInDate = checkInDate; }
    public void setCheckOutDate(String checkOutDate)           { this.checkOutDate = checkOutDate; }
    public void setNights(long nights)                         { this.nights = nights; }
    public void setRatePerNight(String ratePerNight)           { this.ratePerNight = ratePerNight; }
    public void setSubtotal(String subtotal)                   { this.subtotal = subtotal; }
    public void setTaxRate(String taxRate)                     { this.taxRate = taxRate; }
    public void setTax(String tax)                             { this.tax = tax; }
    public void setTotal(String total)                         { this.total = total; }
    public void setStatus(String status)                       { this.status = status; }
}
