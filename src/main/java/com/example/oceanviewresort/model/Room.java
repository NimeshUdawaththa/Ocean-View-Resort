package com.example.oceanviewresort.model;

import java.math.BigDecimal;

/**
 * Represents a physical hotel room.
 */
public class Room {

    private int        id;
    private String     roomNumber;
    private String     roomType;
    private String     description;
    private BigDecimal ratePerNight;
    private String     status;          // available | occupied | maintenance
    private int        floor;
    private String     createdAt;

    // Status constants
    public static final String STATUS_AVAILABLE    = "available";
    public static final String STATUS_OCCUPIED     = "occupied";
    public static final String STATUS_MAINTENANCE  = "maintenance";

    public Room() {}

    public Room(int id, String roomNumber, String roomType, String description,
                BigDecimal ratePerNight, String status, int floor, String createdAt) {
        this.id           = id;
        this.roomNumber   = roomNumber;
        this.roomType     = roomType;
        this.description  = description;
        this.ratePerNight = ratePerNight;
        this.status       = status;
        this.floor        = floor;
        this.createdAt    = createdAt;
    }

    // ── Getters ──────────────────────────────────────────────────
    public int        getId()           { return id; }
    public String     getRoomNumber()   { return roomNumber; }
    public String     getRoomType()     { return roomType; }
    public String     getDescription()  { return description; }
    public BigDecimal getRatePerNight() { return ratePerNight; }
    public String     getStatus()       { return status; }
    public int        getFloor()        { return floor; }
    public String     getCreatedAt()    { return createdAt; }

    // ── Setters ──────────────────────────────────────────────────
    public void setId(int id)                         { this.id = id; }
    public void setRoomNumber(String roomNumber)       { this.roomNumber = roomNumber; }
    public void setRoomType(String roomType)           { this.roomType = roomType; }
    public void setDescription(String description)     { this.description = description; }
    public void setRatePerNight(BigDecimal rate)       { this.ratePerNight = rate; }
    public void setStatus(String status)               { this.status = status; }
    public void setFloor(int floor)                   { this.floor = floor; }
    public void setCreatedAt(String createdAt)         { this.createdAt = createdAt; }
}
