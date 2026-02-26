package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.util.DBConnection;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

public class ReservationService {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    // ── Add Reservation ──────────────────────────────────────────────────────
    /**
     * @return generated reservation number on success, or "error:<message>"
     */
    public String addReservation(String guestName, String address, String contactNumber,
                                 String roomType, String checkIn, String checkOut,
                                 int createdBy) {
        try {
            LocalDate ciDate = LocalDate.parse(checkIn,  FMT);
            LocalDate coDate = LocalDate.parse(checkOut, FMT);

            if (!coDate.isAfter(ciDate)) return "error:Check-out must be after check-in.";

            double rate = Reservation.getRateForRoom(roomType);
            if (rate < 0) return "error:Invalid room type.";

            long   nights   = ChronoUnit.DAYS.between(ciDate, coDate);
            double subtotal = nights * rate;
            double tax      = subtotal * Reservation.TAX_RATE;
            double total    = subtotal + tax;

            String resNum = generateReservationNumber();

            String sql = "INSERT INTO reservations " +
                    "(reservation_number, guest_name, address, contact_number, room_type, " +
                    " check_in_date, check_out_date, total_amount, status, created_by) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'active', ?)";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, resNum);
                ps.setString(2, guestName);
                ps.setString(3, address);
                ps.setString(4, contactNumber);
                ps.setString(5, roomType);
                ps.setDate(6, Date.valueOf(ciDate));
                ps.setDate(7, Date.valueOf(coDate));
                ps.setBigDecimal(8, BigDecimal.valueOf(total).setScale(2, RoundingMode.HALF_UP));
                ps.setInt(9, createdBy);
                ps.executeUpdate();
            }
            return resNum;

        } catch (Exception e) {
            System.err.println("[ReservationService] addReservation error: " + e.getMessage());
            return "error:" + e.getMessage();
        }
    }

    // ── Get single reservation ───────────────────────────────────────────────
    public Reservation getReservation(String reservationNumber) {
        String sql = "SELECT r.*, u.full_name AS created_by_name " +
                     "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
                     "WHERE r.reservation_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reservationNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[ReservationService] getReservation error: " + e.getMessage());
        }
        return null;
    }

    // ── Get single reservation by id ─────────────────────────────────────────
    public Reservation getReservationById(int id) {
        String sql = "SELECT r.*, u.full_name AS created_by_name " +
                     "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
                     "WHERE r.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("[ReservationService] getReservationById error: " + e.getMessage());
        }
        return null;
    }

    // ── List all reservations (manager) ─────────────────────────────────────
    public List<Reservation> getAllReservations() {
        return listReservations(null);
    }

    // ── List reservations created by a specific user (reception) ─────────────
    public List<Reservation> getReservationsByUser(int userId) {
        return listReservations(userId);
    }

    // ── Calculate bill ────────────────────────────────────────────────────────
    /**
     * Returns a bill breakdown map as a JSON-friendly object.
     * Fields: nights, roomType, ratePerNight, subtotal, tax, total.
     */
    public BillResult calculateBill(int reservationId) {
        Reservation r = getReservationById(reservationId);
        if (r == null) return null;

        long   nights   = ChronoUnit.DAYS.between(r.getCheckInDate(), r.getCheckOutDate());
        double rate     = Reservation.getRateForRoom(r.getRoomType());
        double subtotal = nights * rate;
        double tax      = subtotal * Reservation.TAX_RATE;
        double total    = subtotal + tax;

        return new BillResult(r, nights, rate, subtotal, tax, total);
    }

    // ── Inner bill DTO ────────────────────────────────────────────────────────
    public static class BillResult {
        public final Reservation reservation;
        public final long   nights;
        public final double ratePerNight;
        public final double subtotal;
        public final double tax;
        public final double total;

        BillResult(Reservation r, long nights, double rate, double subtotal, double tax, double total) {
            this.reservation  = r;
            this.nights       = nights;
            this.ratePerNight = rate;
            this.subtotal     = subtotal;
            this.tax          = tax;
            this.total        = total;
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private List<Reservation> listReservations(Integer userId) {
        List<Reservation> list = new ArrayList<>();
        String sql;
        if (userId == null) {
            sql = "SELECT r.*, u.full_name AS created_by_name " +
                  "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
                  "ORDER BY r.created_at DESC";
        } else {
            sql = "SELECT r.*, u.full_name AS created_by_name " +
                  "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
                  "WHERE r.created_by = ? ORDER BY r.created_at DESC";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId != null) ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[ReservationService] listReservations error: " + e.getMessage());
        }
        return list;
    }

    private Reservation mapRow(ResultSet rs) throws SQLException {
        Date ci = rs.getDate("check_in_date");
        Date co = rs.getDate("check_out_date");
        return new Reservation(
            rs.getInt("id"),
            rs.getString("reservation_number"),
            rs.getString("guest_name"),
            rs.getString("address"),
            rs.getString("contact_number"),
            rs.getString("room_type"),
            ci != null ? ci.toLocalDate() : null,
            co != null ? co.toLocalDate() : null,
            rs.getBigDecimal("total_amount"),
            rs.getString("status"),
            rs.getInt("created_by"),
            rs.getString("created_by_name"),
            rs.getString("created_at")
        );
    }

    private String generateReservationNumber() {
        String datePart = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        int    rand     = ThreadLocalRandom.current().nextInt(1000, 9999);
        return "RES-" + datePart + "-" + rand;
    }
}
