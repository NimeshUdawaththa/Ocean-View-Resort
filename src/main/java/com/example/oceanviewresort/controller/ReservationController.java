package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.ReservationService;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Reservation API  –  accessible to admin, manager and reception roles.
 *
 * GET  /api/reservations                    → list (manager/admin=all, reception=own)
 * GET  /api/reservations?id=X              → single reservation details
 * GET  /api/reservations?action=bill&id=X  → bill breakdown
 * POST /api/reservations  action=add       → create reservation
 */
@WebServlet(name = "reservationController", value = "/api/reservations")
public class ReservationController extends HttpServlet {

    private final ReservationService svc = new ReservationService();

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (!authenticated(session)) { unauthorized(resp, out); return; }

        String role   = (String) session.getAttribute("role");
        int    userId = ((User) session.getAttribute("loggedInUser")).getId();

        String action = nullToEmpty(req.getParameter("action"));
        String idParam = nullToEmpty(req.getParameter("id"));

        // ── bill ─────────────────────────────────────────────
        if ("bill".equals(action)) {
            int id = parseId(idParam);
            if (id <= 0) { badRequest(resp, out, "Valid reservation id required."); return; }

            ReservationService.BillResult bill = svc.calculateBill(id);
            if (bill == null) { notFound(resp, out, "Reservation not found."); return; }

            JsonObject json = new JsonObject();
            json.addProperty("success", true);
            json.add("bill", buildBillJson(bill));
            out.print(json);
            return;
        }

        // ── single reservation ────────────────────────────────
        if (!idParam.isEmpty()) {
            int id = parseId(idParam);
            if (id <= 0) { badRequest(resp, out, "Valid id required."); return; }
            Reservation r = svc.getReservationById(id);
            if (r == null) { notFound(resp, out, "Reservation not found."); return; }
            JsonObject json = new JsonObject();
            json.addProperty("success", true);
            json.add("reservation", buildResJson(r));
            out.print(json);
            return;
        }

        // ── list ─────────────────────────────────────────────
        List<Reservation> list;
        if (User.ROLE_ADMIN.equals(role) || User.ROLE_MANAGER.equals(role)) {
            list = svc.getAllReservations();
        } else {
            list = svc.getReservationsByUser(userId);
        }

