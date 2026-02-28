package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.dto.BillDTO;
import com.example.oceanviewresort.dto.ReservationDTO;
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
 * POST /api/reservations  action=update    → edit dates/address  (manager/admin only)
 * POST /api/reservations  action=cancel    → cancel reservation  (manager/admin only)
 *
 * Consumes {@link ReservationDTO} and {@link BillDTO} from the service layer.
 */
@WebServlet(name = "reservationController", value = "/api/reservations")
public class ReservationController extends HttpServlet {

    private final ReservationService svc = new ReservationService();
    private final RoomDAO  roomDAO = new RoomDAO();

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (!authenticated(session)) { unauthorized(resp, out); return; }

        String role = (String) session.getAttribute("role");
        int userId = ((User) session.getAttribute("loggedInUser")).getId();

        String action = nullToEmpty(req.getParameter("action"));
        String idParam = nullToEmpty(req.getParameter("id"));

        // ── bill ─────────────────────────────────────────────
        if ("bill".equals(action)) {
            int id = parseId(idParam);
            if (id <= 0) { badRequest(resp, out, "Valid reservation id required."); return; }

            BillDTO bill = svc.calculateBill(id);
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

            ReservationDTO r = svc.getReservationById(id);
            if (r == null) { notFound(resp, out, "Reservation not found."); return; }

            JsonObject json = new JsonObject();
            json.addProperty("success", true);
            json.add("reservation", buildResJson(r));
            out.print(json);
            return;
        }

        // ── list ─────────────────────────────────────────────
        // Expire any past-checkout reservations before returning data
        svc.expireCheckedOut();
        List<ReservationDTO> list = svc.getAllReservations();

        JsonArray arr = new JsonArray();
        for (ReservationDTO r : list) arr.add(buildResJson(r));
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

