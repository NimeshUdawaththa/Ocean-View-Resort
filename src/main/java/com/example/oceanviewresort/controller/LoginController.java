package com.example.oceanviewresort.controller;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.UserService;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * REST-style API endpoint for user login.
 *
 * POST /api/login
 * Accepts JSON body: { "username": "...", "password": "..." }
 * Returns JSON:
 *   Success → { "success": true,  "role": "admin", "fullName": "Admin User", "redirectUrl": "/views/dashboard.jsp" }
 *   Failure → { "success": false, "message": "Invalid username or password." }
 */
@WebServlet(name = "loginController", value = "/api/login")
public class LoginController extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // ── Read form fields sent by jQuery AJAX ─────────────
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        PrintWriter out = response.getWriter();
        JsonObject json = new JsonObject();

        // Basic validation
        if (username == null || username.isBlank() ||
            password == null || password.isBlank()) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            json.addProperty("success", false);
            json.addProperty("message", "Username and password are required.");
            out.print(json);
            return;
        }

        // Authenticate
        User user = userService.authenticate(username.trim(), password);

        if (user != null) {
            // Store user info in session
            HttpSession session = request.getSession(true);
            session.setAttribute("loggedInUser", user);
            session.setAttribute("role",         user.getRole());
            session.setAttribute("fullName",     user.getFullName());
            session.setMaxInactiveInterval(30 * 60);   // 30 minutes

            // Role-based redirect
            String redirectUrl;
            switch (user.getRole()) {
                case User.ROLE_MANAGER:
                    redirectUrl = request.getContextPath() + "/views/dashboard.jsp";
                    break;
                case User.ROLE_RECEPTION:
                    redirectUrl = request.getContextPath() + "/views/dashboard.jsp";
                    break;
                default: // admin
                    redirectUrl = request.getContextPath() + "/views/dashboard.jsp";
            }

            json.addProperty("success",     true);
            json.addProperty("role",        user.getRole());
            json.addProperty("fullName",    user.getFullName());
            json.addProperty("redirectUrl", redirectUrl);

        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            json.addProperty("success", false);
            json.addProperty("message", "Invalid username or password.");
        }

        out.print(json);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        response.getWriter().print("{\"success\":false,\"message\":\"Use POST method.\"}");
    }
}
