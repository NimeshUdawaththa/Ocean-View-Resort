package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.util.DBConnection;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

/**
 * GET /api/reports
 * Returns summary statistics and full reservation history.
 * Accessible to Admin and Manager roles only.
 */
@WebServlet("/api/reports")
public class ReportController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"message\":\"Not authenticated.\"}");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        if (!User.ROLE_ADMIN.equals(user.getRole()) && !User.ROLE_MANAGER.equals(user.getRole())) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"success\":false,\"message\":\"Access denied.\"}");
            return;
        }

        String statusFilter = req.getParameter("status");   // optional: active, checked_in, etc.
        String fromDate     = req.getParameter("from");     // optional: yyyy-MM-dd
        String toDate       = req.getParameter("to");       // optional: yyyy-MM-dd

        JsonObject response = new JsonObject();

        try (Connection conn = DBConnection.getConnection()) {

            // ── Summary Stats ─────────────────────────────────────────────────
            JsonObject stats = new JsonObject();
            String statsSql = "SELECT " +
                "COUNT(*) AS total, " +
                "SUM(CASE WHEN status='active'      THEN 1 ELSE 0 END) AS active, " +
                "SUM(CASE WHEN status='checked_in'  THEN 1 ELSE 0 END) AS checked_in, " +
                "SUM(CASE WHEN status='checked_out' THEN 1 ELSE 0 END) AS checked_out, " +
                "SUM(CASE WHEN status='cancelled'   THEN 1 ELSE 0 END) AS cancelled, " +
                "SUM(CASE WHEN status IN ('checked_out','active','checked_in') THEN total_amount ELSE 0 END) AS total_revenue, " +
                "SUM(CASE WHEN status='checked_out' THEN total_amount ELSE 0 END) AS completed_revenue " +
                "FROM reservations";
            try (PreparedStatement ps = conn.prepareStatement(statsSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.addProperty("total",            rs.getInt("total"));
                    stats.addProperty("active",           rs.getInt("active"));
                    stats.addProperty("checkedIn",        rs.getInt("checked_in"));
                    stats.addProperty("checkedOut",       rs.getInt("checked_out"));
                    stats.addProperty("cancelled",        rs.getInt("cancelled"));
                    stats.addProperty("totalRevenue",     rs.getDouble("total_revenue"));
                    stats.addProperty("completedRevenue", rs.getDouble("completed_revenue"));
                }
            }
            response.add("stats", stats);

            // ── Reservation History with optional filters ──────────────────────
            StringBuilder histSql = new StringBuilder(
                "SELECT r.id, r.reservation_number, r.guest_name, r.contact_number, " +
                "r.room_type, r.check_in_date, r.check_out_date, r.total_amount, r.status, " +
                "r.created_at, DATEDIFF(r.check_out_date, r.check_in_date) AS nights, " +
                "u.full_name AS created_by_name " +
                "FROM reservations r LEFT JOIN users u ON r.created_by = u.id " +
                "WHERE 1=1 "
            );

            boolean hasStatus = statusFilter != null && !statusFilter.isBlank() && !"all".equals(statusFilter);
            boolean hasFrom   = fromDate != null && fromDate.matches("\\d{4}-\\d{2}-\\d{2}");
            boolean hasTo     = toDate   != null && toDate.matches("\\d{4}-\\d{2}-\\d{2}");

            if (hasStatus) histSql.append("AND r.status = ? ");
            if (hasFrom)   histSql.append("AND r.check_in_date >= ? ");
            if (hasTo)     histSql.append("AND r.check_in_date <= ? ");
            histSql.append("ORDER BY r.created_at DESC");

            JsonArray history = new JsonArray();
            try (PreparedStatement ps = conn.prepareStatement(histSql.toString())) {
                int idx = 1;
                if (hasStatus) ps.setString(idx++, statusFilter);
                if (hasFrom)   ps.setString(idx++, fromDate);
                if (hasTo)     ps.setString(idx++, toDate);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        JsonObject row = new JsonObject();
                        row.addProperty("id",                 rs.getInt("id"));
                        row.addProperty("reservationNumber",  rs.getString("reservation_number"));
                        row.addProperty("guestName",          rs.getString("guest_name"));
                        row.addProperty("contactNumber",      rs.getString("contact_number"));
                        row.addProperty("roomType",           rs.getString("room_type"));
                        row.addProperty("checkInDate",        rs.getString("check_in_date"));
                        row.addProperty("checkOutDate",       rs.getString("check_out_date"));
                        row.addProperty("nights",             rs.getInt("nights"));
                        row.addProperty("totalAmount",        rs.getDouble("total_amount"));
                        row.addProperty("status",             rs.getString("status"));
                        row.addProperty("createdAt",          rs.getString("created_at"));
                        row.addProperty("createdByName",      rs.getString("created_by_name") != null
                                                              ? rs.getString("created_by_name") : "—");
                        history.add(row);
                    }
                }
            }
            response.add("history", history);
            response.addProperty("success", true);

        } catch (SQLException e) {
            System.err.println("[ReportController] error: " + e.getMessage());
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("success", false);
            response.addProperty("message", "Failed to load report data.");
        }

        out.print(response);
    }
}
