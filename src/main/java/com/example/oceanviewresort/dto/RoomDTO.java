package com.example.oceanviewresort.dto;

/**
 * Data Transfer Object for room data sent to the API layer.
 * ratePerNight is stored as a plain String for direct JSON serialisation.
 */
public class RoomDTO {

    private int    id;
    private String roomNumber;
    private String roomType;
    private String description;
    private String ratePerNight;
    private String status;
    private int    floor;
    private String createdAt;

    public RoomDTO() {}

    public RoomDTO(int id, String roomNumber, String roomType, String description,
                   String ratePerNight, String status, int floor, String createdAt) {
        this.id           = id;
        this.roomNumber   = roomNumber;
        this.roomType     = roomType;
        this.description  = description;
        this.ratePerNight = ratePerNight;
        this.status       = status;
        this.floor        = floor;
        this.createdAt    = createdAt;
    }

    // ── Getters ───────────────────────────────────────────────────────────────
    public int    getId()           { return id; }
    public String getRoomNumber()   { return roomNumber; }
    public String getRoomType()     { return roomType; }
    public String getDescription()  { return description; }
    public String getRatePerNight() { return ratePerNight; }
    public String getStatus()       { return status; }
    public int    getFloor()        { return floor; }
    public String getCreatedAt()    { return createdAt; }

    // ── Setters ───────────────────────────────────────────────────────────────
    public void setId(int id)                       { this.id = id; }
    public void setRoomNumber(String roomNumber)     { this.roomNumber = roomNumber; }
    public void setRoomType(String roomType)         { this.roomType = roomType; }
    public void setDescription(String description)   { this.description = description; }
    public void setRatePerNight(String ratePerNight) { this.ratePerNight = ratePerNight; }
    public void setStatus(String status)             { this.status = status; }
    public void setFloor(int floor)                  { this.floor = floor; }
    public void setCreatedAt(String createdAt)       { this.createdAt = createdAt; }
}