        // ── add ───────────────────────────────────────────────────────────────
        if ("add".equals(action)) {
            String guestName = nullToEmpty(req.getParameter("guestName")).trim();
            String address  = nullToEmpty(req.getParameter("address")).trim();
            String contactNumber = nullToEmpty(req.getParameter("contactNumber")).trim();
            String roomType  = nullToEmpty(req.getParameter("roomType")).trim();
            String checkIn  = nullToEmpty(req.getParameter("checkIn")).trim();
            String checkOut = nullToEmpty(req.getParameter("checkOut")).trim();
            String roomIdParam = nullToEmpty(req.getParameter("roomId")).trim();

            if (guestName.isEmpty() || contactNumber.isEmpty() ||
                roomType.isEmpty() || checkIn.isEmpty() || checkOut.isEmpty()) {
                badRequest(resp, out,
                    "Guest name, contact, room type, check-in and check-out are required.");
                return;
            }

            int userId = ((User) session.getAttribute("loggedInUser")).getId();
            int roomIdInt = roomIdParam.isEmpty() ? 0 : parseId(roomIdParam);
            String result = svc.addReservation(
                guestName, address, contactNumber, roomType, checkIn, checkOut, userId, roomIdInt);

            JsonObject json = new JsonObject();
            if (result.startsWith("error:")) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                json.addProperty("success", false);
                json.addProperty("message", result.substring(6));
            } else {
                // Mark the specific room as occupied
                if (!roomIdParam.isEmpty()) {
                    try {
                        roomDAO.updateStatus(Integer.parseInt(roomIdParam), "occupied");
                    } catch (NumberFormatException ignored) {}
                }
                ReservationDTO r = svc.getReservation(result);
                json.addProperty("success", true);
                json.addProperty("message", "Reservation " + result + " created successfully.");
                json.addProperty("reservationNumber", result);
                if (r != null) {
                    BillDTO bill = svc.calculateBill(r.getId());
                    if (bill != null) json.add("bill", buildBillJson(bill));
                    json.add("reservation", buildResJson(r));
                }
            }
            out.print(json);
            return;
        }

        // ── update ────────────────────────────────────────────────────────────
        if ("update".equals(action)) {
            int    id         = parseId(nullToEmpty(req.getParameter("id")));
            String checkIn    = nullToEmpty(req.getParameter("checkIn")).trim();
            String checkOut   = nullToEmpty(req.getParameter("checkOut")).trim();
            String address    = nullToEmpty(req.getParameter("address")).trim();
            String roomType   = nullToEmpty(req.getParameter("roomType")).trim();
            String newRoomId  = nullToEmpty(req.getParameter("newRoomId")).trim();
            String oldRoomId  = nullToEmpty(req.getParameter("oldRoomId")).trim();

            if (id <= 0 || checkIn.isEmpty() || checkOut.isEmpty()) {
                badRequest(resp, out, "Valid id, check-in and check-out are required.");
                return;
            }

            String err = svc.updateReservation(id, checkIn, checkOut, address, roomType,
                    newRoomId.isEmpty() ? 0 : parseId(newRoomId));
            JsonObject json = new JsonObject();
            if (err != null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                json.addProperty("success", false);
                json.addProperty("message", err.substring(6));
            } else {
                // Swap room statuses when room changed
                if (!newRoomId.isEmpty() && !oldRoomId.isEmpty() && !newRoomId.equals(oldRoomId)) {
                    try {
                        roomDAO.updateStatus(Integer.parseInt(oldRoomId), "available");
                        roomDAO.updateStatus(Integer.parseInt(newRoomId), "occupied");
                    } catch (NumberFormatException ignored) {}
                }
                json.addProperty("success", true);
                json.addProperty("message", "Reservation updated successfully.");
                ReservationDTO r = svc.getReservationById(id);
                if (r != null) json.add("reservation", buildResJson(r));
            }
            out.print(json);
            return;
        }

        // ── cancel ────────────────────────────────────────────────────────────
        if ("cancel".equals(action)) {
            int id = parseId(nullToEmpty(req.getParameter("id")));
            if (id <= 0) { badRequest(resp, out, "Valid reservation id required."); return; }

            boolean ok = svc.cancelReservation(id);
            JsonObject json = new JsonObject();
            json.addProperty("success", ok);
            json.addProperty("message", ok ? "Reservation cancelled." : "Reservation not found or already closed.");
            out.print(json);
            return;
        }

        badRequest(resp, out, "Unknown action.");
    }

    // ── JSON builders from DTOs ──────────────────────────────────────────────
    private JsonObject buildResJson(ReservationDTO r) {
        JsonObject o = new JsonObject();
        o.addProperty("id",                r.getId());
        o.addProperty("reservationNumber", r.getReservationNumber());
        o.addProperty("guestName",         r.getGuestName());
        o.addProperty("address",           r.getAddress());
        o.addProperty("contactNumber",     r.getContactNumber());
        o.addProperty("roomType",          r.getRoomType());
        o.addProperty("roomId",            r.getRoomId());
        o.addProperty("checkInDate",       r.getCheckInDate());
        o.addProperty("checkOutDate",      r.getCheckOutDate());
        o.addProperty("totalAmount",       r.getTotalAmount());
        o.addProperty("status",            r.getStatus());
        o.addProperty("createdBy",         r.getCreatedBy());
        o.addProperty("createdByName",     r.getCreatedByName());
        o.addProperty("createdAt",         r.getCreatedAt());
        return o;
    }

    private JsonObject buildBillJson(BillDTO b) {
        JsonObject o = new JsonObject();
        o.addProperty("reservationNumber", b.getReservationNumber());
        o.addProperty("guestName",         b.getGuestName());
        o.addProperty("address",           b.getAddress());
        o.addProperty("contactNumber",     b.getContactNumber());
        o.addProperty("roomType",          b.getRoomType());
        o.addProperty("checkInDate",       b.getCheckInDate());
        o.addProperty("checkOutDate",      b.getCheckOutDate());
        o.addProperty("nights",            b.getNights());
        o.addProperty("ratePerNight",      b.getRatePerNight());
        o.addProperty("subtotal",          b.getSubtotal());
        o.addProperty("taxRate",           b.getTaxRate());
        o.addProperty("tax",               b.getTax());
        o.addProperty("total",             b.getTotal());
        o.addProperty("status",            b.getStatus());
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
    private void badRequest(HttpServletResponse resp, PrintWriter out, String msg)
            throws IOException {
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        JsonObject j = new JsonObject();
        j.addProperty("success", false); j.addProperty("message", msg);
        out.print(j);
    }
    private void notFound(HttpServletResponse resp, PrintWriter out, String msg)
            throws IOException {
        resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
        JsonObject j = new JsonObject();
        j.addProperty("success", false); j.addProperty("message", msg);
        out.print(j);
    }
    private String nullToEmpty(String s) { return s != null ? s : ""; }
    private int    parseId(String s)     { try { return Integer.parseInt(s); } catch (Exception e) { return -1; } }
}
