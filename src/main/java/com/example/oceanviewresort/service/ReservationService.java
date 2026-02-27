package com.example.oceanviewresort.service;

import com.example.oceanviewresort.dao.ReservationDAO;
import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.dto.BillDTO;
import com.example.oceanviewresort.dto.ReservationDTO;
import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.model.Room;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

/**
 * Service layer for reservation business logic.
 * Delegates all DB access to {@link ReservationDAO} and returns
 * {@link ReservationDTO} / {@link BillDTO} objects to the controller layer.
 */
public class ReservationService {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private final ReservationDAO reservationDAO = new ReservationDAO();
    private final RoomDAO         roomDAO        = new RoomDAO();

    // ── Add Reservation ───────────────────────────────────────────────────────
    /**
     * Validates business rules, calculates the total, persists the reservation.
     * @return generated reservation number on success, or "error:<message>"
     */
    public String addReservation(String guestName, String address,
                                 String contactNumber, String roomType,
                                 String checkIn, String checkOut, int createdBy, int roomId) {
        try {
            LocalDate ciDate = LocalDate.parse(checkIn,  FMT);
            LocalDate coDate = LocalDate.parse(checkOut, FMT);

            if (!coDate.isAfter(ciDate))
                return "error:Check-out must be after check-in.";

            // Use the room's actual rate; fall back to hardcoded constant if room not found
            Room room = roomId > 0 ? roomDAO.findById(roomId) : null;
            double rate = (room != null)
                ? room.getRatePerNight().doubleValue()
                : Reservation.getRateForRoom(roomType);
            if (rate < 0)
                return "error:Invalid room type.";

            long   nights   = ChronoUnit.DAYS.between(ciDate, coDate);
            double subtotal = nights * rate;
            double tax      = subtotal * Reservation.TAX_RATE;
            double total    = subtotal + tax;

            String resNum = generateReservationNumber();

            boolean ok = reservationDAO.insert(
                resNum, guestName, address, contactNumber, roomType, roomId,
                ciDate, coDate,
                BigDecimal.valueOf(total).setScale(2, RoundingMode.HALF_UP),
                createdBy
            );

            return ok ? resNum : "error:Database error while saving reservation.";

        } catch (Exception e) {
            System.err.println("[ReservationService] addReservation error: " + e.getMessage());
            return "error:" + e.getMessage();
        }
    }

    // ── Queries (return DTOs) ─────────────────────────────────────────────────

    public ReservationDTO getReservation(String reservationNumber) {
        Reservation r = reservationDAO.findByNumber(reservationNumber);
        return r != null ? toDTO(r) : null;
    }

    public ReservationDTO getReservationById(int id) {
        Reservation r = reservationDAO.findById(id);
        return r != null ? toDTO(r) : null;
    }

    public List<ReservationDTO> getAllReservations() {
        return reservationDAO.findAll().stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }

    public List<ReservationDTO> getReservationsByUser(int userId) {
        return reservationDAO.findByUser(userId).stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }

    public List<ReservationDTO> getByContactNumber(String contactNumber) {
        return reservationDAO.findByContactNumber(contactNumber).stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }

