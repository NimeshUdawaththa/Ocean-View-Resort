package com.example.oceanviewresort.service;

import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.dto.RoomDTO;
import com.example.oceanviewresort.model.Room;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service layer for room management business logic.
 * Delegates all DB access to {@link RoomDAO} and returns
 * {@link RoomDTO} objects to the controller layer.
 */
public class RoomService {

    private final RoomDAO roomDAO = new RoomDAO();

    // ── Add Room ──────────────────────────────────────────────────────────────
    /**
     * @return null on success, or an error message string on failure.
     */
    public String addRoom(String roomNumber, String roomType, String description,
                          double ratePerNight, String status, int floor) {
        if (roomNumber  == null || roomNumber.isBlank()) return "Room number is required.";
        if (roomType    == null || roomType.isBlank())   return "Room type is required.";
        if (ratePerNight <= 0)                           return "Rate must be greater than 0.";

        return roomDAO.insert(
            roomNumber.trim(),
            roomType.trim(),
            description != null ? description.trim() : "",
            BigDecimal.valueOf(ratePerNight),
            status != null ? status : Room.STATUS_AVAILABLE,
            floor  > 0    ? floor   : 1
        );
    }

    // ── Update Room ───────────────────────────────────────────────────────────
    public String updateRoom(int id, String roomNumber, String roomType, String description,
                             double ratePerNight, String status, int floor) {
        if (roomNumber  == null || roomNumber.isBlank()) return "Room number is required.";
        if (ratePerNight <= 0)                           return "Rate must be greater than 0.";

        return roomDAO.update(
            id,
            roomNumber.trim(),
            roomType != null ? roomType.trim() : "",
            description != null ? description.trim() : "",
            BigDecimal.valueOf(ratePerNight),
            status,
            floor > 0 ? floor : 1
        );
    }

    // ── Delete Room ───────────────────────────────────────────────────────────
    public String deleteRoom(int id) {
        return roomDAO.delete(id);
    }

    // ── Queries (return DTOs) ─────────────────────────────────────────────────
    public RoomDTO getRoomById(int id) {
        Room r = roomDAO.findById(id);
        return r != null ? toDTO(r) : null;
    }

    public List<RoomDTO> getAllRooms() {
        return roomDAO.findAll().stream().map(this::toDTO).collect(Collectors.toList());
    }

    public List<RoomDTO> getRoomsByStatus(String status) {
        return roomDAO.findByStatus(status).stream().map(this::toDTO).collect(Collectors.toList());
    }

    // ── Mapper: Room entity → RoomDTO ─────────────────────────────────────────
    private RoomDTO toDTO(Room r) {
        return new RoomDTO(
            r.getId(),
            r.getRoomNumber(),
            r.getRoomType(),
            r.getDescription()  != null ? r.getDescription()                : "",
            r.getRatePerNight() != null ? r.getRatePerNight().toPlainString() : "0",
            r.getStatus(),
            r.getFloor(),
            r.getCreatedAt()    != null ? r.getCreatedAt()                  : ""
        );
    }
}
