package com.example.oceanviewresort.dto;

/**
 * Data Transfer Object for reservation data sent to the API layer.
 * Dates are pre-formatted as Strings for direct JSON serialisation.
 */
public class ReservationDTO {

    private int    id;
    private String reservationNumber;
    private String guestName;
    private String address;
    private String contactNumber;
    private String roomType;
    private String checkInDate;
    private String checkOutDate;
    private String totalAmount;
    private String status;
    private int    createdBy;
    private String createdByName;
    private String createdAt;

    public ReservationDTO() {}

    public ReservationDTO(int id, String reservationNumber, String guestName,
                          String address, String contactNumber, String roomType,
                          String checkInDate, String checkOutDate, String totalAmount,
                          String status, int createdBy, String createdByName, String createdAt) {
        this.id                = id;
        this.reservationNumber = reservationNumber;
        this.guestName         = guestName;
        this.address           = address;
        this.contactNumber     = contactNumber;
        this.roomType          = roomType;
        this.checkInDate       = checkInDate;
        this.checkOutDate      = checkOutDate;
        this.totalAmount       = totalAmount;
        this.status            = status;
        this.createdBy         = createdBy;
        this.createdByName     = createdByName;
        this.createdAt         = createdAt;
    }

    // ── Getters ───────────────────────────────────────────────────────────────
    public int    getId()                { return id; }
    public String getReservationNumber() { return reservationNumber; }
    public String getGuestName()         { return guestName; }
    public String getAddress()           { return address; }
    public String getContactNumber()     { return contactNumber; }
    public String getRoomType()          { return roomType; }
    public String getCheckInDate()       { return checkInDate; }
    public String getCheckOutDate()      { return checkOutDate; }
    public String getTotalAmount()       { return totalAmount; }
    public String getStatus()            { return status; }
    public int    getCreatedBy()         { return createdBy; }
    public String getCreatedByName()     { return createdByName; }
    public String getCreatedAt()         { return createdAt; }

    // ── Setters ───────────────────────────────────────────────────────────────
    public void setId(int id)                            { this.id = id; }
    public void setReservationNumber(String n)           { this.reservationNumber = n; }
    public void setGuestName(String guestName)           { this.guestName = guestName; }
    public void setAddress(String address)               { this.address = address; }
    public void setContactNumber(String c)               { this.contactNumber = c; }
    public void setRoomType(String roomType)             { this.roomType = roomType; }
    public void setCheckInDate(String checkInDate)       { this.checkInDate = checkInDate; }
    public void setCheckOutDate(String checkOutDate)     { this.checkOutDate = checkOutDate; }
    public void setTotalAmount(String totalAmount)       { this.totalAmount = totalAmount; }
    public void setStatus(String status)                 { this.status = status; }
    public void setCreatedBy(int createdBy)              { this.createdBy = createdBy; }
    public void setCreatedByName(String createdByName)   { this.createdByName = createdByName; }
    public void setCreatedAt(String createdAt)           { this.createdAt = createdAt; }
}
