package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dto.RoomDTO;
import com.example.oceanviewresort.service.RoomService;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * REST-style servlet for room management.
 * GET (list / single) → all authenticated roles.
 * POST (add / update / delete) → manager and admin only.
 *
 * GET  /api/rooms                → list all rooms
 * GET  /api/rooms?id=X           → single room
 * GET  /api/rooms?status=available → filtered list
 * POST /api/rooms  action=add    → add room
 * POST /api/rooms  action=update → update room
 * POST /api/rooms  action=delete → delete room
 *
 * Consumes {@link RoomDTO} objects produced by the service layer.
 */
@WebServlet("/api/rooms")
public class RoomController extends HttpServlet {

    private final RoomService svc = new RoomService();

    // ── GET ───────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (!authenticated(session)) { unauthorized(resp, out); return; }

        String statusFilter = req.getParameter("status");
        String idParam      = req.getParameter("id");

        if (idParam != null) {
            // Single room
            try {
                int id = Integer.parseInt(idParam);
                RoomDTO r = svc.getRoomById(id);
                JsonObject j = new JsonObject();
                if (r != null) {
                    j.addProperty("success", true);
                    j.add("room", roomJson(r));
                } else {
                    j.addProperty("success", false);
                    j.addProperty("message", "Room not found.");
                }
                out.print(j);
            } catch (NumberFormatException e) {
                JsonObject j = new JsonObject();
                j.addProperty("success", false);
                j.addProperty("message", "Invalid room id.");
                out.print(j);
            }
            return;
        }

        // All rooms (optionally filtered by status)
        List<RoomDTO> rooms = (statusFilter != null && !statusFilter.isBlank())
            ? svc.getRoomsByStatus(statusFilter)
            : svc.getAllRooms();

        JsonObject j = new JsonObject();
        j.addProperty("success", true);
        JsonArray arr = new JsonArray();
        for (RoomDTO r : rooms) arr.add(roomJson(r));
        j.add("rooms", arr);
        out.print(j);
    }

    // ── POST ──────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (!authenticated(session)) { unauthorized(resp, out); return; }
        if (!isManager(session))     { forbidden(resp, out);    return; }

        String action = req.getParameter("action");
        JsonObject j  = new JsonObject();

        if ("add".equals(action)) {
            String roomNumber  = req.getParameter("roomNumber");
            String roomType    = req.getParameter("roomType");
            String description = req.getParameter("description");
            double rate        = parseDouble(req.getParameter("ratePerNight"));
            String status      = req.getParameter("status");
            int    floor       = parseInt(req.getParameter("floor"), 1);

            String err = svc.addRoom(roomNumber, roomType, description, rate, status, floor);
            if (err == null) {
                j.addProperty("success", true);
                j.addProperty("message", "Room " + roomNumber + " added successfully.");
            } else {
                j.addProperty("success", false);
                j.addProperty("message", err);
            }

        } else if ("update".equals(action)) {
            int    id          = parseInt(req.getParameter("id"), -1);
            String roomNumber  = req.getParameter("roomNumber");
            String roomType    = req.getParameter("roomType");
            String description = req.getParameter("description");
            double rate        = parseDouble(req.getParameter("ratePerNight"));
            String status      = req.getParameter("status");
            int    floor       = parseInt(req.getParameter("floor"), 1);

            if (id <= 0) {
                j.addProperty("success", false);
                j.addProperty("message", "Invalid room id.");
            } else {
                String err = svc.updateRoom(id, roomNumber, roomType, description, rate, status, floor);
                if (err == null) {
                    j.addProperty("success", true);
                    j.addProperty("message", "Room updated successfully.");
                } else {
                    j.addProperty("success", false);
                    j.addProperty("message", err);
                }
            }

        } else if ("delete".equals(action)) {
            int id = parseInt(req.getParameter("id"), -1);
            if (id <= 0) {
                j.addProperty("success", false);
                j.addProperty("message", "Invalid room id.");
            } else {
                String err = svc.deleteRoom(id);
                if (err == null) {
                    j.addProperty("success", true);
                    j.addProperty("message", "Room deleted successfully.");
                } else {
                    j.addProperty("success", false);
                    j.addProperty("message", err);
                }
            }

        } else {
            j.addProperty("success", false);
            j.addProperty("message", "Unknown action.");
        }

        out.print(j);
    }

    // ── JSON builder from RoomDTO ─────────────────────────────────────────────
    private JsonObject roomJson(RoomDTO r) {
        JsonObject o = new JsonObject();
        o.addProperty("id",           r.getId());
        o.addProperty("roomNumber",   r.getRoomNumber());
        o.addProperty("roomType",     r.getRoomType());
        o.addProperty("description",  r.getDescription());
        o.addProperty("ratePerNight", r.getRatePerNight());
        o.addProperty("status",       r.getStatus());
        o.addProperty("floor",        r.getFloor());
        o.addProperty("createdAt",    r.getCreatedAt());
        return o;
    }

    // ── Auth helpers ──────────────────────────────────────────────────────────
    private boolean authenticated(HttpSession s) {
        return s != null && s.getAttribute("loggedInUser") != null;
    }
    private boolean isManager(HttpSession s) {
        String role = (String) s.getAttribute("role");
        return "manager".equals(role) || "admin".equals(role);
    }
    private void unauthorized(HttpServletResponse resp, PrintWriter out) throws IOException {
        resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        JsonObject j = new JsonObject();
        j.addProperty("success", false);
        j.addProperty("message", "Not authenticated.");
        out.print(j);
    }
    private void forbidden(HttpServletResponse resp, PrintWriter out) throws IOException {
        resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
        JsonObject j = new JsonObject();
        j.addProperty("success", false);
        j.addProperty("message", "Access denied. Manager role required.");
        out.print(j);
    }
    private double parseDouble(String s) {
        try { return Double.parseDouble(s); } catch (Exception e) { return 0; }
    }
    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}
