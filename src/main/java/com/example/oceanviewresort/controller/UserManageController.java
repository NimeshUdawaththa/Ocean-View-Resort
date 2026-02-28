package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.dto.UserDTO;
import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.UserService;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Set;

/**
 * Admin-only user management API.
 *
 * GET  /api/users                    → JSON list of all manager + reception users
 * POST /api/users  action=update     → update a user record
 * POST /api/users  action=delete     → delete a user by id
 *
 * Consumes {@link UserDTO} objects produced by the service layer.
 */
@WebServlet(name = "userManageController", value = "/api/users")
public class UserManageController extends HttpServlet {

    private static final Set<String> ALLOWED_ROLES = Set.of(
            User.ROLE_MANAGER, User.ROLE_RECEPTION
    );

    private final UserService userService = new UserService();

    // ── GET — list all managed users ─────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (!isAdminOrManager(request, response, out)) return;

        List<UserDTO> users = userService.getManagedUsers();

        JsonArray array = new JsonArray();
        for (UserDTO u : users) {
            JsonObject obj = new JsonObject();
            obj.addProperty("id",       u.getId());
            obj.addProperty("username", u.getUsername());
            obj.addProperty("fullName", u.getFullName());
            obj.addProperty("email",    u.getEmail());
            obj.addProperty("role",     u.getRole());
            array.add(obj);
        }

        JsonObject result = new JsonObject();
        result.addProperty("success", true);
        result.add("users", array);
        out.print(result);
    }

    // ── POST — update or delete ───────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out  = response.getWriter();
        JsonObject  json = new JsonObject();

        if (!isAdminOrManager(request, response, out)) return;

        String action = nullToEmpty(request.getParameter("action"));
        // Managers may only update / delete reception accounts
        String callerRole = (String) request.getSession(false).getAttribute("role");

        switch (action) {

            case "update": {
                int    id       = parseId(request.getParameter("id"));
                String username = nullToEmpty(request.getParameter("username")).trim();
                String password = nullToEmpty(request.getParameter("password")).trim();
                String email    = nullToEmpty(request.getParameter("email")).trim();
                String fullName = nullToEmpty(request.getParameter("fullName")).trim();
                String role     = nullToEmpty(request.getParameter("role")).trim();

                if (id <= 0 || username.isEmpty() || fullName.isEmpty()) {
                    badRequest(response, out, json, "ID, username and full name are required.");
                    return;
                }
                if (!password.isEmpty() && password.length() < 6) {
                    badRequest(response, out, json, "Password must be at least 6 characters.");
                    return;
                }
                if (!ALLOWED_ROLES.contains(role)) {
                    badRequest(response, out, json, "Invalid role.");
                    return;
                }
                // Managers may only manage reception accounts
                if (User.ROLE_MANAGER.equals(callerRole) && !User.ROLE_RECEPTION.equals(role)) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    json.addProperty("success", false);
                    json.addProperty("message", "Managers can only edit reception accounts.");
                    out.print(json);
                    return;
                }

                String res = userService.updateUser(id, username, password, email, fullName, role);
                handleResult(response, out, json, res,
                        "User updated successfully.",
                        "Username already taken.",
                        "Failed to update user.");
                break;
            }

            case "delete": {
                int id = parseId(request.getParameter("id"));
                if (id <= 0) {
                    badRequest(response, out, json, "Valid user ID is required.");
                    return;
                }
                // Managers may only delete reception accounts
                if (User.ROLE_MANAGER.equals(callerRole)) {
                    UserDTO target = userService.getManagedUsers().stream()
                            .filter(u -> u.getId() == id).findFirst().orElse(null);
                    if (target == null || !User.ROLE_RECEPTION.equals(target.getRole())) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        json.addProperty("success", false);
                        json.addProperty("message", "Managers can only delete reception accounts.");
                        out.print(json);
                        return;
                    }
                }
                String res = userService.deleteUser(id);
                if ("protected".equals(res)) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    json.addProperty("success", false);
                    json.addProperty("message", "Admin accounts cannot be deleted.");
                    out.print(json);
                    return;
                }
                handleResult(response, out, json, res,
                        "User deleted successfully.",
                        null,
                        "Failed to delete user.");
                break;
            }

            default:
                badRequest(response, out, json, "Unknown action.");
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────
    private boolean isAdminOrManager(HttpServletRequest request,
                                     HttpServletResponse response,
                                     PrintWriter out) throws IOException {
        HttpSession session = request.getSession(false);
        JsonObject json = new JsonObject();

        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            json.addProperty("success", false);
            json.addProperty("message", "Not authenticated.");
            out.print(json);
            return false;
        }

        String role = (String) session.getAttribute("role");
        if (!User.ROLE_ADMIN.equals(role) && !User.ROLE_MANAGER.equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            json.addProperty("success", false);
            json.addProperty("message", "Access denied.");
            out.print(json);
            return false;
        }
        return true;
    }

    private boolean isAdmin(HttpServletRequest request,
                             HttpServletResponse response,
                             PrintWriter out) throws IOException {
        HttpSession session = request.getSession(false);
        JsonObject json = new JsonObject();

        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            json.addProperty("success", false);
            json.addProperty("message", "Not authenticated.");
            out.print(json);
            return false;
        }

        String role = (String) session.getAttribute("role");
        if (!User.ROLE_ADMIN.equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            json.addProperty("success", false);
            json.addProperty("message", "Access denied. Admin role required.");
            out.print(json);
            return false;
        }
        return true;
    }

    private void badRequest(HttpServletResponse response, PrintWriter out,
                            JsonObject json, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        json.addProperty("success", false);
        json.addProperty("message", message);
        out.print(json);
    }

    private void handleResult(HttpServletResponse response, PrintWriter out,
                               JsonObject json, String res,
                               String okMsg, String dupMsg, String errMsg) throws IOException {
        switch (res) {
            case "ok":
                json.addProperty("success", true);
                json.addProperty("message", okMsg);
                break;
            case "duplicate":
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                json.addProperty("success", false);
                json.addProperty("message", dupMsg != null ? dupMsg : "Duplicate entry.");
                break;
            default:
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                json.addProperty("success", false);
                json.addProperty("message", errMsg);
        }
        out.print(json);
    }

    private String nullToEmpty(String s) { return s != null ? s : ""; }
    private int    parseId(String s)     { try { return Integer.parseInt(s); } catch (Exception e) { return -1; } }
}