    // ── Update Reservation ────────────────────────────────────────────────────
    /**
     * Updates dates, address and room type (recalculates total) for an active reservation.
     * @return null on success, or "error:<message>"
     */
    public String updateReservation(int id, String checkIn, String checkOut, String address, String roomType, int roomId) {
        try {
            Reservation existing = reservationDAO.findById(id);
            if (existing == null) return "error:Reservation not found.";
            if (!"active".equals(existing.getStatus()))
                return "error:Only active reservations can be edited.";

            LocalDate ciDate = LocalDate.parse(checkIn,  FMT);
            LocalDate coDate = LocalDate.parse(checkOut, FMT);
            if (!coDate.isAfter(ciDate))
                return "error:Check-out must be after check-in.";

            String effectiveType   = (roomType != null && !roomType.isEmpty())
                ? roomType : existing.getRoomType();
            int    effectiveRoomId = roomId > 0 ? roomId : existing.getRoomId();

            // Use the room's actual rate; fall back to hardcoded constant
            Room room = effectiveRoomId > 0 ? roomDAO.findById(effectiveRoomId) : null;
            double rate = (room != null)
                ? room.getRatePerNight().doubleValue()
                : Reservation.getRateForRoom(effectiveType);
            if (rate < 0) return "error:Invalid room type.";

            long   nights   = ChronoUnit.DAYS.between(ciDate, coDate);
            double subtotal = nights * rate;
            double tax      = subtotal * Reservation.TAX_RATE;
            double total    = subtotal + tax;

            boolean ok = reservationDAO.update(
                id, ciDate, coDate,
                BigDecimal.valueOf(total).setScale(2, RoundingMode.HALF_UP),
                address != null ? address : "",
                effectiveType, effectiveRoomId);
            return ok ? null : "error:Update failed.";
        } catch (Exception e) {
            System.err.println("[ReservationService] updateReservation error: " + e.getMessage());
            return "error:" + e.getMessage();
        }
    }

    // ── Cancel Reservation ────────────────────────────────────────────────────
    public boolean cancelReservation(int id) {
        return reservationDAO.cancel(id);
    }

    // ── Bill calculation (returns BillDTO) ────────────────────────────────────
    public BillDTO calculateBill(int reservationId) {
        Reservation r = reservationDAO.findById(reservationId);
        if (r == null) return null;

        long   nights   = ChronoUnit.DAYS.between(r.getCheckInDate(), r.getCheckOutDate());
        Room   room     = r.getRoomId() > 0 ? roomDAO.findById(r.getRoomId()) : null;
        double rate     = (room != null)
            ? room.getRatePerNight().doubleValue()
            : Reservation.getRateForRoom(r.getRoomType());
        double subtotal = nights * rate;
        double tax      = subtotal * Reservation.TAX_RATE;
        double total    = subtotal + tax;

        return new BillDTO(
            r.getReservationNumber(),
            r.getGuestName(),
            r.getAddress()      != null ? r.getAddress()               : "",
            r.getContactNumber(),
            r.getRoomType(),
            r.getCheckInDate()  != null ? r.getCheckInDate().toString()  : "",
            r.getCheckOutDate() != null ? r.getCheckOutDate().toString() : "",
            nights,
            String.format("%.2f", rate),
            String.format("%.2f", subtotal),
            String.format("%.0f%%", Reservation.TAX_RATE * 100),
            String.format("%.2f", tax),
            String.format("%.2f", total),
            r.getStatus()
        );
    }

    // ── Mapper: Reservation entity → ReservationDTO ───────────────────────────
    private ReservationDTO toDTO(Reservation r) {
        return new ReservationDTO(
            r.getId(),
            r.getReservationNumber(),
            r.getGuestName(),
            r.getAddress()       != null ? r.getAddress()                  : "",
            r.getContactNumber(),
            r.getRoomType(),
            r.getRoomId(),
            r.getCheckInDate()   != null ? r.getCheckInDate().toString()   : "",
            r.getCheckOutDate()  != null ? r.getCheckOutDate().toString()  : "",
            r.getTotalAmount()   != null ? r.getTotalAmount().toPlainString() : "0.00",
            r.getStatus(),
            r.getCreatedBy(),
            r.getCreatedByName() != null ? r.getCreatedByName()            : "",
            r.getCreatedAt()     != null ? r.getCreatedAt()                : ""
        );
    }

    // ── Reservation number generator ──────────────────────────────────────────
    private String generateReservationNumber() {
        String datePart = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        int    rand     = ThreadLocalRandom.current().nextInt(1000, 9999);
        return "RES-" + datePart + "-" + rand;
    }
}
