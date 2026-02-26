package com.example.oceanviewresort.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Handles user logout.
 *
 * GET /api/logout  → invalidates session and redirects to login page.
 */
@WebServlet(name = "logoutController", value = "/api/logout")
public class LogoutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
    }
}
