package com.example.oceanviewresort.dto;

/**
 * Data Transfer Object for guest data sent to the API / UI layer.
 */
public class GuestDTO {

    private int    id;
    private String fullName;
    private String mobileNumber;
    private String email;
    private String address;
    private String nicNumber;
    private String notes;
    private int    createdBy;
    private String createdAt;

    public GuestDTO() {}

    public GuestDTO(int id, String fullName, String mobileNumber, String email,
                    String address, String nicNumber, String notes,
                    int createdBy, String createdAt) {
        this.id           = id;
        this.fullName     = fullName;
        this.mobileNumber = mobileNumber;
        this.email        = email;
        this.address      = address;
        this.nicNumber    = nicNumber;
        this.notes        = notes;
        this.createdBy    = createdBy;
        this.createdAt    = createdAt;
    }

    // ── Getters ───────────────────────────────────────────────────────────────
    public int    getId()           { return id; }
    public String getFullName()     { return fullName; }
    public String getMobileNumber() { return mobileNumber; }
    public String getEmail()        { return email; }
    public String getAddress()      { return address; }
    public String getNicNumber()    { return nicNumber; }
    public String getNotes()        { return notes; }
    public int    getCreatedBy()    { return createdBy; }
    public String getCreatedAt()    { return createdAt; }

    // ── Setters ───────────────────────────────────────────────────────────────
    public void setId(int id)                   { this.id = id; }
    public void setFullName(String fullName)     { this.fullName = fullName; }
    public void setMobileNumber(String mobile)   { this.mobileNumber = mobile; }
    public void setEmail(String email)           { this.email = email; }
    public void setAddress(String address)       { this.address = address; }
    public void setNicNumber(String nicNumber)   { this.nicNumber = nicNumber; }
    public void setNotes(String notes)           { this.notes = notes; }
    public void setCreatedBy(int createdBy)      { this.createdBy = createdBy; }
    public void setCreatedAt(String createdAt)   { this.createdAt = createdAt; }
}
