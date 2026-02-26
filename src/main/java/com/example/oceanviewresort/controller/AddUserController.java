package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.UserService;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Set;

/**
 * Unified API endpoint for creating staff accounts.
 *
 * POST /api/users/add-user
 *
 * Caller = admin   : role param must be "manager" or "reception"
 * Caller = manager : role is forced to "reception" (param ignored)
 *
 * Params: username, password, email, fullName, role
 * Returns JSON: { "success": true/false, "message": "..." }
 */
@WebServlet(name = "addUserController", value = "/api/users/add-user")
public class AddUserController extends HttpServlet {

    private static final Set<String> ALLOWED_ROLES = Set.of(
            User.ROLE_MANAGER, User.ROLE_RECEPTION
    );

    private final UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out  = response.getWriter();
        JsonObject  json = new JsonObject();

        // ── Session guard ────────────────────────────────────
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            json.addProperty("success", false);
            json.addProperty("message", "Not authenticated.");
            out.print(json);
            return;
        }

        String sessionRole = (String) session.getAttribute("role");

        // ── Role guard: only admin or manager allowed ────────
        if (!User.ROLE_ADMIN.equals(sessionRole) && !User.ROLE_MANAGER.equals(sessionRole)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            json.addProperty("success", false);
            json.addProperty("message", "Access denied.");
            out.print(json);
            return;
        }

        // ── Determine target role ────────────────────────────
        // Manager can only create reception accounts.
        // Admin chooses via the 'role' parameter.
        String role;
        if (User.ROLE_MANAGER.equals(sessionRole)) {
            role = User.ROLE_RECEPTION;
        } else {
            role = nullToEmpty(request.getParameter("role")).trim();
            if (!ALLOWED_ROLES.contains(role)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                json.addProperty("success", false);
                json.addProperty("message", "Invalid role. Must be 'manager' or 'reception'.");
                out.print(json);
                return;
            }
        }

        // ── Read parameters ──────────────────────────────────
        String username = nullToEmpty(request.getParameter("username")).trim();
        String password = nullToEmpty(request.getParameter("password")).trim();
        String email    = nullToEmpty(request.getParameter("email")).trim();
        String fullName = nullToEmpty(request.getParameter("fullName")).trim();

        // ── Validation ───────────────────────────────────────
        if (username.isEmpty() || password.isEmpty() || fullName.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", "Username, password and full name are required.");
            out.print(json);
            return;
        }

        if (password.length() < 6) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", "Password must be at least 6 characters.");
            out.print(json);
            return;
        }

        // ── Delegate to service ──────────────────────────────
        String result = userService.addUser(username, password, email, fullName, role);

        switch (result) {
            case "ok":
                String roleLabel = role.substring(0, 1).toUpperCase() + role.substring(1);
                json.addProperty("success", true);
                json.addProperty("message", roleLabel + " account created successfully.");
                break;
            case "duplicate":
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                json.addProperty("success", false);
                json.addProperty("message", "Username already exists. Please choose another.");
                break;
            default:
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                json.addProperty("success", false);
                json.addProperty("message", "A server error occurred. Please try again.");
        }

        out.print(json);
    }

    private String nullToEmpty(String s) {
        return s == null ? "" : s;
    }
}
