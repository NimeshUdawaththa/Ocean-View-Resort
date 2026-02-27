package com.example.oceanviewresort.service;

import com.example.oceanviewresort.dao.GuestDAO;
import com.example.oceanviewresort.dto.GuestDTO;
import com.example.oceanviewresort.model.Guest;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service layer for guest registration business logic.
 * Delegates all DB access to {@link GuestDAO} and returns
 * {@link GuestDTO} objects to the controller layer.
 * Guests are uniquely identified by mobile number and email.
 */
public class GuestService {

    private final GuestDAO guestDAO = new GuestDAO();

    // ── Register guest ────────────────────────────────────────────────────────
    /**
     * @return null on success, or a user-facing error message string.
     */
    public String registerGuest(String fullName, String mobileNumber, String email,
                                String address, String nicNumber, String notes, int createdBy) {
        // Basic validation
        if (fullName     == null || fullName.isBlank())     return "Full name is required.";
        if (mobileNumber == null || mobileNumber.isBlank()) return "Mobile number is required.";

        String result = guestDAO.insert(
            fullName.trim(),
            mobileNumber.trim(),
            email    != null ? email.trim()    : null,
            address  != null ? address.trim()  : "",
            nicNumber!= null ? nicNumber.trim(): "",
            notes    != null ? notes.trim()    : "",
            createdBy
        );

        if (result == null)                   return null; // success
        if ("duplicate_mobile".equals(result)) return "A guest with mobile number \"" + mobileNumber.trim() + "\" is already registered.";
        if ("duplicate_email".equals(result))  return "A guest with email \"" + email.trim() + "\" is already registered.";
        return "Database error: " + result.replace("error:", "");
    }

    // ── Lookup by mobile (for quick search / reservation auto-fill) ───────────
    public GuestDTO findByMobile(String mobileNumber) {
        Guest g = guestDAO.findByMobile(mobileNumber);
        return g != null ? toDTO(g) : null;
    }

    // ── Lookup by email ───────────────────────────────────────────────────────
    public GuestDTO findByEmail(String email) {
        Guest g = guestDAO.findByEmail(email);
        return g != null ? toDTO(g) : null;
    }

    // ── Lookup by id ──────────────────────────────────────────────────────────
    public GuestDTO findById(int id) {
        Guest g = guestDAO.findById(id);
        return g != null ? toDTO(g) : null;
    }

    // ── List all guests ───────────────────────────────────────────────────────
    public List<GuestDTO> getAllGuests() {
        return guestDAO.findAll().stream().map(this::toDTO).collect(Collectors.toList());
    }

    // ── Search guests ─────────────────────────────────────────────────────────
    public List<GuestDTO> searchGuests(String keyword) {
        return guestDAO.search(keyword).stream().map(this::toDTO).collect(Collectors.toList());
    }
    // ── Update guest ───────────────────────────────────────────────────────
    /** @return null on success, or user-facing error message. */
    public String updateGuest(int id, String fullName, String mobileNumber, String email,
                              String address, String nicNumber, String notes) {
        if (fullName     == null || fullName.isBlank())     return "Full name is required.";
        if (mobileNumber == null || mobileNumber.isBlank()) return "Mobile number is required.";

        String result = guestDAO.update(
            id,
            fullName.trim(),
            mobileNumber.trim(),
            email     != null ? email.trim()     : null,
            address   != null ? address.trim()   : "",
            nicNumber != null ? nicNumber.trim() : "",
            notes     != null ? notes.trim()     : ""
        );

        if (result == null)                    return null;
        if ("duplicate_mobile".equals(result)) return "A guest with mobile number \"" + mobileNumber.trim() + "\" is already registered.";
        if ("duplicate_email".equals(result))  return "A guest with email \"" + email.trim() + "\" is already registered.";
        return "Database error: " + result.replace("error:", "");
    }

    // ── Delete guest ────────────────────────────────────────────────────────
    public boolean deleteGuest(int id) {
        return guestDAO.delete(id);
    }
    // ── Mapper ────────────────────────────────────────────────────────────────
    private GuestDTO toDTO(Guest g) {
        return new GuestDTO(
            g.getId(),
            g.getFullName(),
            g.getMobileNumber(),
            g.getEmail()     != null ? g.getEmail()     : "",
            g.getAddress()   != null ? g.getAddress()   : "",
            g.getNicNumber() != null ? g.getNicNumber() : "",
            g.getNotes()     != null ? g.getNotes()     : "",
            g.getCreatedBy(),
            g.getCreatedAt() != null ? g.getCreatedAt() : ""
        );
    }
}
