package com.example.oceanviewresort.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Represents a guest reservation.
 */
public class Reservation {

    private int        id;
    private String     reservationNumber;
    private String     guestName;
    private String     address;
    private String     contactNumber;
    private String     roomType;
    private LocalDate  checkInDate;
    private LocalDate  checkOutDate;
    private BigDecimal totalAmount;
    private String     status;
    private int        createdBy;
    private String     createdByName;
    private String     createdAt;

    // Room rates (per night, in USD)
    public static final String ROOM_STANDARD        = "Standard Room";
    public static final String ROOM_DELUXE          = "Deluxe Room";
    public static final String ROOM_SUITE           = "Suite";
    public static final String ROOM_OCEAN_VIEW      = "Ocean View Suite";

    public static final double RATE_STANDARD        = 80.00;
    public static final double RATE_DELUXE          = 130.00;
    public static final double RATE_SUITE           = 220.00;
    public static final double RATE_OCEAN_VIEW      = 300.00;
    public static final double TAX_RATE             = 0.10;   // 10 %

    public Reservation() {}

    public Reservation(int id, String reservationNumber, String guestName, String address,
                       String contactNumber, String roomType,
                       LocalDate checkInDate, LocalDate checkOutDate,
                       BigDecimal totalAmount, String status,
                       int createdBy, String createdByName, String createdAt) {
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

    /** Returns the nightly rate for a given room type, or -1 if unknown. */
    public static double getRateForRoom(String roomType) {
        if (roomType == null) return -1;
        switch (roomType) {
            case ROOM_STANDARD:   return RATE_STANDARD;
            case ROOM_DELUXE:     return RATE_DELUXE;
            case ROOM_SUITE:      return RATE_SUITE;
            case ROOM_OCEAN_VIEW: return RATE_OCEAN_VIEW;
            default:              return -1;
        }
    }

    // ── Getters ───────────────────────────────────────────────
    public int        getId()                { return id; }
    public String     getReservationNumber() { return reservationNumber; }
    public String     getGuestName()         { return guestName; }
    public String     getAddress()           { return address; }
    public String     getContactNumber()     { return contactNumber; }
    public String     getRoomType()          { return roomType; }
    public LocalDate  getCheckInDate()       { return checkInDate; }
    public LocalDate  getCheckOutDate()      { return checkOutDate; }
    public BigDecimal getTotalAmount()       { return totalAmount; }
    public String     getStatus()            { return status; }
    public int        getCreatedBy()         { return createdBy; }
    public String     getCreatedByName()     { return createdByName; }
    public String     getCreatedAt()         { return createdAt; }

    // ── Setters ───────────────────────────────────────────────
    public void setId(int id)                               { this.id = id; }
    public void setReservationNumber(String n)              { this.reservationNumber = n; }
    public void setGuestName(String guestName)              { this.guestName = guestName; }
    public void setAddress(String address)                  { this.address = address; }
    public void setContactNumber(String contactNumber)      { this.contactNumber = contactNumber; }
    public void setRoomType(String roomType)                { this.roomType = roomType; }
    public void setCheckInDate(LocalDate checkInDate)       { this.checkInDate = checkInDate; }
    public void setCheckOutDate(LocalDate checkOutDate)     { this.checkOutDate = checkOutDate; }
    public void setTotalAmount(BigDecimal totalAmount)      { this.totalAmount = totalAmount; }
    public void setStatus(String status)                    { this.status = status; }
    public void setCreatedBy(int createdBy)                 { this.createdBy = createdBy; }
    public void setCreatedByName(String createdByName)      { this.createdByName = createdByName; }
    public void setCreatedAt(String createdAt)              { this.createdAt = createdAt; }
}
