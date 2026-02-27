package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dto.GuestDTO;
import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.GuestService;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * REST-style servlet for guest management (manager and admin only).
 *
 * GET  /api/guests                    → list all guests
 * GET  /api/guests?id=X               → single guest by id
 * GET  /api/guests?mobile=X           → lookup guest by mobile number
 * GET  /api/guests?email=X            → lookup guest by email
 * GET  /api/guests?keyword=X          → search guests (name/mobile/email/NIC)
 * POST /api/guests  action=register   → register a new guest
 *
 * Consumes {@link GuestDTO} objects from the service layer.
 */
@WebServlet("/api/guests")
public class GuestController extends HttpServlet {

    private final GuestService svc = new GuestService();

    // ── GET ───────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (!authenticated(session)) { unauthorized(resp, out); return; }
        if (!isManagerOrAdmin(session)) { forbidden(resp, out); return; }

        String idParam      = req.getParameter("id");
        String mobileParam  = req.getParameter("mobile");
        String emailParam   = req.getParameter("email");
        String keywordParam = req.getParameter("keyword");

        JsonObject j = new JsonObject();

        // Lookup by id
        if (idParam != null) {
            int id = parseInt(idParam, -1);
            if (id <= 0) { badRequest(resp, out, "Invalid guest id."); return; }
            GuestDTO g = svc.findById(id);
            if (g == null) { notFound(resp, out, "Guest not found."); return; }
            j.addProperty("success", true);
            j.add("guest", guestJson(g));
            out.print(j);
            return;
        }

        // Lookup by mobile
        if (mobileParam != null && !mobileParam.isBlank()) {
            GuestDTO g = svc.findByMobile(mobileParam.trim());
            if (g == null) { notFound(resp, out, "No guest found with that mobile number."); return; }
            j.addProperty("success", true);
            j.add("guest", guestJson(g));
            out.print(j);
            return;
        }

        // Lookup by email
        if (emailParam != null && !emailParam.isBlank()) {
            GuestDTO g = svc.findByEmail(emailParam.trim());
            if (g == null) { notFound(resp, out, "No guest found with that email."); return; }
            j.addProperty("success", true);
            j.add("guest", guestJson(g));
            out.print(j);
            return;
        }

        // Search by keyword
        if (keywordParam != null && !keywordParam.isBlank()) {
            List<GuestDTO> results = svc.searchGuests(keywordParam.trim());
            JsonArray arr = new JsonArray();
            for (GuestDTO g : results) arr.add(guestJson(g));
            j.addProperty("success", true);
            j.add("guests", arr);
            out.print(j);
            return;
        }

        // List all
        List<GuestDTO> all = svc.getAllGuests();
        JsonArray arr = new JsonArray();
        for (GuestDTO g : all) arr.add(guestJson(g));
        j.addProperty("success", true);
        j.add("guests", arr);
        out.print(j);
    }

    // ── POST ──────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (!authenticated(session))    { unauthorized(resp, out); return; }
        if (!isManagerOrAdmin(session)) { forbidden(resp, out);    return; }

        String action = nullToEmpty(req.getParameter("action"));
        JsonObject j  = new JsonObject();

        if ("register".equals(action)) {
            String fullName     = nullToEmpty(req.getParameter("fullName")).trim();
            String mobileNumber = nullToEmpty(req.getParameter("mobileNumber")).trim();
            String email        = nullToEmpty(req.getParameter("email")).trim();
            String address      = nullToEmpty(req.getParameter("address")).trim();
            String nicNumber    = nullToEmpty(req.getParameter("nicNumber")).trim();
            String notes        = nullToEmpty(req.getParameter("notes")).trim();
            int    createdBy    = ((User) session.getAttribute("loggedInUser")).getId();

            String error = svc.registerGuest(fullName, mobileNumber,
                email.isEmpty() ? null : email,
                address, nicNumber, notes, createdBy);

            if (error == null) {
                j.addProperty("success", true);
                j.addProperty("message", "Guest \"" + fullName + "\" registered successfully.");
                // Return the newly created guest record
                GuestDTO g = svc.findByMobile(mobileNumber);
                if (g != null) j.add("guest", guestJson(g));
            } else {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                j.addProperty("success", false);
                j.addProperty("message", error);
            }
        } else {
            badRequest(resp, out, "Unknown action.");
            return;
        }

        out.print(j);
    }

    // ── JSON builder from GuestDTO ────────────────────────────────────────────
    private JsonObject guestJson(GuestDTO g) {
        JsonObject o = new JsonObject();
        o.addProperty("id",           g.getId());
        o.addProperty("fullName",     g.getFullName());
        o.addProperty("mobileNumber", g.getMobileNumber());
        o.addProperty("email",        g.getEmail());
        o.addProperty("address",      g.getAddress());
        o.addProperty("nicNumber",    g.getNicNumber());
        o.addProperty("notes",        g.getNotes());
        o.addProperty("createdBy",    g.getCreatedBy());
        o.addProperty("createdAt",    g.getCreatedAt());
        return o;
    }

    // ── Auth helpers ──────────────────────────────────────────────────────────
    private boolean authenticated(HttpSession s) {
        return s != null && s.getAttribute("loggedInUser") != null;
    }
    private boolean isManagerOrAdmin(HttpSession s) {
        String role = (String) s.getAttribute("role");
        return "manager".equals(role) || "admin".equals(role);
    }
    private void unauthorized(HttpServletResponse resp, PrintWriter out) throws IOException {
        resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        JsonObject j = new JsonObject();
        j.addProperty("success", false); j.addProperty("message", "Not authenticated.");
        out.print(j);
    }
    private void forbidden(HttpServletResponse resp, PrintWriter out) throws IOException {
        resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
        JsonObject j = new JsonObject();
        j.addProperty("success", false); j.addProperty("message", "Access denied.");
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
    private String nullToEmpty(String s) { return s != null ? s : ""; }
    private int    parseInt(String s, int def) { try { return Integer.parseInt(s); } catch (Exception e) { return def; } }
}