        JsonArray arr = new JsonArray();
        for (Reservation r : list) arr.add(buildResJson(r));
        JsonObject result = new JsonObject();
        result.addProperty("success", true);
        result.add("reservations", arr);
        out.print(result);
    }

    // ── POST ─────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (!authenticated(session)) { unauthorized(resp, out); return; }

        String action = nullToEmpty(req.getParameter("action"));
        if (!"add".equals(action)) { badRequest(resp, out, "Unknown action."); return; }

        String guestName     = nullToEmpty(req.getParameter("guestName")).trim();
        String address       = nullToEmpty(req.getParameter("address")).trim();
        String contactNumber = nullToEmpty(req.getParameter("contactNumber")).trim();
        String roomType      = nullToEmpty(req.getParameter("roomType")).trim();
        String checkIn       = nullToEmpty(req.getParameter("checkIn")).trim();
        String checkOut      = nullToEmpty(req.getParameter("checkOut")).trim();

        if (guestName.isEmpty() || contactNumber.isEmpty() ||
            roomType.isEmpty() || checkIn.isEmpty() || checkOut.isEmpty()) {
            badRequest(resp, out, "Guest name, contact, room type, check-in and check-out are required.");
            return;
        }

        int userId = ((User) session.getAttribute("loggedInUser")).getId();
        String result = svc.addReservation(guestName, address, contactNumber, roomType, checkIn, checkOut, userId);

        JsonObject json = new JsonObject();
        if (result.startsWith("error:")) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", result.substring(6));
        } else {
            // Fetch the full reservation to return it with bill
            Reservation r = svc.getReservation(result);
            json.addProperty("success", true);
            json.addProperty("message", "Reservation " + result + " created successfully.");
            json.addProperty("reservationNumber", result);
            if (r != null) {
                ReservationService.BillResult bill = svc.calculateBill(r.getId());
                if (bill != null) json.add("bill", buildBillJson(bill));
                json.add("reservation", buildResJson(r));
            }
        }
        out.print(json);
    }

    // ── JSON builders ────────────────────────────────────────────────────────
    private JsonObject buildResJson(Reservation r) {
        JsonObject o = new JsonObject();
        o.addProperty("id",                r.getId());
        o.addProperty("reservationNumber", r.getReservationNumber());
        o.addProperty("guestName",         r.getGuestName());
        o.addProperty("address",           r.getAddress() != null ? r.getAddress() : "");
        o.addProperty("contactNumber",     r.getContactNumber());
        o.addProperty("roomType",          r.getRoomType());
        o.addProperty("checkInDate",       r.getCheckInDate()  != null ? r.getCheckInDate().toString()  : "");
        o.addProperty("checkOutDate",      r.getCheckOutDate() != null ? r.getCheckOutDate().toString() : "");
        o.addProperty("totalAmount",       r.getTotalAmount()  != null ? r.getTotalAmount().toPlainString() : "0.00");
        o.addProperty("status",            r.getStatus());
        o.addProperty("createdBy",         r.getCreatedBy());
        o.addProperty("createdByName",     r.getCreatedByName() != null ? r.getCreatedByName() : "");
        o.addProperty("createdAt",         r.getCreatedAt() != null ? r.getCreatedAt() : "");
        return o;
    }

    private JsonObject buildBillJson(ReservationService.BillResult b) {
        Reservation r = b.reservation;
        JsonObject o = new JsonObject();
        o.addProperty("reservationNumber", r.getReservationNumber());
        o.addProperty("guestName",         r.getGuestName());
        o.addProperty("address",           r.getAddress() != null ? r.getAddress() : "");
        o.addProperty("contactNumber",     r.getContactNumber());
        o.addProperty("roomType",          r.getRoomType());
        o.addProperty("checkInDate",       r.getCheckInDate()  != null ? r.getCheckInDate().toString()  : "");
        o.addProperty("checkOutDate",      r.getCheckOutDate() != null ? r.getCheckOutDate().toString() : "");
        o.addProperty("nights",            b.nights);
        o.addProperty("ratePerNight",      String.format("%.2f", b.ratePerNight));
        o.addProperty("subtotal",          String.format("%.2f", b.subtotal));
        o.addProperty("taxRate",           String.format("%.0f%%", Reservation.TAX_RATE * 100));
        o.addProperty("tax",               String.format("%.2f", b.tax));
        o.addProperty("total",             String.format("%.2f", b.total));
        o.addProperty("status",            r.getStatus());
        return o;
    }

    // ── Response helpers ─────────────────────────────────────────────────────
    private boolean authenticated(HttpSession s) {
        return s != null && s.getAttribute("loggedInUser") != null;
    }

    private void unauthorized(HttpServletResponse resp, PrintWriter out) throws IOException {
        resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        JsonObject j = new JsonObject();
        j.addProperty("success", false); j.addProperty("message", "Not authenticated.");
        out.print(j);
    }

    private void badRequest(HttpServletResponse resp, PrintWriter out, String msg) throws IOException {
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        JsonObject j = new JsonObject();
        j.addProperty("success", false); j.addProperty("message", msg);
        out.print(j);
    }

    private void notFound(HttpServletResponse resp, PrintWriter out, String msg) throws IOException {
        resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
        JsonObject j = new JsonObject();
        j.addProperty("success", false); j.addProperty("message", msg);
        out.print(j);
    }

    private int    parseId(String s)      { try { return Integer.parseInt(s); } catch (Exception e) { return -1; } }
    private String nullToEmpty(String s)  { return s == null ? "" : s; }
}
