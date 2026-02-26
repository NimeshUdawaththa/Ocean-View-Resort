<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Session guard — redirect to login if not authenticated
    if (session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("fullName");
    String role     = (String) session.getAttribute("role");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | OceanView Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f0f6fa;
            min-height: 100vh;
            color: #1e3a4a;
        }

        /* ── Navbar ── */
        nav {
            background: linear-gradient(135deg, #0a4f6e, #1aa3c8);
            padding: 0 32px;
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 12px rgba(0,50,80,.25);
        }

        .nav-brand {
            display: flex;
            align-items: center;
            gap: 12px;
            color: white;
            font-size: 20px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .nav-brand span { font-size: 26px; }

        .nav-right {
            display: flex;
            align-items: center;
            gap: 18px;
        }

        .nav-user {
            color: rgba(255,255,255,.9);
            font-size: 14px;
        }

        .nav-user strong {
            display: block;
            font-size: 15px;
            color: white;
        }

        .btn-logout {
            background: rgba(255,255,255,.15);
            color: white;
            border: 1px solid rgba(255,255,255,.3);
            padding: 8px 18px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 13.5px;
            font-weight: 600;
            text-decoration: none;
            transition: background .2s;
        }

        .btn-logout:hover { background: rgba(255,255,255,.28); }

        /* ── Main ── */
        main {
            max-width: 1100px;
            margin: 40px auto;
            padding: 0 24px;
        }

        .welcome-banner {
            background: linear-gradient(135deg, #0a4f6e 0%, #1aa3c8 100%);
            border-radius: 16px;
            padding: 32px 36px;
            color: white;
            margin-bottom: 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 8px 28px rgba(13,122,154,.35);
        }

        .welcome-banner h1 { font-size: 26px; margin-bottom: 6px; }
        .welcome-banner p  { opacity: .85; font-size: 15px; }

        .welcome-banner .badge {
            background: rgba(255,255,255,.2);
            border: 1px solid rgba(255,255,255,.35);
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* ── Cards grid ── */
        .cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
        }

        .card {
            background: white;
            border-radius: 14px;
            padding: 26px 24px;
            box-shadow: 0 4px 14px rgba(0,50,80,.08);
            border-left: 4px solid #1aa3c8;
            transition: transform .2s, box-shadow .2s;
        }

        .card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(0,50,80,.14);
        }

        .card .icon {
            font-size: 32px;
            margin-bottom: 12px;
        }

        .card h3 {
            font-size: 15px;
            color: #7a95a8;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .5px;
            margin-bottom: 6px;
        }

        .card .value {
            font-size: 32px;
            font-weight: 700;
            color: #0a4f6e;
        }

        .card:nth-child(2) { border-left-color: #34a853; }
        .card:nth-child(3) { border-left-color: #f4a22b; }
        .card:nth-child(4) { border-left-color: #e04b3a; }

        /* ── Manager actions ── */
        .section-title {
            font-size: 16px;
            font-weight: 700;
            color: #0a4f6e;
            margin: 36px 0 16px;
            padding-bottom: 8px;
            border-bottom: 2px solid #dce8ee;
        }

        .action-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
        }

        .action-card {
            background: white;
            border-radius: 14px;
            padding: 24px 22px;
            box-shadow: 0 4px 14px rgba(0,50,80,.08);
            text-decoration: none;
            color: #1e3a4a;
            display: flex;
            align-items: center;
            gap: 16px;
            transition: transform .2s, box-shadow .2s;
            border: 2px solid transparent;
        }

        .action-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(0,50,80,.14);
            border-color: #1aa3c8;
        }

        .action-card .ac-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: linear-gradient(135deg, #0a4f6e, #1aa3c8);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }

        .action-card .ac-text h4 {
            font-size: 15px;
            font-weight: 700;
            margin-bottom: 3px;
        }

        .action-card .ac-text p {
            font-size: 12.5px;
            color: #7a95a8;
        }

        footer {
            text-align: center;
            padding: 32px;
            color: #9ab4c2;
            font-size: 13px;
        }
    </style>
</head>
<body>

    <!-- Navbar -->
    <nav>
        <div class="nav-brand">
            <span>&#9875;</span> OceanView Resort
        </div>
        <div class="nav-right">
            <div class="nav-user">
                <strong><%= fullName != null ? fullName : "User" %></strong>
                <%= role != null ? role.substring(0, 1).toUpperCase() + role.substring(1) : "" %>
            </div>
            <a href="<%= request.getContextPath() %>/api/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <!-- Main content -->
    <main>
        <div class="welcome-banner">
            <div>
                <h1>Welcome back, <%= fullName != null ? fullName : "User" %>!</h1>
                <p>Here's what's happening at OceanView Resort today.</p>
            </div>
            <div class="badge"><%= role %></div>
        </div>

        <!-- Stat cards -->
        <div class="cards">
            <div class="card">
                <div class="icon">&#127968;</div>
                <h3>Total Rooms</h3>
                <div class="value">48</div>
            </div>
            <div class="card">
                <div class="icon">&#9989;</div>
                <h3>Booked</h3>
                <div class="value">31</div>
            </div>
            <div class="card">
                <div class="icon">&#8987;</div>
                <h3>Pending</h3>
                <div class="value">5</div>
            </div>
            <div class="card">
                <div class="icon">&#128100;</div>
                <h3>Guests Today</h3>
                <div class="value">62</div>
            </div>
        </div>

        <% if ("admin".equals(role)) { %>
        <!-- Admin quick actions -->
        <div class="section-title">&#9881; Admin Actions</div>
        <div class="action-cards">
            <a href="<%= request.getContextPath() %>/views/manage-users.jsp" class="action-card">
                <div class="ac-icon" style="background: linear-gradient(135deg,#7b2d8b,#a855f7);">&#9998;</div>
                <div class="ac-text">
                    <h4>Manage Staff</h4>
                    <p>Edit or remove manager &amp; reception accounts</p>
                </div>
            </a>
        </div>
        <% } %>

        <% if ("manager".equals(role)) { %>
        <!-- Manager quick actions -->
        <div class="section-title">&#9881; Manager Actions</div>
        <div class="action-cards">
            <a href="<%= request.getContextPath() %>/views/add-user.jsp" class="action-card">
                <div class="ac-icon">&#128100;</div>
                <div class="ac-text">
                    <h4>Add Reception Staff</h4>
                    <p>Create a new front-desk account</p>
                </div>
            </a>
        </div>
        <% } %>

    </main>

    <footer>OceanView Resort &copy; 2026 &mdash; Management System</footer>

</body>
</html>
