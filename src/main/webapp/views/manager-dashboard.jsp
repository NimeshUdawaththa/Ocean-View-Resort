<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    if (!"manager".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("fullName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Dashboard | OceanView Resort</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif; background:#f0f6fa; min-height:100vh; color:#1e3a4a; }

        /* Navbar */
        nav { background:linear-gradient(135deg,#0a4f6e,#1aa3c8); padding:0 32px; height:64px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 2px 12px rgba(0,50,80,.25); position:sticky; top:0; z-index:900; }
        .nav-brand { display:flex; align-items:center; gap:10px; color:white; font-size:20px; font-weight:700; }
        .nav-brand span { font-size:26px; }
        .nav-right { display:flex; align-items:center; gap:12px; }
        .nav-user { color:rgba(255,255,255,.9); font-size:14px; text-align:right; }
        .nav-user strong { display:block; font-size:15px; color:white; }
        .btn-nav { background:rgba(255,255,255,.15); color:white; border:1px solid rgba(255,255,255,.3); padding:8px 18px; border-radius:8px; cursor:pointer; font-size:13.5px; font-weight:600; text-decoration:none; transition:background .2s; }
        .btn-nav:hover { background:rgba(255,255,255,.28); }
        .btn-nav-primary { background:rgba(255,255,255,.9); color:#0a4f6e; border:none; padding:9px 20px; border-radius:8px; font-size:13.5px; font-weight:700; cursor:pointer; text-decoration:none; transition:all .2s; }
        .btn-nav-primary:hover { background:white; }

        main { max-width:1200px; margin:36px auto; padding:0 24px; }

        /* Welcome */
        .welcome { margin-bottom:28px; }
        .welcome h1 { font-size:26px; font-weight:800; color:#0a4f6e; }
        .welcome p  { color:#7a95a8; font-size:14px; margin-top:4px; }

        /* Stats */
        .stats { display:grid; grid-template-columns:repeat(auto-fit,minmax(170px,1fr)); gap:16px; margin-bottom:28px; }
        .stat-card { background:white; border-radius:14px; padding:20px 22px; box-shadow:0 3px 14px rgba(0,50,80,.08); display:flex; align-items:center; gap:16px; }
        .stat-icon { width:50px; height:50px; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0; }
        .stat-info .val { font-size:26px; font-weight:800; color:#0a4f6e; }
        .stat-info .lbl { font-size:12.5px; color:#8aacbc; margin-top:2px; }

        /* Quick Actions */
        .section-title { font-size:14px; font-weight:700; color:#7a95a8; text-transform:uppercase; letter-spacing:.6px; margin-bottom:14px; }
        .action-cards { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin-bottom:30px; }
        .action-card { display:flex; align-items:center; gap:14px; background:white; border-radius:13px; padding:16px 20px; text-decoration:none; color:#1e3a4a; box-shadow:0 3px 12px rgba(0,50,80,.08); border:2px solid transparent; cursor:pointer; transition:all .2s; min-width:200px; }
        .action-card:hover { border-color:#1aa3c8; transform:translateY(-2px); box-shadow:0 6px 18px rgba(0,80,120,.13); }
        .ac-icon { width:44px; height:44px; border-radius:11px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); display:flex; align-items:center; justify-content:center; font-size:20px; color:white; flex-shrink:0; }
        .ac-text h4 { font-size:14px; font-weight:700; }
        .ac-text p  { font-size:12px; color:#8aacbc; margin-top:2px; }

        /* Filter tabs */
        .filter-bar { display:flex; gap:8px; margin-bottom:14px; flex-wrap:wrap; }
        .filter-btn { padding:7px 16px; border-radius:20px; border:2px solid #dce8ee; background:white; font-size:13px; font-weight:600; color:#3a5a6e; cursor:pointer; transition:all .2s; }
        .filter-btn.active, .filter-btn:hover { border-color:#1aa3c8; background:#e6f7fd; color:#0a4f6e; }

        /* Alert */
        .alert { display:none; padding:12px 16px; border-radius:10px; font-size:14px; font-weight:500; margin-bottom:18px; }
        .alert-success { background:#e8f8f0; color:#1e8449; border:1px solid #b8e8ce; }
        .alert-error   { background:#fde8e8; color:#c0392b; border:1px solid #f5c6c6; }

        /* Table card */
        .table-card { background:white; border-radius:16px; box-shadow:0 4px 20px rgba(0,50,80,.09); overflow:hidden; }
        .table-toolbar { padding:18px 22px; border-bottom:1px solid #e8f0f4; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px; }
        .toolbar-title { font-size:16px; font-weight:700; color:#0a4f6e; }
        .search-box { position:relative; min-width:200px; max-width:280px; }
        .search-box input { width:100%; padding:9px 14px 9px 36px; border:2px solid #dce8ee; border-radius:8px; font-size:14px; color:#1e3a4a; background:#f6fafc; outline:none; transition:border-color .25s; }
        .search-box input:focus { border-color:#1aa3c8; background:white; }
        .search-icon { position:absolute; left:10px; top:50%; transform:translateY(-50%); color:#8aacbc; font-size:14px; }
        .btn-add-res { display:inline-flex; align-items:center; gap:7px; padding:10px 20px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; border:none; border-radius:9px; font-size:13.5px; font-weight:700; cursor:pointer; box-shadow:0 4px 12px rgba(13,122,154,.3); transition:transform .2s; }
        .btn-add-res:hover { transform:translateY(-2px); }
        .toolbar-actions { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
        .btn-secondary { display:inline-flex; align-items:center; gap:7px; padding:9px 20px; background:linear-gradient(135deg,#1b6b33,#34a853); color:white; border:none; border-radius:9px; font-size:13.5px; font-weight:700; cursor:pointer; box-shadow:0 4px 12px rgba(52,168,83,.28); transition:transform .2s; }
        .btn-secondary:hover { transform:translateY(-2px); }
        .btn-guest-view   { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e6f7fd; color:#0a4f6e; transition:all .2s; margin-right:3px; }
        .btn-guest-view:hover   { background:#1aa3c8; color:white; }
        .btn-guest-edit   { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e8f8ee; color:#1a7a4e; transition:all .2s; margin-right:3px; }
        .btn-guest-edit:hover   { background:#27ae60; color:white; }
        .btn-guest-delete { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fdecea; color:#c0392b; transition:all .2s; margin-right:3px; }
        .btn-guest-delete:hover { background:#e04b3a; color:white; }
        .btn-reserve { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fff3cd; color:#856404; transition:all .2s; margin-right:3px; }
        .btn-reserve:hover { background:#ffc107; color:#1a1a1a; }

        table { width:100%; border-collapse:collapse; }
        thead th { padding:12px 16px; text-align:left; font-size:12px; font-weight:700; color:#7a95a8; text-transform:uppercase; letter-spacing:.5px; background:#f6fafc; border-bottom:2px solid #e8f0f4; white-space:nowrap; }
        tbody tr { border-bottom:1px solid #eef4f7; transition:background .15s; cursor:pointer; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:#f0f9ff; }
        tbody td { padding:12px 16px; font-size:13.5px; vertical-align:middle; }

        .badge { display:inline-block; padding:4px 11px; border-radius:20px; font-size:12px; font-weight:700; }
        .badge-active     { background:#e8f8ee; color:#1b6b33; }
        .badge-checkedout { background:#e6f7fd; color:#0a4f6e; }
        .badge-checkin    { background:#fff8e1; color:#e65100; }
        .badge-cancelled  { background:#fde8e8; color:#c0392b; }
        .btn-checkin  { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fff3cd; color:#856404; transition:all .2s; margin-right:3px; }
        .btn-checkin:hover  { background:#ffc107; color:#1a1a1a; }
        .btn-checkout { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#d1ecf1; color:#0c5460; transition:all .2s; margin-right:3px; }
        .btn-checkout:hover { background:#17a2b8; color:white; }
        .btn-view { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e6f7fd; color:#0a4f6e; transition:all .2s; margin-right:3px; }
        .btn-view:hover { background:#1aa3c8; color:white; }
        .btn-bill { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e8f8ee; color:#1b6b33; transition:all .2s; }
        .btn-bill:hover { background:#34a853; color:white; }
        .btn-edit { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fff3e0; color:#b7690a; transition:all .2s; margin-right:4px; }
        .btn-edit:hover { background:#f59f00; color:white; }
        .btn-delete { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fde8e8; color:#c0392b; transition:all .2s; }
        .btn-delete:hover { background:#e04b3a; color:white; }
        .badge-available   { background:#e8f8ee; color:#1b6b33; }
        .badge-occupied    { background:#fde8e8; color:#c0392b; }
        .badge-maintenance { background:#fff3e0; color:#b7690a; }
        .badge-manager     { background:#e6f7fd; color:#0a4f6e; }
        .badge-reception   { background:#e8f8ee; color:#1b6b33; }
        .section-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; flex-wrap:wrap; gap:10px; }

        /* Tabs */
        .tab-nav  { display:flex; gap:4px; margin-bottom:20px; border-bottom:2px solid #e8f0f4; }
        .tab-btn  { padding:10px 22px; border:none; background:none; font-size:14px; font-weight:600; color:#7a95a8; cursor:pointer; border-bottom:3px solid transparent; margin-bottom:-2px; transition:all .2s; border-radius:8px 8px 0 0; }
        .tab-btn.active { color:#0a4f6e; border-bottom-color:#1aa3c8; background:#f0f9fd; }
        .tab-btn:hover:not(.active) { background:#f6fafc; color:#3a5a6e; }
        .tab-pane { display:none; }
        .tab-pane.active { display:block; }

        /* Staff table */
        .avatar { width:38px; height:38px; border-radius:10px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); display:flex; align-items:center; justify-content:center; font-size:15px; color:white; font-weight:700; flex-shrink:0; }
        .avatar.reception { background:linear-gradient(135deg,#1e8449,#34a853); }
        .user-cell { display:flex; align-items:center; gap:10px; }
        .user-info .name  { font-size:14px; font-weight:700; color:#1e3a4a; }
        .user-info .uname { font-size:12px; color:#8aacbc; margin-top:1px; }

        .empty-state { text-align:center; padding:60px 20px; color:#9ab4c2; }
        .empty-state .es-icon { font-size:48px; margin-bottom:12px; }

        /* Modals */
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(10,40,60,.5); z-index:1000; align-items:center; justify-content:center; }
        .modal-overlay.show { display:flex; }
        .modal { background:white; border-radius:18px; padding:34px 36px 30px; width:100%; max-width:560px; box-shadow:0 20px 60px rgba(0,30,60,.3); animation:mIn .25s ease; max-height:90vh; overflow-y:auto; }
        @keyframes mIn { from{transform:translateY(-18px);opacity:0} to{transform:translateY(0);opacity:1} }
        .modal-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:22px; }
        .modal-header h2 { font-size:19px; font-weight:700; color:#0a4f6e; }
        .btn-close { background:none; border:none; font-size:20px; color:#8aacbc; cursor:pointer; padding:4px; transition:color .2s; }
        .btn-close:hover { color:#e04b3a; }

        .fg { margin-bottom:15px; }
        .fg label { display:block; font-size:12px; font-weight:700; color:#3a5a6e; margin-bottom:6px; text-transform:uppercase; letter-spacing:.4px; }
        .fg input, .fg select, .fg textarea { width:100%; padding:10px 13px; border:2px solid #dce8ee; border-radius:9px; font-size:14px; color:#1e3a4a; background:#f6fafc; outline:none; font-family:inherit; transition:border-color .25s; }
        .fg input:focus, .fg select:focus, .fg textarea:focus { border-color:#1aa3c8; background:white; }
        .fg textarea { resize:vertical; min-height:68px; }
        .fg .req { color:#e04b3a; }
        .form-row2 { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        .modal-alert { display:none; padding:9px 13px; border-radius:8px; font-size:13.5px; margin-bottom:14px; }
        .modal-alert-error { background:#fde8e8; color:#c0392b; border:1px solid #f5c6c6; }
        .modal-footer { display:flex; gap:10px; justify-content:flex-end; margin-top:20px; }
        .btn-mcancel { padding:10px 22px; border:2px solid #dce8ee; border-radius:9px; background:white; color:#3a5a6e; font-size:14px; font-weight:600; cursor:pointer; transition:border-color .2s; }
        .btn-mcancel:hover { border-color:#1aa3c8; }
        .btn-msave { padding:10px 24px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; border:none; border-radius:9px; font-size:14px; font-weight:700; cursor:pointer; box-shadow:0 4px 14px rgba(13,122,154,.3); transition:transform .2s; }
        .btn-msave:hover { transform:translateY(-1px); }
        .btn-msave:disabled { opacity:.7; cursor:not-allowed; transform:none; }

        .detail-row { display:flex; border-bottom:1px solid #eef4f7; padding:10px 0; }
        .detail-row:last-child { border-bottom:none; }
        .detail-label { width:150px; font-size:13px; font-weight:700; color:#7a95a8; flex-shrink:0; }
        .detail-value { font-size:13.5px; color:#1e3a4a; }

        .bill-modal-inner { max-width:480px; }
        .bill-header-box { text-align:center; padding:18px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); border-radius:10px; color:white; margin-bottom:20px; }
        .bill-header-box h3 { font-size:18px; font-weight:700; }
        .bill-header-box p  { font-size:13px; opacity:.85; margin-top:3px; }
        .bill-table { width:100%; border-collapse:collapse; margin-bottom:12px; }
        .bill-table td { padding:8px 4px; font-size:13.5px; border-bottom:1px solid #eef4f7; }
        .bill-table .lbl { color:#7a95a8; }
        .bill-table .val { text-align:right; font-weight:600; color:#1e3a4a; }
        .bill-total-row td { font-size:15px; font-weight:800; color:#0a4f6e; border-top:2px solid #0a4f6e; padding-top:12px; }
        .btn-print { padding:10px 24px; background:linear-gradient(135deg,#1e8449,#34a853); color:white; border:none; border-radius:9px; font-size:14px; font-weight:700; cursor:pointer; transition:transform .2s; }
        .btn-print:hover { transform:translateY(-1px); }
        .btn-email { padding:10px 18px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; border:none; border-radius:9px; font-size:14px; font-weight:700; cursor:pointer; transition:transform .2s; }
        .btn-email:hover { transform:translateY(-1px); opacity:.92; }
        .btn-email:disabled { opacity:.50; cursor:not-allowed; transform:none; }


        @media(max-width:760px) { .stats{grid-template-columns:1fr 1fr;} .form-row2{grid-template-columns:1fr;} }
        @media(max-width:480px) { .stats{grid-template-columns:1fr;} }
    </style>
</head>
<body>
<nav>
    <div class="nav-brand"><span>&#9875;</span> OceanView Resort</div>
    <div class="nav-right">
        <div class="nav-user">
            <strong><%= fullName != null ? fullName : "Manager" %></strong>
            Manager
        </div>
        <button class="btn-nav-primary" onclick="openAddModal()">&#43; New Reservation</button>
        <a href="<%= request.getContextPath() %>/api/logout" class="btn-nav">Logout</a>
    </div>
</nav>

<main>
    <div class="welcome">
        <h1>Manager Dashboard &#128101;</h1>
        <p>Overview of all reservations and staff management.</p>
    </div>

    <!-- Stats -->
    <div class="stats">
        <div class="stat-card">
            <div class="stat-icon" style="background:#e6f7fd;">&#128197;</div>
            <div class="stat-info"><div class="val" id="statTotal">–</div><div class="lbl">Total Reservations</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#e8f8ee;">&#9989;</div>
            <div class="stat-info"><div class="val" id="statActive">–</div><div class="lbl">Active</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fff3e0;">&#128710;</div>
            <div class="stat-info"><div class="val" id="statToday">–</div><div class="lbl">Check-ins Today</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fde8e8;">&#128711;</div>
            <div class="stat-info"><div class="val" id="statOut">–</div><div class="lbl">Check-outs Today</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#f3e8ff;">&#127968;</div>
            <div class="stat-info"><div class="val" id="statRoomsAvail">–</div><div class="lbl">Rooms Available</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fef9e7;">&#128101;</div>
            <div class="stat-info"><div class="val" id="statGuests">–</div><div class="lbl">Registered Guests</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#eee8ff;">&#128100;</div>
            <div class="stat-info"><div class="val" id="statStaff">–</div><div class="lbl">Staff Members</div></div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="section-title">&#9881; Quick Actions</div>
    <div class="action-cards">
        <div class="action-card" onclick="openAddModal()">
            <div class="ac-icon">&#128203;</div>
            <div class="ac-text"><h4>New Reservation</h4><p>Add a guest booking</p></div>
        </div>
        <a href="<%= request.getContextPath() %>/views/add-user.jsp" class="action-card">
            <div class="ac-icon" style="background:linear-gradient(135deg,#1e8449,#34a853);">&#128100;</div>
            <div class="ac-text"><h4>Register Reception</h4><p>Add a front-desk staff</p></div>
        </a>
        <div class="action-card" onclick="openAddRoomModal()">
            <div class="ac-icon" style="background:linear-gradient(135deg,#7b2ff7,#9b5de5);">&#127968;</div>
            <div class="ac-text"><h4>Add Room</h4><p>Register a new hotel room</p></div>
        </div>
        <div class="action-card" onclick="openRegisterGuestModal()">
            <div class="ac-icon" style="background:linear-gradient(135deg,#e67e22,#f39c12);">&#128101;</div>
            <div class="ac-text"><h4>Register Guest</h4><p>Add a guest profile</p></div>
        </div>
    </div>

    <!-- Tab Navigation -->
    <div class="tab-nav">
        <button class="tab-btn active" id="tab-btn-reservations" onclick="showTab('reservations')">&#128203; Reservations</button>
        <button class="tab-btn" id="tab-btn-rooms" onclick="showTab('rooms')">&#127968; Rooms</button>
        <button class="tab-btn" id="tab-btn-guests" onclick="showTab('guests')">&#128101; Guests</button>
        <button class="tab-btn" id="tab-btn-staff" onclick="showTab('staff')">&#128100; Staff</button>
        <button class="tab-btn" id="tab-btn-help"    onclick="showTab('help')">&#10067; Help</button>
        <button class="tab-btn" id="tab-btn-reports" onclick="showTab('reports')">&#128202; Reports</button>
    </div>

    <!-- RESERVATIONS TAB -->
    <div id="tab-reservations" class="tab-pane active">
        <div class="filter-bar">
            <button class="filter-btn active" id="filterAll"         onclick="applyFilter('all')">All</button>
            <button class="filter-btn"         id="filterActive"      onclick="applyFilter('active')">Active</button>
            <button class="filter-btn"         id="filterToday"       onclick="applyFilter('today')">Today's Check-ins</button>
            <button class="filter-btn"         id="filterTodayOut"    onclick="applyFilter('today_checkout')">Today's Check-outs</button>
            <button class="filter-btn"         id="filterCheckedIn"   onclick="applyFilter('checked_in')">Checked In</button>
            <button class="filter-btn"         id="filterCheckedOut"  onclick="applyFilter('checked_out')">Checked Out</button>
            <button class="filter-btn"         id="filterCancelled"   onclick="applyFilter('cancelled')">Cancelled</button>
        </div>

        <div id="alertBox" class="alert"></div>

        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#128203; All Reservations</div>
                <div class="search-box">
                    <span class="search-icon">&#128269;</span>
                    <input type="text" id="searchInput" placeholder="Search guest, room or res #…" oninput="renderTable()" />
                </div>
                <button class="btn-add-res" onclick="openAddModal()">&#43; New Reservation</button>
            </div>
            <div id="tableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading reservations…</p></div>
            </div>
        </div>
    </div>

    <!-- ROOMS TAB -->
    <div id="tab-rooms" class="tab-pane">
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#127968; Room Directory</div>
                <button class="btn-add-res" onclick="openAddRoomModal()">&#43; Add Room</button>
            </div>
            <div id="roomTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading rooms…</p></div>
            </div>
        </div>
    </div>

    <!-- GUESTS TAB -->
    <div id="tab-guests" class="tab-pane">
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#128100; Registered Guests</div>
                <div class="toolbar-actions">
                    <div class="search-box">
                        <span class="search-icon">&#128269;</span>
                        <input type="text" id="guestSearch" placeholder="Search name, mobile, NIC…" oninput="renderGuestTable()" />
                    </div>
                    <button class="btn-secondary" onclick="openRegisterGuestModal()">&#43; Register Guest</button>
                </div>
            </div>
            <div id="guestTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading guests…</p></div>
            </div>
        </div>
    </div>

    <!-- STAFF TAB -->
    <div id="tab-staff" class="tab-pane">
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#128100; Reception Staff</div>
                <div class="search-box">
                    <span class="search-icon">&#128269;</span>
                    <input type="text" id="staffSearchInput" placeholder="Search by name or username&hellip;" oninput="renderStaffTable()" />
                </div>
                <a href="<%= request.getContextPath() %>/views/add-user.jsp" class="btn-add-res" style="text-decoration:none;">&#43; Register Reception</a>
            </div>
            <div id="staffTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading staff&hellip;</p></div>
            </div>
        </div>
    </div>

    <!-- HELP TAB -->
    <div id="tab-help" class="tab-pane">
        <div class="table-card" style="padding:28px 32px;">
            <h2 style="margin:0 0 6px;color:#1a3a4a;font-size:1.5rem;">&#10067; Help &amp; Guide</h2>
            <p style="margin:0 0 24px;color:#6b8a9a;font-size:0.92rem;">Quick reference for using OceanView Resort Management System.</p>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:18px;">

                <div style="background:#eef7ff;border:1px solid #bcd9f0;border-radius:10px;padding:18px 20px;">
                    <h3 style="margin:0 0 10px;color:#0a4f6e;font-size:1rem;">&#128203; Reservations</h3>
                    <ul style="margin:0;padding-left:18px;line-height:2;color:#2d4a5e;font-size:0.88rem;">
                        <li>Click <strong>+ Add Reservation</strong> to create a new booking.</li>
                        <li>Use <strong>Today&#8217;s Check-ins</strong> filter to view arrivals due today.</li>
                        <li>Use <strong>Today&#8217;s Check-outs</strong> filter to view departures due today.</li>
                        <li>Click a row to expand reservation details.</li>
                        <li>Use <strong>Check In</strong> / <strong>Check Out</strong> buttons on confirmed reservations.</li>
                        <li>Click <strong>&#128084; Bill</strong> to send the bill receipt by email.</li>
                        <li>Cancelling a reservation automatically emails the guest.</li>
                    </ul>
                </div>

                <div style="background:#f0fff4;border:1px solid #b2dfc0;border-radius:10px;padding:18px 20px;">
                    <h3 style="margin:0 0 10px;color:#1a7a4e;font-size:1rem;">&#127968; Rooms</h3>
                    <ul style="margin:0;padding-left:18px;line-height:2;color:#2d4a5e;font-size:0.88rem;">
                        <li>View all rooms and their current status.</li>
                        <li>Filter by <strong>Available</strong>, <strong>Occupied</strong>, or <strong>Maintenance</strong>.</li>
                        <li>Use the search box to find a room by number or type.</li>
                        <li>Edit room details or change status via the action buttons.</li>
                    </ul>
                </div>

                <div style="background:#fffbee;border:1px solid #e8d89a;border-radius:10px;padding:18px 20px;">
                    <h3 style="margin:0 0 10px;color:#856404;font-size:1rem;">&#128101; Guests</h3>
                    <ul style="margin:0;padding-left:18px;line-height:2;color:#2d4a5e;font-size:0.88rem;">
                        <li>Search guests by name or NIC using the search box.</li>
                        <li>Click any row to view the full guest profile.</li>
                        <li>Click <strong>&#9998; Edit</strong> to update guest information.</li>
                        <li>Click <strong>&#10006; Delete</strong> to permanently remove a guest record.</li>
                        <li>Click <strong>&#128203; Reserve</strong> to make a new reservation for that guest.</li>
                        <li>Click <strong>+ Register Guest</strong> to add a new guest to the system.</li>
                    </ul>
                </div>

                <div style="background:#fff0f8;border:1px solid #e0b0d0;border-radius:10px;padding:18px 20px;">
                    <h3 style="margin:0 0 10px;color:#8b1a5a;font-size:1rem;">&#128100; Reception Staff</h3>
                    <ul style="margin:0;padding-left:18px;line-height:2;color:#2d4a5e;font-size:0.88rem;">
                        <li>View and manage reception staff accounts.</li>
                        <li>Search by name or username using the search box.</li>
                        <li>Click <strong>+ Register Reception</strong> to add a new reception user.</li>
                    </ul>
                </div>

                <div style="background:#f4f0ff;border:1px solid #c8b8f0;border-radius:10px;padding:18px 20px;">
                    <h3 style="margin:0 0 10px;color:#5b21b6;font-size:1rem;">&#128084; Bill &amp; Email</h3>
                    <ul style="margin:0;padding-left:18px;line-height:2;color:#2d4a5e;font-size:0.88rem;">
                        <li>After a guest checks out, click <strong>&#128084; Bill</strong> on the reservation row.</li>
                        <li>The system calculates the total and sends a detailed receipt to the guest&#8217;s email.</li>
                        <li>When cancelling, the system auto-emails the guest a cancellation notice.</li>
                        <li>Ensure the guest&#8217;s email is registered for email features to work.</li>
                    </ul>
                </div>

            </div>
        </div>
    </div>
    <!-- REPORTS TAB -->
    <div id="tab-reports" class="tab-pane">
        <div id="rptSummaryCards" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:16px;margin-bottom:22px;"></div>
        <div class="table-card" style="padding:18px 22px 14px;margin-bottom:18px;">
            <div style="display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end;">
                <div style="display:flex;flex-direction:column;gap:4px;">
                    <label style="font-size:12px;font-weight:600;color:#6b8a9a;">Status</label>
                    <select id="rptStatus" style="padding:8px 12px;border:1.5px solid #d0e8f0;border-radius:8px;font-size:13px;">
                        <option value="all">All Statuses</option>
                        <option value="active">Active</option>
                        <option value="checked_in">Checked In</option>
                        <option value="checked_out">Checked Out</option>
                        <option value="cancelled">Cancelled</option>
                    </select>
                </div>
                <div style="display:flex;flex-direction:column;gap:4px;">
                    <label style="font-size:12px;font-weight:600;color:#6b8a9a;">From Date</label>
                    <input type="date" id="rptFrom" style="padding:8px 12px;border:1.5px solid #d0e8f0;border-radius:8px;font-size:13px;" />
                </div>
                <div style="display:flex;flex-direction:column;gap:4px;">
                    <label style="font-size:12px;font-weight:600;color:#6b8a9a;">To Date</label>
                    <input type="date" id="rptTo" style="padding:8px 12px;border:1.5px solid #d0e8f0;border-radius:8px;font-size:13px;" />
                </div>
                <button onclick="loadReport()" style="padding:9px 20px;background:linear-gradient(135deg,#0a4f6e,#1aa3c8);color:white;border:none;border-radius:8px;font-weight:600;font-size:13px;cursor:pointer;">&#128269; Apply</button>
                <button onclick="resetReportFilters()" style="padding:9px 16px;background:#f0f6fa;color:#0a4f6e;border:1.5px solid #c0dce8;border-radius:8px;font-weight:600;font-size:13px;cursor:pointer;">Reset</button>
                <button onclick="printReport()" style="padding:9px 18px;background:linear-gradient(135deg,#2e7d32,#43a047);color:white;border:none;border-radius:8px;font-weight:600;font-size:13px;cursor:pointer;margin-left:8px;">&#128424; Print Report</button>
            </div>
        </div>
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#128203; Reservation History</div>
                <div class="search-box">
                    <span class="search-icon">&#128269;</span>
                    <input type="text" id="rptSearch" placeholder="Search guest, room or res #&hellip;" oninput="renderReportTable()" />
                </div>
            </div>
            <div id="rptTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Click the Reports tab to load data&hellip;</p></div>
            </div>
        </div>
    </div>
</main>

<!-- ── Add Reservation Modal ── -->
<div class="modal-overlay" id="addModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#128203; New Reservation</h2>
            <button class="btn-close no-print" onclick="closeAddModal()">&#10005;</button>
        </div>
        <div id="addAlertBox" class="modal-alert"></div>

        <!-- Step 1: Find registered guest -->
        <div id="guestLookupSection" style="background:#f0f7fb;border:1.5px solid #b8d4e8;border-radius:8px;padding:14px;margin-bottom:12px;">
            <div style="font-weight:700;color:#1a3c4e;font-size:12.5px;text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;">&#128101; Step 1 &mdash; Find Registered Guest <span class="req">*</span></div>
            <div style="display:flex;gap:8px;">
                <input type="text" id="resGuestSearch" placeholder="Name, mobile, email or NIC / passport…" style="flex:1;" onkeydown="if(event.key==='Enter')searchGuestForRes();" />
                <button class="btn-msave" style="white-space:nowrap;padding:0 16px;" onclick="searchGuestForRes()">&#128269; Find</button>
            </div>
            <div id="guestLookupResult" style="margin-top:8px;"></div>
        </div>

        <!-- Selected guest banner (shown after selection) -->
        <div id="selectedGuestBanner" style="display:none;background:#eaf6f0;border:1.5px solid #27ae60;border-radius:8px;padding:10px 14px;margin-bottom:10px;">
            <div style="display:flex;align-items:center;justify-content:space-between;gap:8px;">
                <div>
                    <div style="font-weight:700;color:#196f3d;font-size:14px;" id="selectedGuestInfo"></div>
                    <div style="color:#5d8a6f;font-size:12px;margin-top:2px;" id="selectedGuestSubInfo"></div>
                </div>
                <button onclick="clearGuestForRes()" style="background:none;border:1px solid #c0392b;color:#c0392b;cursor:pointer;font-size:12px;font-weight:600;padding:4px 10px;border-radius:5px;">Change Guest</button>
            </div>
        </div>

        <!-- Step 2: Reservation details -->
        <form id="addForm" novalidate>
            <input type="hidden" id="guestName" />
            <input type="hidden" id="contactNumber" />
            <input type="hidden" id="address" />
            <div class="form-row2">
                <div class="fg"><label>Check-in Date <span class="req">*</span></label><input type="date" id="checkIn" /></div>
                <div class="fg"><label>Check-out Date <span class="req">*</span></label><input type="date" id="checkOut" /></div>
            </div>
            <div class="fg">
                <label>Room <span class="req">*</span></label>
                <select id="roomType"><option value="">Loading available rooms…</option></select>
            </div>
        </form>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeAddModal()">Cancel</button>
            <button class="btn-msave" id="btnSaveRes" onclick="saveReservation()">Create Reservation</button>
        </div>
    </div>
</div>

<!-- ── Detail Modal ── -->
<div class="modal-overlay" id="detailModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#128196; Reservation Details</h2>
            <button class="btn-close no-print" onclick="closeDetailModal()">&#10005;</button>
        </div>
        <div id="detailContent"></div>
        <div class="modal-footer no-print">
            <button class="btn-mcancel" onclick="closeDetailModal()">Close</button>
            <button class="btn-msave" onclick="showBillFromDetail()">&#128203; View Bill</button>
        </div>
    </div>
</div>

<!-- ── Bill Modal ── -->
<div class="modal-overlay" id="billModal">
    <div class="modal bill-modal-inner">
        <div class="modal-header">
            <h2>&#129534; Guest Bill</h2>
            <button class="btn-close no-print" onclick="closeBillModal()">&#10005;</button>
        </div>
        <div id="billContent"></div>
        <div class="no-print" style="padding:10px 20px 2px;display:flex;align-items:center;gap:8px;border-top:1px solid #e6eff5;">
            <label style="font-size:13px;color:#7a95a8;white-space:nowrap;">Send to:</label>
            <input type="email" id="billEmailInput" placeholder="guest@email.com" style="flex:1;padding:8px 12px;border:1.5px solid #dce8ee;border-radius:8px;font-size:13px;color:#1e3a4a;outline:none;" />
        </div>
        <div class="modal-footer no-print">
            <button class="btn-mcancel" onclick="closeBillModal()">Close</button>
            <button class="btn-print" onclick="printBill()">&#128424; Print Bill</button>
            <button class="btn-email" id="btnEmailBill" onclick="emailBill()">&#128231; Email Bill</button>
        </div>
    </div>
</div>

<!-- ── Add Room Modal ── -->
<div class="modal-overlay" id="addRoomModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#127968; Add New Room</h2>
            <button class="btn-close" onclick="closeAddRoomModal()">&#10005;</button>
        </div>
        <div id="addRoomAlertBox" class="modal-alert"></div>
        <div class="form-row2">
            <div class="fg"><label>Room Number <span class="req">*</span></label><input type="text" id="arRoomNumber" placeholder="e.g. 101" /></div>
            <div class="fg"><label>Floor</label><input type="number" id="arFloor" min="1" max="20" value="1" /></div>
        </div>
        <div class="form-row2">
            <div class="fg">
                <label>Room Type <span class="req">*</span></label>
                <select id="arRoomType">
                    <option value="">-- Select --</option>
                    <option value="Standard Room">Standard Room</option>
                    <option value="Deluxe Room">Deluxe Room</option>
                    <option value="Suite">Suite</option>
                    <option value="Ocean View Suite">Ocean View Suite</option>
                </select>
            </div>
            <div class="fg"><label>Rate / Night ($) <span class="req">*</span></label><input type="number" id="arRate" min="1" step="0.01" placeholder="e.g. 120.00" /></div>
        </div>
        <div class="fg">
            <label>Status</label>
            <select id="arStatus">
                <option value="available">Available</option>
                <option value="occupied">Occupied</option>
                <option value="maintenance">Maintenance</option>
            </select>
        </div>
        <div class="fg"><label>Description</label><textarea id="arDescription" placeholder="Optional room description…"></textarea></div>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeAddRoomModal()">Cancel</button>
            <button class="btn-msave" id="btnSaveRoom" onclick="saveNewRoom()">Add Room</button>
        </div>
    </div>
</div>

<!-- ── Edit Room Modal ── -->
<div class="modal-overlay" id="editRoomModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#9999;&#65039; Edit Room</h2>
            <button class="btn-close" onclick="closeEditRoomModal()">&#10005;</button>
        </div>
        <div id="editRoomAlertBox" class="modal-alert"></div>
        <input type="hidden" id="erId" />
        <div class="form-row2">
            <div class="fg"><label>Room Number <span class="req">*</span></label><input type="text" id="erRoomNumber" /></div>
            <div class="fg"><label>Floor</label><input type="number" id="erFloor" min="1" max="20" /></div>
        </div>
        <div class="form-row2">
            <div class="fg">
                <label>Room Type <span class="req">*</span></label>
                <select id="erRoomType">
                    <option value="Standard Room">Standard Room</option>
                    <option value="Deluxe Room">Deluxe Room</option>
                    <option value="Suite">Suite</option>
                    <option value="Ocean View Suite">Ocean View Suite</option>
                </select>
            </div>
            <div class="fg"><label>Rate / Night ($) <span class="req">*</span></label><input type="number" id="erRate" min="1" step="0.01" /></div>
        </div>
        <div class="fg">
            <label>Status</label>
            <select id="erStatus">
                <option value="available">Available</option>
                <option value="occupied">Occupied</option>
                <option value="maintenance">Maintenance</option>
            </select>
        </div>
        <div class="fg"><label>Description</label><textarea id="erDescription"></textarea></div>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeEditRoomModal()">Cancel</button>
            <button class="btn-msave" id="btnUpdateRoom" onclick="updateRoom()">Save Changes</button>
        </div>
    </div>
</div>

<!-- ── Delete Room Confirm ── -->
<div class="modal-overlay" id="deleteRoomModal">
    <div class="modal" style="max-width:420px;">
        <div class="modal-header">
            <h2>&#128465;&#65039; Delete Room</h2>
            <button class="btn-close" onclick="closeDeleteRoomModal()">&#10005;</button>
        </div>
        <p style="color:#3a5a6e;font-size:14.5px;line-height:1.6;">Are you sure you want to delete <strong id="deleteRoomLabel"></strong>? This cannot be undone.</p>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeDeleteRoomModal()">Cancel</button>
            <button class="btn-msave" id="btnConfirmDeleteRoom" style="background:linear-gradient(135deg,#c0392b,#e04b3a);" onclick="confirmDeleteRoom()">Delete</button>
        </div>
    </div>
</div>

<!-- ── Register Guest Modal ── -->
<div class="modal-overlay" id="guestModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#128101; Register New Guest</h2>
            <button class="btn-close" onclick="closeRegisterGuestModal()">&#10005;</button>
        </div>
        <div id="guestAlertBox" class="modal-alert" style="display:none;"></div>
        <form id="guestForm" onsubmit="return false;">
            <div class="form-row2">
                <div class="fg"><label>Full Name <span class="req">*</span></label><input type="text" id="gFullName" placeholder="e.g. John Silva" /></div>
                <div class="fg"><label>Mobile Number <span class="req">*</span></label><input type="tel" id="gMobile" placeholder="e.g. 0771234567" /></div>
            </div>
            <div class="form-row2">
                <div class="fg"><label>Email Address</label><input type="email" id="gEmail" placeholder="guest@example.com" /></div>
                <div class="fg"><label>NIC / Passport No.</label><input type="text" id="gNic" placeholder="e.g. 199012345678" /></div>
            </div>
            <div class="fg"><label>Address</label><input type="text" id="gAddress" placeholder="Street, City" /></div>
            <div class="fg"><label>Notes</label><textarea id="gNotes" rows="3" placeholder="Any additional notes about the guest…"></textarea></div>
        </form>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeRegisterGuestModal()">Cancel</button>
            <button class="btn-msave" id="btnSaveGuest" onclick="saveGuest()">&#128101; Register Guest</button>
        </div>
    </div>
</div>

<!-- ── Guest Detail Modal ── -->
<div class="modal-overlay" id="guestDetailModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#128101; Guest Details</h2>
            <button class="btn-close" onclick="closeGuestDetailModal()">&#10005;</button>
        </div>
        <div id="guestDetailContent" style="padding:4px 0 8px;"></div>
        <div class="modal-footer">
            <button class="btn-msave" onclick="closeGuestDetailModal()">Close</button>
        </div>
    </div>
</div>

<!-- ── Edit Guest Modal ── -->
<div class="modal-overlay" id="editGuestModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#9998; Edit Guest</h2>
            <button class="btn-close" onclick="closeEditGuestModal()">&#10005;</button>
        </div>
        <div id="editGuestAlertBox" class="modal-alert" style="display:none;"></div>
        <form id="editGuestForm" onsubmit="return false;">
            <input type="hidden" id="editGuestId" />
            <div class="form-row2">
                <div class="fg"><label>Full Name <span class="req">*</span></label><input type="text" id="egFullName" /></div>
                <div class="fg"><label>Mobile Number <span class="req">*</span></label><input type="tel" id="egMobile" /></div>
            </div>
            <div class="form-row2">
                <div class="fg"><label>Email Address</label><input type="email" id="egEmail" /></div>
                <div class="fg"><label>NIC / Passport No.</label><input type="text" id="egNic" /></div>
            </div>
            <div class="fg"><label>Address</label><input type="text" id="egAddress" /></div>
            <div class="fg"><label>Notes</label><textarea id="egNotes" rows="3"></textarea></div>
        </form>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeEditGuestModal()">Cancel</button>
            <button class="btn-msave" id="btnSaveEditGuest" onclick="saveEditGuest()">&#10003; Save Changes</button>
        </div>
    </div>
</div>

<!-- ── Edit Staff Modal ── -->
<div class="modal-overlay" id="editStaffModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#9998; Edit Staff Account</h2>
            <button class="btn-close" onclick="closeEditStaffModal()">&#10005;</button>
        </div>
        <div id="editStaffAlertBox" class="modal-alert"></div>
        <input type="hidden" id="editStaffId" />
        <div class="form-row2">
            <div class="fg"><label>Full Name <span class="req">*</span></label><input type="text" id="editStaffFullName" placeholder="Full name" /></div>
            <div class="fg"><label>Email</label><input type="email" id="editStaffEmail" placeholder="Email address" /></div>
        </div>
        <div class="fg"><label>Username <span class="req">*</span></label><input type="text" id="editStaffUsername" placeholder="Username" autocomplete="off" /></div>
        <div class="fg">
            <label>New Password</label>
            <input type="password" id="editStaffPassword" placeholder="Leave blank to keep current" autocomplete="new-password" />
        </div>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeEditStaffModal()">Cancel</button>
            <button class="btn-msave" id="btnSaveStaffEdit" onclick="saveStaffEdit()">Save Changes</button>
        </div>
    </div>
</div>

<!-- ── Delete Staff Confirm ── -->
<div class="modal-overlay" id="deleteStaffModal">
    <div class="modal" style="max-width:420px;">
        <div class="modal-header">
            <h2 style="color:#c0392b;">&#128465; Delete Account</h2>
            <button class="btn-close" onclick="closeDeleteStaffModal()">&#10005;</button>
        </div>
        <p style="color:#3a5a6e;font-size:14.5px;line-height:1.6;">Permanently delete <strong id="deleteStaffTargetName"></strong>? This cannot be undone.</p>
        <input type="hidden" id="deleteStaffTargetId" />
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeDeleteStaffModal()">Cancel</button>
            <button class="btn-msave" id="btnConfirmDelStaff" style="background:linear-gradient(135deg,#c0392b,#e04b3a);" onclick="confirmDeleteStaff()">Yes, Delete</button>
        </div>
    </div>
</div>

<!-- ── Delete Guest Confirm Modal ── -->
<div class="modal-overlay" id="deleteGuestModal">
    <div class="modal" style="max-width:440px;">
        <div class="modal-header">
            <h2 style="color:#c0392b;">&#10006; Delete Guest</h2>
            <button class="btn-close" onclick="closeDeleteGuestModal()">&#10005;</button>
        </div>
        <p style="color:#3a5a6e;font-size:14.5px;line-height:1.6;">Are you sure you want to delete <strong id="deleteGuestLabel"></strong>? This action cannot be undone.</p>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeDeleteGuestModal()">Cancel</button>
            <button class="btn-msave" id="btnConfirmDeleteGuest" style="background:linear-gradient(135deg,#c0392b,#e04b3a);" onclick="confirmDeleteGuest()">Delete Guest</button>
        </div>
    </div>
</div>

<!-- ── Edit Reservation Modal ── -->
<div class="modal-overlay" id="editResModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#9998; Edit Reservation</h2>
            <button class="btn-close" onclick="closeEditResModal()">&#10005;</button>
        </div>
        <div id="editResAlertBox" class="modal-alert"></div>
        <input type="hidden" id="erResId" />
        <div class="form-row2" style="margin-bottom:8px;">
            <div class="fg">
                <label>Reservation #</label>
                <div id="erResNumber" style="padding:8px 0;font-weight:700;color:#0a4f6e;font-size:14px;"></div>
            </div>
            <div class="fg">
                <label>Guest</label>
                <div id="erGuestName" style="padding:8px 0;font-size:13.5px;color:#3a5a6e;"></div>
            </div>
        </div>
        <div class="form-row2">
            <div class="fg"><label>Check-in Date <span class="req">*</span></label><input type="date" id="erCheckIn" /></div>
            <div class="fg"><label>Check-out Date <span class="req">*</span></label><input type="date" id="erCheckOut" /></div>
        </div>
        <div class="fg">
            <label>Room <span class="req">*</span></label>
            <select id="erResRoom"><option value="">Loading rooms…</option></select>
            <input type="hidden" id="erOldRoomId" />
        </div>
        <div class="fg"><label>Address</label><input type="text" id="erAddress" placeholder="Street, City" /></div>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeEditResModal()">Close</button>
            <button class="btn-msave" id="btnCancelResFromEdit" style="background:linear-gradient(135deg,#c0392b,#e04b3a);" onclick="cancelFromEditModal()">&#10006; Cancel Reservation</button>
            <button class="btn-msave" id="btnSaveEditRes" onclick="saveEditReservation()">&#10003; Save Changes</button>
        </div>
    </div>
</div>

<!-- ── Cancel Reservation Confirm ── -->
<div class="modal-overlay" id="cancelResModal">
    <div class="modal" style="max-width:440px;">
        <div class="modal-header">
            <h2 style="color:#c0392b;">&#9888; Cancel Reservation</h2>
            <button class="btn-close" onclick="closeCancelResModal()">&#10005;</button>
        </div>
        <p style="color:#3a5a6e;font-size:14.5px;line-height:1.6;">Are you sure you want to cancel reservation <strong id="cancelResLabel"></strong>? This cannot be undone.</p>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeCancelResModal()">Keep Reservation</button>
            <button class="btn-msave" id="btnConfirmCancelRes" style="background:linear-gradient(135deg,#c0392b,#e04b3a);" onclick="confirmCancelReservation()">Cancel Reservation</button>
        </div>
    </div>
</div>

<script>
var allReservations  = [];
var activeFilter     = 'all';
var currentDetailId  = null;
var cancelResTarget  = null;
var apiBase          = '<%= request.getContextPath() %>/api/reservations';
var roomApiBase      = '<%= request.getContextPath() %>/api/rooms';
var guestApiBase     = '<%= request.getContextPath() %>/api/guests';
var reportApiBase    = '<%= request.getContextPath() %>/api/reports';
(function(){ var _d=new Date(); var _pad=function(n){return String(n).padStart(2,'0');}; window.today=_d.getFullYear()+'-'+_pad(_d.getMonth()+1)+'-'+_pad(_d.getDate()); })();
var today            = window.today;
var allRooms         = [];
var deleteRoomTarget = null;
var allGuests        = [];
var selectedGuest    = null;
var staffApiBase     = '<%= request.getContextPath() %>/api/users';
var allStaff         = [];
var allReportRows    = [];

// ── Load ────────────────────────────────────────────────────────────────────
function loadReservations() {
    $.ajax({
        url: apiBase, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success) { allReservations = res.reservations; updateStats(); renderTable(); }
            else showAlert('error', res.message);
        },
        error: function() { showAlert('error', 'Failed to load reservations.'); }
    });
}

function updateStats() {
    var total  = allReservations.length;
    var active = allReservations.filter(function(r){ return r.status === 'active'; }).length;
    var ci     = allReservations.filter(function(r){ return r.checkInDate  === today; }).length;
    var co     = allReservations.filter(function(r){ return r.checkOutDate === today; }).length;
    $('#statTotal').text(total); $('#statActive').text(active); $('#statToday').text(ci); $('#statOut').text(co);
}

// ── Rooms ─────────────────────────────────────────────────────────────────────
function loadRooms() {
    $.ajax({
        url: roomApiBase, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success) {
                allRooms = res.rooms;
                var avail = allRooms.filter(function(r){ return r.status === 'available'; }).length;
                $('#statRoomsAvail').text(avail);
                renderRoomTable();
            }
        },
        error: function() { $('#roomTableContainer').html('<div class="empty-state"><p>Failed to load rooms.</p></div>'); }
    });
}

function renderRoomTable() {
    if (!allRooms.length) {
        $('#roomTableContainer').html('<div class="empty-state"><div class="es-icon">&#127968;</div><p>No rooms yet. Add your first room.</p></div>');
        return;
    }
    var rows = allRooms.map(function(r, i) {
        var st = r.status === 'available' ? 'badge-available' : r.status === 'occupied' ? 'badge-occupied' : 'badge-maintenance';
        return '<tr>' +
            '<td>' + (i+1) + '</td>' +
            '<td><strong>' + esc(r.roomNumber) + '</strong></td>' +
            '<td>' + esc(r.roomType) + '</td>' +
            '<td>Floor ' + esc(r.floor) + '</td>' +
            '<td><strong>$' + esc(r.ratePerNight) + '</strong></td>' +
            '<td><span class="badge ' + st + '">' + esc(r.status) + '</span></td>' +
            '<td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + (esc(r.description) || '<span style="color:#aaa">—</span>') + '</td>' +
            '<td><button class="btn-edit" onclick="openEditRoomModal(' + r.id + ')">Edit</button>' +
                 '<button class="btn-delete" onclick="openDeleteRoomModal(' + r.id + ',\'' + esc(r.roomNumber) + '\')">Delete</button></td>' +
        '</tr>';
    }).join('');
    $('#roomTableContainer').html(
        '<table><thead><tr><th>#</th><th>Room #</th><th>Type</th><th>Floor</th><th>Rate/Night</th><th>Status</th><th>Description</th><th>Actions</th></tr></thead>' +
        '<tbody>' + rows + '</tbody></table>'
    );
}

function openAddRoomModal() {
    $('#arRoomNumber').val(''); $('#arFloor').val(1); $('#arRoomType').val(''); $('#arRate').val('');
    $('#arStatus').val('available'); $('#arDescription').val('');
    $('#addRoomAlertBox').hide();
    $('#addRoomModal').addClass('show');
}
function closeAddRoomModal() { $('#addRoomModal').removeClass('show'); }

function saveNewRoom() {
    var rn = $.trim($('#arRoomNumber').val()), rt = $('#arRoomType').val(), rate = $('#arRate').val();
    if (!rn || !rt || !rate) { showModalAlert('addRoomAlertBox', 'Please fill in all required fields.'); return; }
    var $btn = $('#btnSaveRoom');
    $btn.prop('disabled', true).text('Adding…');
    $.ajax({
        url: roomApiBase, type: 'POST', dataType: 'json',
        data: { action:'add', roomNumber:rn, roomType:rt, ratePerNight:rate,
                status:$('#arStatus').val(), floor:$('#arFloor').val(), description:$('#arDescription').val() },
        success: function(res) {
            if (res.success) { closeAddRoomModal(); showAlert('success', '✓ ' + res.message); loadRooms(); }
            else showModalAlert('addRoomAlertBox', res.message);
            $btn.prop('disabled', false).text('Add Room');
        },
        error: function() { showModalAlert('addRoomAlertBox', 'Failed to add room.'); $btn.prop('disabled', false).text('Add Room'); }
    });
}

function openEditRoomModal(id) {
    var r = allRooms.find(function(x){ return x.id === id; });
    if (!r) return;
    $('#erId').val(r.id); $('#erRoomNumber').val(r.roomNumber); $('#erRoomType').val(r.roomType);
    $('#erRate').val(r.ratePerNight); $('#erStatus').val(r.status);
    $('#erFloor').val(r.floor); $('#erDescription').val(r.description);
    $('#editRoomAlertBox').hide();
    $('#editRoomModal').addClass('show');
}
function closeEditRoomModal() { $('#editRoomModal').removeClass('show'); }

function updateRoom() {
    var rn = $.trim($('#erRoomNumber').val()), rt = $('#erRoomType').val(), rate = $('#erRate').val();
    if (!rn || !rt || !rate) { showModalAlert('editRoomAlertBox', 'Please fill in all required fields.'); return; }
    var $btn = $('#btnUpdateRoom');
    $btn.prop('disabled', true).text('Saving…');
    $.ajax({
        url: roomApiBase, type: 'POST', dataType: 'json',
        data: { action:'update', id:$('#erId').val(), roomNumber:rn, roomType:rt, ratePerNight:rate,
                status:$('#erStatus').val(), floor:$('#erFloor').val(), description:$('#erDescription').val() },
        success: function(res) {
            if (res.success) { closeEditRoomModal(); showAlert('success', '✓ ' + res.message); loadRooms(); }
            else showModalAlert('editRoomAlertBox', res.message);
            $btn.prop('disabled', false).text('Save Changes');
        },
        error: function() { showModalAlert('editRoomAlertBox', 'Failed to update.'); $btn.prop('disabled', false).text('Save Changes'); }
    });
}

function openDeleteRoomModal(id, number) {
    deleteRoomTarget = id;
    $('#deleteRoomLabel').text('Room ' + number);
    $('#deleteRoomModal').addClass('show');
}
function closeDeleteRoomModal() { $('#deleteRoomModal').removeClass('show'); deleteRoomTarget = null; }

function confirmDeleteRoom() {
    if (!deleteRoomTarget) return;
    var $btn = $('#btnConfirmDeleteRoom');
    $btn.prop('disabled', true).text('Deleting…');
    $.ajax({
        url: roomApiBase, type: 'POST', dataType: 'json',
        data: { action:'delete', id:deleteRoomTarget },
        success: function(res) {
            closeDeleteRoomModal();
            if (res.success) { showAlert('success', '✓ ' + res.message); loadRooms(); }
            else showAlert('error', res.message);
            $btn.prop('disabled', false).text('Delete');
        },
        error: function() { showAlert('error', 'Failed to delete.'); $btn.prop('disabled', false).text('Delete'); }
    });
}

// ── Tab switching ────────────────────────────────────────────────────────────
function showTab(name) {
    $('.tab-btn').removeClass('active');
    $('.tab-pane').removeClass('active');
    $('#tab-btn-' + name).addClass('active');
    $('#tab-' + name).addClass('active');
    if (name === 'reports') loadReport();
}

// ── Reports ──────────────────────────────────────────────────────────────────
function loadReport() {
    var status = $('#rptStatus').val();
    var from   = $('#rptFrom').val();
    var to     = $('#rptTo').val();
    var params = 'status=' + encodeURIComponent(status);
    if (from) params += '&from=' + from;
    if (to)   params += '&to='   + to;
    $('#rptTableContainer').html('<div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading&hellip;</p></div>');
    $.ajax({
        url: reportApiBase + '?' + params, type: 'GET', dataType: 'json',
        success: function(res) {
            if (!res.success) { showAlert('error', res.message || 'Failed to load report.'); return; }
            renderReportSummary(res.stats);
            allReportRows = res.history;
            renderReportTable();
        },
        error: function() { showAlert('error', 'Failed to load report data.'); }
    });
}
function resetReportFilters() {
    $('#rptStatus').val('all'); $('#rptFrom').val(''); $('#rptTo').val(''); $('#rptSearch').val('');
    loadReport();
}
function renderReportSummary(s) {
    var fmt = function(n) { return '$' + parseFloat(n||0).toLocaleString('en-US',{minimumFractionDigits:2,maximumFractionDigits:2}); };
    var cards = [
        { label:'Total Reservations', value:s.total,            bg:'#eef7ff', border:'#bcd9f0', color:'#0a4f6e' },
        { label:'Active',             value:s.active,           bg:'#eafaf1', border:'#a9dfbf', color:'#1a7a4e' },
        { label:'Checked In',         value:s.checkedIn,        bg:'#fff9e6', border:'#f5d97a', color:'#856404' },
        { label:'Checked Out',        value:s.checkedOut,       bg:'#f0f0ff', border:'#c0b8f0', color:'#3b28b0' },
        { label:'Cancelled',          value:s.cancelled,        bg:'#fff0f0', border:'#f0b8b8', color:'#b01a1a' },
        { label:'Total Revenue',      value:fmt(s.totalRevenue), bg:'#eaffee', border:'#90d4a0', color:'#145a32' }
    ];
    var html = '';
    cards.forEach(function(c) {
        html += '<div style="background:'+c.bg+';border:1.5px solid '+c.border+';border-radius:12px;padding:16px 18px;">'+
                '<div style="font-size:12px;font-weight:600;color:'+c.color+';text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;">'+c.label+'</div>'+
                '<div style="font-size:24px;font-weight:800;color:'+c.color+';">'+c.value+'</div></div>';
    });
    $('#rptSummaryCards').html(html);
}
function renderReportTable() {
    var q = ($('#rptSearch').val() || '').toLowerCase();
    var rows = allReportRows.filter(function(r) {
        return !q || r.guestName.toLowerCase().includes(q) ||
               r.reservationNumber.toLowerCase().includes(q) ||
               r.roomType.toLowerCase().includes(q) ||
               (r.contactNumber||'').toLowerCase().includes(q);
    });
    if (!rows.length) { $('#rptTableContainer').html('<div class="empty-state"><div class="es-icon">&#128202;</div><p>No records found.</p></div>'); return; }
    var statusBadge = function(s) {
        var map={active:'#1a7a4e:#d4edda',checked_in:'#856404:#fff3cd',checked_out:'#3b28b0:#e8e4ff',cancelled:'#b01a1a:#fde8e8'};
        var v=map[s]||'#555:#eee'; var p=v.split(':');
        return '<span style="background:'+p[1]+';color:'+p[0]+';padding:3px 10px;border-radius:20px;font-size:11.5px;font-weight:700;">'+esc(s.replace('_',' '))+'</span>';
    };
    var html='<table><thead><tr><th>#</th><th>Res No.</th><th>Guest</th><th>Contact</th>'+
        '<th>Room Type</th><th>Check-In</th><th>Check-Out</th><th>Nights</th><th>Total (USD)</th><th>Status</th><th>Created By</th></tr></thead><tbody>';
    rows.forEach(function(r,i){
        html+='<tr><td>'+(i+1)+'</td><td><strong>'+esc(r.reservationNumber)+'</strong></td><td>'+esc(r.guestName)+'</td><td>'+esc(r.contactNumber)+'</td>'+
              '<td>'+esc(r.roomType)+'</td><td>'+esc(r.checkInDate)+'</td><td>'+esc(r.checkOutDate)+'</td>'+
              '<td style="text-align:center;">'+r.nights+'</td><td style="font-weight:700;">$'+parseFloat(r.totalAmount||0).toFixed(2)+'</td>'+
              '<td>'+statusBadge(r.status)+'</td><td style="font-size:12px;color:#6b8a9a;">'+esc(r.createdByName)+'</td></tr>';
    });
    html+='</tbody></table>';
    $('#rptTableContainer').html(html);
}
function printReport() {
    if (!allReportRows.length) { showAlert('error','No report data loaded. Select filters and click Apply first.'); return; }
    var q = ($('#rptSearch').val() || '').toLowerCase();
    var rows = allReportRows.filter(function(r) {
        return !q || r.guestName.toLowerCase().includes(q) ||
               r.reservationNumber.toLowerCase().includes(q) ||
               r.roomType.toLowerCase().includes(q) ||
               (r.contactNumber||'').toLowerCase().includes(q);
    });
    var statusFilter = $('#rptStatus').val();
    var fromDate     = $('#rptFrom').val();
    var toDate       = $('#rptTo').val();
    var filterInfo   = [];
    if (statusFilter && statusFilter !== 'all') filterInfo.push('Status: ' + statusFilter.replace('_',' '));
    if (fromDate) filterInfo.push('From: ' + fromDate);
    if (toDate)   filterInfo.push('To: ' + toDate);
    var fmt = function(n) { return '$' + parseFloat(n||0).toLocaleString('en-US',{minimumFractionDigits:2,maximumFractionDigits:2}); };
    var totalRevenue = rows.reduce(function(s,r){ return s + (r.status !== 'cancelled' ? parseFloat(r.totalAmount||0) : 0); }, 0);
    var counts = { total: rows.length, active:0, checked_in:0, checked_out:0, cancelled:0 };
    rows.forEach(function(r){ if (counts[r.status] !== undefined) counts[r.status]++; });
    var statsHtml = [
        ['Total Reservations', counts.total,           '#0a4f6e'],
        ['Active',             counts.active,          '#1a7a4e'],
        ['Checked In',         counts.checked_in,      '#856404'],
        ['Checked Out',        counts.checked_out,     '#3b28b0'],
        ['Cancelled',          counts.cancelled,       '#b01a1a'],
        ['Total Revenue',      fmt(totalRevenue),      '#145a32']
    ].map(function(c){
        return '<div style="border:1px solid #ddd;border-radius:8px;padding:10px 14px;text-align:center;">'+
               '<div style="font-size:10px;font-weight:700;text-transform:uppercase;color:#6b8a9a;margin-bottom:4px;">'+c[0]+'</div>'+
               '<div style="font-size:20px;font-weight:800;color:'+c[2]+';">'+c[1]+'</div></div>';
    }).join('');
    var tableRows = rows.map(function(r,i){
        return '<tr style="'+(i%2===0?'background:#f8fbfd;':'')+'">'+
            '<td>'+(i+1)+'</td><td><strong>'+esc(r.reservationNumber)+'</strong></td>'+
            '<td>'+esc(r.guestName)+'</td><td>'+esc(r.contactNumber)+'</td>'+
            '<td>'+esc(r.roomType)+'</td><td>'+esc(r.checkInDate)+'</td><td>'+esc(r.checkOutDate)+'</td>'+
            '<td style="text-align:center;">'+r.nights+'</td>'+
            '<td style="font-weight:700;">$'+parseFloat(r.totalAmount||0).toFixed(2)+'</td>'+
            '<td>'+esc(r.status.replace('_',' '))+'</td>'+
            '<td>'+esc(r.createdByName)+'</td></tr>';
    }).join('');
    var html = '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>OceanView Resort - Report</title>'+
        '<style>body{font-family:Arial,sans-serif;padding:24px;color:#222;font-size:13px;}'+
        'h1{color:#0a4f6e;margin:0 0 2px;font-size:22px;}'+
        '.meta{font-size:11px;color:#6b8a9a;margin-bottom:18px;}'+
        '.stats{display:grid;grid-template-columns:repeat(6,1fr);gap:10px;margin-bottom:20px;}'+
        'table{width:100%;border-collapse:collapse;font-size:11px;}'+
        'th{background:#0a4f6e;color:#fff;padding:7px 9px;text-align:left;}'+
        'td{padding:5px 9px;border-bottom:1px solid #e8f0f5;}'+
        '@media print{body{padding:10px;}}'+
        '</style></head><body>'+
        '<h1>&#9875; OceanView Resort</h1>'+
        '<div class="meta">Reservation Report &nbsp;&bull;&nbsp; Generated: '+new Date().toLocaleString()+(filterInfo.length?' &nbsp;&bull;&nbsp;'+filterInfo.join(' &nbsp;&bull;&nbsp; '):'')+'</div>'+
        '<div class="stats">'+statsHtml+'</div>'+
        '<table><thead><tr><th>#</th><th>Res No.</th><th>Guest</th><th>Contact</th>'+
        '<th>Room Type</th><th>Check-In</th><th>Check-Out</th><th>Nights</th>'+
        '<th>Total (USD)</th><th>Status</th><th>Created By</th></tr></thead>'+
        '<tbody>'+tableRows+'</tbody></table></body></html>';
    var w = window.open('','_blank','width=1100,height=700');
    w.document.write(html);
    w.document.close();
    w.focus();
    setTimeout(function(){ w.print(); }, 400);
}

// ── Filter ──────────────────────────────────────────────────────────────────
function applyFilter(f) {
    activeFilter = f;
    $('.filter-btn').removeClass('active');
    if (f === 'all')            $('#filterAll').addClass('active');
    if (f === 'active')         $('#filterActive').addClass('active');
    if (f === 'today')          $('#filterToday').addClass('active');
    if (f === 'today_checkout') $('#filterTodayOut').addClass('active');
    if (f === 'checked_in')     $('#filterCheckedIn').addClass('active');
    if (f === 'checked_out')    $('#filterCheckedOut').addClass('active');
    if (f === 'cancelled')      $('#filterCancelled').addClass('active');
    renderTable();
}

// ── Render table ─────────────────────────────────────────────────────────────
function renderTable() {
    var q = ($('#searchInput').val() || '').toLowerCase();
    var list = allReservations.filter(function(r) {
        var matchFilter = activeFilter === 'all' ||
            (activeFilter === 'active'         && r.status === 'active') ||
            (activeFilter === 'today'          && r.checkInDate === today) ||
            (activeFilter === 'today_checkout' && r.checkOutDate === today) ||
            (activeFilter === 'checked_in'     && r.status === 'checked_in') ||
            (activeFilter === 'checked_out'    && r.status === 'checked_out') ||
            (activeFilter === 'cancelled'      && r.status === 'cancelled');
        var matchSearch = !q || r.guestName.toLowerCase().includes(q) ||
            r.reservationNumber.toLowerCase().includes(q) || r.roomType.toLowerCase().includes(q);
        return matchFilter && matchSearch;
    });

    if (!list.length) {
        $('#tableContainer').html('<div class="empty-state"><div class="es-icon">&#128100;</div><p>No reservations found.</p></div>');
        return;
    }
    var rows = list.map(function(r, i) {
        var badge = r.status === 'active' ? 'badge-active' : r.status === 'checked_in' ? 'badge-checkin' : r.status === 'checked_out' ? 'badge-checkedout' : 'badge-cancelled';
        return '<tr onclick="openDetailModal(' + r.id + ')">' +
            '<td>' + (i+1) + '</td>' +
            '<td><strong>' + esc(r.reservationNumber) + '</strong></td>' +
            '<td>' + esc(r.guestName) + '</td>' +
            '<td>' + esc(r.roomType) + '</td>' +
            '<td>' + esc(r.checkInDate) + '</td>' +
            '<td>' + esc(r.checkOutDate) + '</td>' +
            '<td><span class="badge ' + badge + '">' + esc(r.status) + '</span></td>' +
            '<td><strong>$' + esc(r.totalAmount) + '</strong></td>' +
            '<td>' + esc(r.createdByName) + '</td>' +
            '<td onclick="event.stopPropagation()">' +
              '<button class="btn-view" onclick="openDetailModal(' + r.id + ')">Details</button>' +
              '<button class="btn-bill" onclick="openBillModal(' + r.id + ')">Bill</button>' +
              (r.status === 'active' ? '<button class="btn-checkin" onclick="doCheckIn(' + r.id + ')">&#10003; Check In</button>' : '') +
              (r.status === 'checked_in' || (r.status === 'active' && activeFilter === 'today_checkout') ? '<button class="btn-checkout" onclick="doCheckOut(' + r.id + ')">&#10004; Check Out</button>' : '') +
              (r.status === 'active' ?
                '<button class="btn-edit" onclick="openEditResModal(' + r.id + ')">&#9998; Edit</button>'
                : '') +
            '</td>' +
        '</tr>';
    }).join('');
    $('#tableContainer').html(
        '<table><thead><tr><th>#</th><th>Res #</th><th>Guest</th><th>Room</th><th>Check-in</th><th>Check-out</th><th>Status</th><th>Total</th><th>Created By</th><th>Actions</th></tr></thead>' +
        '<tbody>' + rows + '</tbody></table>'
    );
}

// ── Add Reservation ──────────────────────────────────────────────────────────
function openAddModal() {
    $('#addForm')[0].reset();
    $('#checkIn').val(today);
    $('#addAlertBox').hide();
    selectedGuest = null;
    window._guestSearchResults = [];
    $('#resGuestSearch').val('');
    $('#guestLookupResult').html('');
    $('#selectedGuestBanner').hide();
    $('#guestLookupSection').show();
    var $sel = $('#roomType');
    $sel.html('<option value="">Loading available rooms…</option>').prop('disabled', true);
    $.ajax({
        url: roomApiBase + '?status=available', type: 'GET', dataType: 'json',
        success: function(res) {
            $sel.prop('disabled', false);
            if (res.success && res.rooms.length) {
                var opts = '<option value="">-- Select a room --</option>';
                res.rooms.forEach(function(r) {
                    opts += '<option value="' + r.id + '" data-roomtype="' + esc(r.roomType) + '">' +
                            'Room ' + esc(r.roomNumber) + ' – ' + esc(r.roomType) +
                            ' ($' + esc(r.ratePerNight) + '/night)</option>';
                });
                $sel.html(opts);
            } else {
                $sel.html('<option value="">No rooms available</option>');
            }
        },
        error: function() {
            $sel.prop('disabled', false)
                .html('<option value="">Failed to load rooms</option>');
        }
    });
    $('#addModal').addClass('show');
}
function closeAddModal() { $('#addModal').removeClass('show'); }

function buildGuestResultCard(g) {
    return '<div style="background:#eaf6f0;border:1.5px solid #27ae60;border-radius:7px;padding:10px 12px;margin-bottom:6px;">' +
        '<div style="display:flex;align-items:center;justify-content:space-between;gap:8px;">' +
        '<div>' +
        '<div style="font-weight:700;color:#196f3d;font-size:13.5px;">&#10003; ' + esc(g.fullName) + '</div>' +
        '<div style="color:#5d8a6f;font-size:12px;margin-top:2px;">' + esc(g.mobileNumber) +
        (g.email     ? ' &nbsp;|&nbsp; ' + esc(g.email)     : '') +
        (g.nicNumber ? ' &nbsp;|&nbsp; NIC: ' + esc(g.nicNumber) : '') +
        '</div></div>' +
        '<button class="btn-msave" style="padding:5px 14px;font-size:12.5px;white-space:nowrap;" onclick="selectGuestForRes(' + g.id + ')">&#10003; Select</button>' +
        '</div></div>';
}

function searchGuestForRes() {
    var q = $.trim($('#resGuestSearch').val());
    if (!q) {
        $('#guestLookupResult').html('<span style="color:#c0392b;font-size:13px;">Please enter a name, mobile, email or NIC / passport number.</span>');
        return;
    }
    $('#guestLookupResult').html('<span style="color:#8aacbc;font-size:13px;">Searching…</span>');
    $.ajax({
        url: guestApiBase + '?keyword=' + encodeURIComponent(q), type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success && res.guests && res.guests.length) {
                window._guestSearchResults = res.guests;
                if (res.guests.length === 1) {
                    $('#guestLookupResult').html(buildGuestResultCard(res.guests[0]));
                } else {
                    var html = '<div style="font-size:12px;color:#5d7a8a;margin-bottom:6px;">' + res.guests.length + ' guests found &mdash; select one:</div>' +
                               '<div style="max-height:210px;overflow-y:auto;">';
                    res.guests.forEach(function(g) { html += buildGuestResultCard(g); });
                    html += '</div>';
                    $('#guestLookupResult').html(html);
                }
            } else {
                window._guestSearchResults = [];
                $('#guestLookupResult').html(
                    '<div style="background:#fdf2f0;border:1.5px solid #e74c3c;border-radius:7px;padding:10px 12px;">' +
                    '<div style="color:#c0392b;font-weight:600;font-size:13px;">&#10006; No registered guest found.</div>' +
                    '<div style="color:#888;font-size:12px;margin-top:3px;">Please register the guest first before creating a reservation.</div>' +
                    '</div>'
                );
            }
        },
        error: function() {
            $('#guestLookupResult').html('<span style="color:#c0392b;font-size:13px;">Server error. Please try again.</span>');
        }
    });
}

function selectGuestForRes(id) {
    var list = window._guestSearchResults || [];
    var g = null;
    for (var i = 0; i < list.length; i++) { if (list[i].id === id) { g = list[i]; break; } }
    if (!g) { for (var j = 0; j < allGuests.length; j++) { if (allGuests[j].id === id) { g = allGuests[j]; break; } } }
    if (!g) return;
    selectedGuest = g;
    $('#guestLookupSection').hide();
    $('#selectedGuestInfo').text('✓ ' + g.fullName);
    $('#selectedGuestSubInfo').text(g.mobileNumber +
        (g.email    ? '  |  ' + g.email    : '') +
        (g.nicNumber ? '  |  NIC: ' + g.nicNumber : ''));
    $('#selectedGuestBanner').show();
    $('#addAlertBox').hide();
}

function clearGuestForRes() {
    selectedGuest = null;
    window._guestSearchResults = [];
    $('#resGuestSearch').val('');
    $('#guestLookupResult').html('');
    $('#selectedGuestBanner').hide();
    $('#guestLookupSection').show();
}

function saveReservation() {
    if (!selectedGuest) {
        showModalAlert('addAlertBox', 'Please find and select a registered guest first.'); return;
    }
    var roomId   = $('#roomType').val();
    var roomType = $('#roomType option:selected').data('roomtype');
    var checkIn  = $('#checkIn').val();
    var checkOut = $('#checkOut').val();

    $('#addAlertBox').hide();
    if (!roomId || !checkIn || !checkOut) {
        showModalAlert('addAlertBox', 'Please select a room and set check-in / check-out dates.'); return;
    }
    if (checkOut <= checkIn) {
        showModalAlert('addAlertBox', 'Check-out must be after check-in.'); return;
    }

    var $btn = $('#btnSaveRes');
    $btn.prop('disabled', true).text('Creating…');

    $.ajax({
        url: apiBase, type: 'POST',
        data: { action: 'add',
                guestName:     selectedGuest.fullName,
                contactNumber: selectedGuest.mobileNumber,
                roomType:      roomType,
                roomId:        roomId,
                address:       selectedGuest.address || '',
                checkIn:       checkIn,
                checkOut:      checkOut },
        dataType: 'json',
        success: function(res) {
            if (res.success) {
                closeAddModal();
                showAlert('success', '✓ ' + res.message);
                loadReservations();
                loadRooms();
                if (res.bill) setTimeout(function(){ showBillData(res.bill); }, 400);
            } else {
                showModalAlert('addAlertBox', res.message);
            }
            $btn.prop('disabled', false).text('Create Reservation');
        },
        error: function(xhr) {
            var msg = 'Failed to create reservation.';
            try { msg = JSON.parse(xhr.responseText).message || msg; } catch(e) {}
            showModalAlert('addAlertBox', msg);
            $btn.prop('disabled', false).text('Create Reservation');
        }
    });
}

// ── Details Modal ────────────────────────────────────────────────────────────
function openDetailModal(id) {
    currentDetailId = id;
    $.ajax({
        url: apiBase + '?id=' + id, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success) { renderDetailContent(res.reservation); $('#detailModal').addClass('show'); }
            else showAlert('error', res.message);
        }
    });
}
function closeDetailModal() { $('#detailModal').removeClass('show'); }

function renderDetailContent(r) {
    var badgeCls = r.status === 'active' ? 'badge-active' : r.status === 'checked_in' ? 'badge-checkin' : r.status === 'checked_out' ? 'badge-checkedout' : 'badge-cancelled';
    var actionBtns = r.status === 'active' ? '<button class="btn-checkin" onclick="closeDetailModal();doCheckIn(' + r.id + ')">&#10003; Check In</button>' :
                     r.status === 'checked_in' ? '<button class="btn-checkout" onclick="closeDetailModal();doCheckOut(' + r.id + ')">&#10004; Check Out</button>' : '';
    var html = '<div>' +
        row('Reservation #', '<strong>' + esc(r.reservationNumber) + '</strong>') +
        row('Status', '<span class="badge ' + badgeCls + '">' + esc(r.status) + '</span>') +
        row('Guest Name',   esc(r.guestName)) +
        row('Contact',      esc(r.contactNumber)) +
        row('Address',      esc(r.address) || '—') +
        row('Room Type',    esc(r.roomType)) +
        row('Check-in',     esc(r.checkInDate)) +
        row('Check-out',    esc(r.checkOutDate)) +
        row('Total Amount', '<strong>$' + esc(r.totalAmount) + '</strong>') +
        row('Created By',   esc(r.createdByName)) +
        row('Created At',   esc(r.createdAt)) +
        (actionBtns ? '<div style="margin-top:16px;text-align:right;">' + actionBtns + '</div>' : '') +
    '</div>';
    $('#detailContent').html(html);
}

function showBillFromDetail() {
    closeDetailModal();
    if (currentDetailId) openBillModal(currentDetailId);
}
function doCheckIn(id) {
    $.ajax({ url: apiBase, type: 'POST', dataType: 'json', data: { action: 'checkin', id: id },
        success: function(res) {
            if (res.success) { showAlert('success', '\u2713 ' + res.message); loadReservations(); }
            else showAlert('error', res.message);
        }
    });
}
function doCheckOut(id) {
    $.ajax({ url: apiBase, type: 'POST', dataType: 'json', data: { action: 'checkout', id: id },
        success: function(res) {
            if (res.success) { showAlert('success', '\u2713 ' + res.message); loadReservations(); loadRooms(); }
            else showAlert('error', res.message);
        }
    });
}
function cancelFromEditModal() {
    var id = parseInt($('#erResId').val());
    closeEditResModal();
    openCancelResModal(id);
}

// ── Bill Modal ───────────────────────────────────────────────────────────────
var currentBillResId = null;
function openBillModal(id) {
    currentBillResId = id;
    $.ajax({
        url: apiBase + '?action=bill&id=' + id, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success) showBillData(res.bill);
            else showAlert('error', res.message);
        }
    });
}
function closeBillModal() { $('#billModal').removeClass('show'); }
function emailBill() {
    if (!currentBillResId) return;
    var email = $('#billEmailInput').val().trim();
    if (!email) { showAlert('error', 'Please enter an email address.'); return; }
    var $btn = $('#btnEmailBill').prop('disabled', true).text('Sending\u2026');
    $.ajax({
        url: apiBase, type: 'POST', dataType: 'json',
        data: { action: 'sendbill', id: currentBillResId, email: email },
        success: function(res) {
            $btn.prop('disabled', false).html('&#128231; Email Bill');
            if (res.success) showAlert('success', '\u2714 ' + res.message);
            else             showAlert('error',   res.message);
        },
        error: function(xhr) {
            $btn.prop('disabled', false).html('&#128231; Email Bill');
            var msg = (xhr.responseJSON && xhr.responseJSON.message) ? xhr.responseJSON.message : xhr.responseText || 'Failed to send email.';
            showAlert('error', msg);
        }
    });
}

function printBill() {
    var content = document.getElementById('billContent').innerHTML;
    var w = window.open('', '_blank', 'width=800,height=900');
    w.document.write(
        '<!DOCTYPE html><html><head><title>OceanView Resort – Bill</title>' +
        '<style>' +
        'body{font-family:Arial,sans-serif;padding:48px 56px;color:#1e3a4a;}' +
        '.bill-header-box{text-align:center;padding:28px;background:linear-gradient(135deg,#0a4f6e,#1aa3c8);border-radius:12px;color:white;margin-bottom:32px;}' +
        '.bill-header-box h3{font-size:26px;font-weight:700;margin:0;}' +
        '.bill-header-box p{font-size:16px;opacity:.85;margin-top:6px;}' +
        '.bill-table{width:100%;border-collapse:collapse;margin-bottom:16px;}' +
        '.bill-table td{padding:12px 8px;font-size:16px;border-bottom:1px solid #eef4f7;}' +
        '.bill-table .lbl{color:#7a95a8;}' +
        '.bill-table .val{text-align:right;font-weight:600;color:#1e3a4a;}' +
        '.bill-total-row td{font-size:19px;font-weight:800;color:#0a4f6e;border-top:2px solid #0a4f6e;padding-top:16px;}' +
        '</style></head><body>' +
        content +
        '</body></html>'
    );
    w.document.close();
    w.focus();
    w.print();
    w.close();
}

function showBillData(b) {
    var html =
        '<div class="bill-header-box">' +
        '<h3>&#9875; OceanView Resort</h3>' +
        '<p>Guest Bill &amp; Invoice</p>' +
        '</div>' +
        '<table class="bill-table">' +
        '<tr><td class="lbl">Reservation No.</td><td class="val">' + esc(b.reservationNumber) + '</td></tr>' +
        '<tr><td class="lbl">Guest Name</td><td class="val">' + esc(b.guestName) + '</td></tr>' +
        '<tr><td class="lbl">Address</td><td class="val">' + (esc(b.address) || '—') + '</td></tr>' +
        '<tr><td class="lbl">Contact</td><td class="val">' + esc(b.contactNumber) + '</td></tr>' +
        '<tr><td class="lbl">Room Type</td><td class="val">' + esc(b.roomType) + '</td></tr>' +
        '<tr><td class="lbl">Check-in</td><td class="val">' + esc(b.checkInDate) + '</td></tr>' +
        '<tr><td class="lbl">Check-out</td><td class="val">' + esc(b.checkOutDate) + '</td></tr>' +
        '<tr><td class="lbl">Nights</td><td class="val">' + b.nights + '</td></tr>' +
        '<tr><td class="lbl">Rate / Night</td><td class="val">$' + b.ratePerNight + '</td></tr>' +
        '<tr><td class="lbl">Subtotal</td><td class="val">$' + b.subtotal + '</td></tr>' +
        '<tr><td class="lbl">Tax (' + b.taxRate + ')</td><td class="val">$' + b.tax + '</td></tr>' +
        '<tr class="bill-total-row"><td class="lbl">TOTAL</td><td class="val">$' + b.total + '</td></tr>' +
        '</table>';
    $('#billEmailInput').val(b.guestEmail || '');
    $('#billContent').html(html);
    $('#billModal').addClass('show');
}

// ── Helpers ────────────────────────────────────────────────────────────────
function row(label, value) {
    return '<div class="detail-row"><div class="detail-label">' + label + '</div><div class="detail-value">' + value + '</div></div>';
}
function esc(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function showAlert(type, msg) {
    $('#alertBox').removeClass('alert-success alert-error')
        .addClass(type === 'success' ? 'alert-success' : 'alert-error')
        .html(msg).stop(true).fadeIn(200);
    if (type === 'success') setTimeout(function(){ $('#alertBox').fadeOut(400); }, 4000);
}
function showModalAlert(id, msg) {
    $('#' + id).removeClass('modal-alert-error').addClass('modal-alert modal-alert-error').html(msg).show();
}
// ── Guest functions ───────────────────────────────────────────────────────
function loadGuests() {
    $.ajax({
        url: guestApiBase, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success) { allGuests = res.guests; renderGuestTable(); $('#statGuests').text(allGuests.length); }
        },
        error: function() { $('#guestTableContainer').html('<div class="empty-state"><p>Failed to load guests.</p></div>'); }
    });
}

function getInitials(name) {
    if (!name) return '?';
    var parts = name.trim().split(/\s+/);
    return (parts[0][0] + (parts.length > 1 ? parts[parts.length-1][0] : '')).toUpperCase();
}

function loadStaff() {
    $.ajax({
        url: staffApiBase, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success && res.users) {
                allStaff = res.users.filter(function(u){ return u.role === 'reception'; });
                $('#statStaff').text(allStaff.length);
                renderStaffTable();
            }
        },
        error: function() { $('#staffTableContainer').html('<div class="empty-state"><p>Failed to load staff.</p></div>'); }
    });
}

function renderStaffTable() {
    var kw = ($('#staffSearchInput').val() || '').toLowerCase();
    var list = allStaff.filter(function(u) {
        return !kw || u.fullName.toLowerCase().includes(kw) || u.username.toLowerCase().includes(kw) || (u.email && u.email.toLowerCase().includes(kw));
    });
    if (!list.length) {
        $('#staffTableContainer').html('<div class="empty-state"><div class="es-icon">&#128100;</div><p>No reception staff found.</p></div>');
        return;
    }
    var rows = list.map(function(u, i) {
        var initials = getInitials(u.fullName);
        return '<tr>' +
            '<td>' + (i+1) + '</td>' +
            '<td><div class="user-cell"><div class="avatar reception">' + esc(initials) + '</div>' +
                 '<div class="user-info"><div class="name">' + esc(u.fullName) + '</div><div class="uname">@' + esc(u.username) + '</div></div></div></td>' +
            '<td>' + (u.email ? esc(u.email) : '<span style="color:#b0c8d4">—</span>') + '</td>' +
            '<td><span class="badge badge-reception">Reception</span></td>' +
            '<td><button class="btn-edit" onclick="openEditStaffModal(' + u.id + ')">Edit</button>' +
                 '<button class="btn-delete" onclick="openDeleteStaffModal(' + u.id + ',\'' + esc(u.fullName) + '\')">Delete</button></td>' +
            '</tr>';
    }).join('');
    $('#staffTableContainer').html(
        '<table><thead><tr><th>#</th><th>Staff Member</th><th>Email</th><th>Role</th><th>Actions</th></tr></thead><tbody>' + rows + '</tbody></table>'
    );
}

function openEditStaffModal(id) {
    var u = allStaff.find(function(x){ return x.id === id; });
    if (!u) return;
    $('#editStaffId').val(u.id); $('#editStaffFullName').val(u.fullName); $('#editStaffEmail').val(u.email || '');
    $('#editStaffUsername').val(u.username); $('#editStaffPassword').val('');
    $('#editStaffAlertBox').hide(); $('#editStaffModal').addClass('show');
}
function closeEditStaffModal() { $('#editStaffModal').removeClass('show'); $('#editStaffAlertBox').hide(); }

function saveStaffEdit() {
    var id = $('#editStaffId').val(), fullName = $.trim($('#editStaffFullName').val()), username = $.trim($('#editStaffUsername').val());
    var email = $.trim($('#editStaffEmail').val()), password = $.trim($('#editStaffPassword').val());
    $('#editStaffAlertBox').hide();
    if (!fullName || !username) { showModalAlert('editStaffAlertBox', 'Full name and username are required.'); return; }
    if (password && password.length < 6) { showModalAlert('editStaffAlertBox', 'Password must be at least 6 characters.'); return; }
    var $btn = $('#btnSaveStaffEdit').prop('disabled', true).text('Saving…');
    $.ajax({
        url: staffApiBase, type: 'POST', dataType: 'json',
        data: { action:'update', id:id, fullName:fullName, email:email, username:username, role:'reception', password:password },
        success: function(res) {
            if (res.success) { closeEditStaffModal(); showAlert('success', '\u2713 ' + res.message); loadStaff(); }
            else showModalAlert('editStaffAlertBox', res.message);
            $btn.prop('disabled', false).text('Save Changes');
        },
        error: function() { showModalAlert('editStaffAlertBox', 'Failed to update.'); $btn.prop('disabled', false).text('Save Changes'); }
    });
}

function openDeleteStaffModal(id, name) { $('#deleteStaffTargetId').val(id); $('#deleteStaffTargetName').text(name); $('#deleteStaffModal').addClass('show'); }
function closeDeleteStaffModal() { $('#deleteStaffModal').removeClass('show'); }

function confirmDeleteStaff() {
    var id = $('#deleteStaffTargetId').val();
    var $btn = $('#btnConfirmDelStaff').prop('disabled', true).text('Deleting…');
    $.ajax({
        url: staffApiBase, type: 'POST', dataType: 'json',
        data: { action:'delete', id:id },
        success: function(res) {
            closeDeleteStaffModal();
            if (res.success) { showAlert('success', '\u2713 ' + res.message); loadStaff(); } else showAlert('error', res.message);
            $btn.prop('disabled', false).text('Yes, Delete');
        },
        error: function() { showAlert('error', 'Failed to delete.'); $btn.prop('disabled', false).text('Yes, Delete'); closeDeleteStaffModal(); }
    });
}

function renderGuestTable() {
    var q = ($('#guestSearch').val() || '').toLowerCase();
    var list = allGuests.filter(function(g) {
        return !q || (g.fullName||'').toLowerCase().includes(q) ||
               (g.mobileNumber||'').includes(q) ||
               (g.nicNumber||'').toLowerCase().includes(q) ||
               (g.email||'').toLowerCase().includes(q);
    });
    if (!list.length) {
        $('#guestTableContainer').html('<div class="empty-state"><div class="es-icon">&#128100;</div><p>No guests found.</p></div>');
        return;
    }
    var rows = list.map(function(g, i) {
        return '<tr onclick="openGuestDetailModal(' + g.id + ')">' +
            '<td>' + (i+1) + '</td>' +
            '<td><strong>' + esc(g.fullName) + '</strong></td>' +
            '<td>' + esc(g.mobileNumber) + '</td>' +
            '<td>' + esc(g.email||'\u2014') + '</td>' +
            '<td>' + esc(g.nicNumber||'\u2014') + '</td>' +
            '<td>' + esc(g.address||'\u2014') + '</td>' +
            '<td style="color:#8aacbc;font-size:12px;">' + esc((g.createdAt||'').substring(0,10)) + '</td>' +
            '<td onclick="event.stopPropagation()">' +
              '<button class="btn-guest-view" onclick="openGuestDetailModal(' + g.id + ')">Profile</button>' +
              '<button class="btn-reserve" onclick="newResForGuest(' + g.id + ')">&#128203; Reserve</button>' +
              '<button class="btn-guest-edit" onclick="openEditGuestModal(' + g.id + ')">&#9998; Edit</button>' +
              '<button class="btn-guest-delete" onclick="openDeleteGuestModal(' + g.id + ',\'' + esc(g.fullName) + '\')" >&#10006; Delete</button>' +
            '</td></tr>';
    }).join('');
    $('#guestTableContainer').html(
        '<table><thead><tr><th>#</th><th>Full Name</th><th>Mobile</th>' +
        '<th>Email</th><th>NIC / Passport</th><th>Address</th><th>Registered</th><th>Actions</th>' +
        '</tr></thead><tbody>' + rows + '</tbody></table>'
    );
}

function openRegisterGuestModal() {
    $('#guestForm')[0].reset();
    $('#guestAlertBox').hide();
    $('#guestModal').addClass('show');
}
function closeRegisterGuestModal() { $('#guestModal').removeClass('show'); }
function newResForGuest(id) {
    openAddModal();
    setTimeout(function() { selectGuestForRes(id); }, 100);
}

function saveGuest() {
    var fullName     = $.trim($('#gFullName').val());
    var mobileNumber = $.trim($('#gMobile').val());
    var email        = $.trim($('#gEmail').val());
    var address      = $.trim($('#gAddress').val());
    var nicNumber    = $.trim($('#gNic').val());
    var notes        = $.trim($('#gNotes').val());

    if (!fullName || !mobileNumber) {
        $('#guestAlertBox').show().text('Full name and mobile number are required.');
        return;
    }
    var $btn = $('#btnSaveGuest').prop('disabled', true).text('Saving…');
    $.ajax({
        url: guestApiBase, type: 'POST', dataType: 'json',
        data: { action:'register', fullName:fullName, mobileNumber:mobileNumber,
                email:email, address:address, nicNumber:nicNumber, notes:notes },
        success: function(res) {
            $btn.prop('disabled', false).text('Register Guest');
            if (res.success) {
                closeRegisterGuestModal();
                showAlert('success', res.message);
                loadGuests();
            } else {
                $('#guestAlertBox').show().text(res.message);
            }
        },
        error: function() {
            $btn.prop('disabled', false).text('Register Guest');
            $('#guestAlertBox').show().text('Server error. Please try again.');
        }
    });
}

function openGuestDetailModal(id) {
    $('#guestDetailContent').html('<div style="padding:20px;text-align:center;color:#8aacbc;">Loading…</div>');
    $('#guestDetailModal').addClass('show');
    $.ajax({
        url: guestApiBase + '?id=' + id, type: 'GET', dataType: 'json',
        success: function(res) {
            if (!res.success) { $('#guestDetailContent').html('<p style="color:#c0392b;">' + esc(res.message) + '</p>'); return; }
            var g = res.guest;
            var reservations = res.reservations || [];

            var html = '<table style="width:100%;border-collapse:collapse;margin-bottom:18px;">' +
                gdetailRow('Full Name',      g.fullName) +
                gdetailRow('Mobile Number',  g.mobileNumber) +
                gdetailRow('Email',          g.email      || '—') +
                gdetailRow('NIC / Passport', g.nicNumber  || '—') +
                gdetailRow('Address',        g.address    || '—') +
                gdetailRow('Notes',          g.notes      || '—') +
                gdetailRow('Registered On',  (g.createdAt || '').substring(0,10)) +
                '</table>';

            // Reservation history
            html += '<div style="font-weight:700;color:#1a3c4e;font-size:12.5px;text-transform:uppercase;' +
                    'letter-spacing:.5px;margin-bottom:8px;border-top:2px solid #dceef7;padding-top:14px;">' +
                    '&#128203; Reservation History (' + reservations.length + ')</div>';
            if (!reservations.length) {
                html += '<div style="color:#aaa;font-size:13px;padding:8px 0;">No reservations found for this guest.</div>';
            } else {
                html += '<table style="width:100%;border-collapse:collapse;font-size:13px;">' +
                    '<thead><tr>' +
                    '<th style="text-align:left;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Res #</th>' +
                    '<th style="text-align:left;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Room</th>' +
                    '<th style="text-align:left;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Check-in</th>' +
                    '<th style="text-align:left;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Check-out</th>' +
                    '<th style="text-align:right;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Total ($)</th>' +
                    '<th style="text-align:center;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Status</th>' +
                    '</tr></thead><tbody>';
                reservations.forEach(function(r) {
                    var badgeCss = r.status === 'active'
                        ? 'background:#d5f5e3;color:#1e8449;'
                        : 'background:#f0f0f0;color:#777;';
                    html += '<tr>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;color:#2980b9;font-weight:600;">' + esc(r.reservationNumber) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;">' + esc(r.roomType) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;">' + esc(r.checkInDate) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;">' + esc(r.checkOutDate) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;text-align:right;font-weight:600;">$' + esc(r.totalAmount) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;text-align:center;"><span style="' + badgeCss + 'border-radius:4px;padding:2px 8px;font-size:11.5px;font-weight:600;">' + esc(r.status) + '</span></td>' +
                        '</tr>';
                });
                html += '</tbody></table>';
            }
            $('#guestDetailContent').html(html);
        },
        error: function() {
            $('#guestDetailContent').html('<p style="color:#c0392b;">Failed to load guest details.</p>');
        }
    });
}
function closeGuestDetailModal() { $('#guestDetailModal').removeClass('show'); }

function openEditGuestModal(id) {
    var g = allGuests.find(function(x){ return x.id === id; });
    if (!g) return;
    $('#editGuestForm')[0].reset();
    $('#editGuestAlertBox').hide();
    $('#editGuestId').val(g.id);
    $('#egFullName').val(g.fullName);
    $('#egMobile').val(g.mobileNumber);
    $('#egEmail').val(g.email || '');
    $('#egNic').val(g.nicNumber || '');
    $('#egAddress').val(g.address || '');
    $('#egNotes').val(g.notes || '');
    $('#editGuestModal').addClass('show');
}
function closeEditGuestModal() { $('#editGuestModal').removeClass('show'); }

function saveEditGuest() {
    var id           = parseInt($('#editGuestId').val());
    var fullName     = $.trim($('#egFullName').val());
    var mobileNumber = $.trim($('#egMobile').val());
    var email        = $.trim($('#egEmail').val());
    var address      = $.trim($('#egAddress').val());
    var nicNumber    = $.trim($('#egNic').val());
    var notes        = $.trim($('#egNotes').val());

    if (!fullName || !mobileNumber) {
        $('#editGuestAlertBox').show().text('Full name and mobile number are required.');
        return;
    }
    var $btn = $('#btnSaveEditGuest').prop('disabled', true).text('Saving…');
    $.ajax({
        url: guestApiBase, type: 'POST', dataType: 'json',
        data: { action:'update', id:id, fullName:fullName, mobileNumber:mobileNumber,
                email:email, address:address, nicNumber:nicNumber, notes:notes },
        success: function(res) {
            $btn.prop('disabled', false).text('\u2713 Save Changes');
            if (res.success) {
                closeEditGuestModal();
                showAlert('success', '\u2713 ' + res.message);
                loadGuests();
            } else {
                $('#editGuestAlertBox').show().text(res.message);
            }
        },
        error: function() {
            $btn.prop('disabled', false).text('\u2713 Save Changes');
            $('#editGuestAlertBox').show().text('Server error. Please try again.');
        }
    });
}

var deleteGuestTargetId = null;
function openDeleteGuestModal(id, name) {
    deleteGuestTargetId = id;
    $('#deleteGuestLabel').text(name);
    $('#deleteGuestModal').addClass('show');
}
function closeDeleteGuestModal() { $('#deleteGuestModal').removeClass('show'); deleteGuestTargetId = null; }

function confirmDeleteGuest() {
    if (!deleteGuestTargetId) return;
    var $btn = $('#btnConfirmDeleteGuest').prop('disabled', true).text('Deleting…');
    $.ajax({
        url: guestApiBase, type: 'POST', dataType: 'json',
        data: { action:'delete', id: deleteGuestTargetId },
        success: function(res) {
            $btn.prop('disabled', false).text('Delete Guest');
            if (res.success) {
                closeDeleteGuestModal();
                showAlert('success', '\u2713 ' + res.message);
                loadGuests();
            } else {
                closeDeleteGuestModal();
                showAlert('error', res.message);
            }
        },
        error: function() {
            $btn.prop('disabled', false).text('Delete Guest');
            closeDeleteGuestModal();
            showAlert('error', 'Failed to delete guest.');
        }
    });
}
function gdetailRow(label, value) {
    return '<tr>' +
        '<td style="padding:9px 8px;color:#6b8fa5;font-size:13px;font-weight:600;width:38%;border-bottom:1px solid #e8f0f5;">' + label + '</td>' +
        '<td style="padding:9px 8px;color:#1a3c4e;font-size:13.5px;border-bottom:1px solid #e8f0f5;">' + esc(String(value)) + '</td>' +
        '</tr>';
}

// ── Edit Reservation ─────────────────────────────────────────────────────────
function openEditResModal(id) {
    var r = allReservations.find(function(x){ return x.id === id; });
    if (!r) return;
    $('#erResId').val(r.id);
    $('#erResNumber').text(r.reservationNumber);
    $('#erGuestName').text(r.guestName + '  —  ' + r.contactNumber);
    $('#erCheckIn').val(r.checkInDate);
    $('#erCheckOut').val(r.checkOutDate);
    $('#erAddress').val(r.address || '');
    $('#editResAlertBox').hide();

    // Find the currently assigned room using the stored room_id
    var currentRoom = allRooms.find(function(rm){
        return rm.id === r.roomId;
    });
    var oldRoomId = currentRoom ? currentRoom.id : '';
    $('#erOldRoomId').val(oldRoomId);

    // Populate room dropdown: available rooms + current room (always selectable)
    var $sel = $('#erResRoom').html('<option value="">Loading rooms…</option>').prop('disabled', true);
    $.ajax({
        url: roomApiBase + '?status=available', type: 'GET', dataType: 'json',
        success: function(res) {
            $sel.prop('disabled', false);
            var opts = '';
            // Prepend current room so it is always an option
            if (currentRoom) {
                opts += '<option value="' + currentRoom.id + '" data-roomtype="' + esc(currentRoom.roomType) + '" selected>' +
                        'Room ' + esc(currentRoom.roomNumber) + ' – ' + esc(currentRoom.roomType) +
                        ' ($' + esc(currentRoom.ratePerNight) + '/night) [current]</option>';
            }
            if (res.success && res.rooms) {
                res.rooms.forEach(function(rm) {
                    // Skip if it's the same room as current (already added)
                    if (currentRoom && rm.id === currentRoom.id) return;
                    opts += '<option value="' + rm.id + '" data-roomtype="' + esc(rm.roomType) + '">' +
                            'Room ' + esc(rm.roomNumber) + ' – ' + esc(rm.roomType) +
                            ' ($' + esc(rm.ratePerNight) + '/night)</option>';
                });
            }
            if (!opts) opts = '<option value="">No rooms available</option>';
            $sel.html(opts);
        },
        error: function() {
            $sel.prop('disabled', false).html('<option value="">Failed to load rooms</option>');
        }
    });

    $('#editResModal').addClass('show');
}
function closeEditResModal() { $('#editResModal').removeClass('show'); }

function saveEditReservation() {
    var id        = parseInt($('#erResId').val());
    var checkIn   = $('#erCheckIn').val();
    var checkOut  = $('#erCheckOut').val();
    var address   = $.trim($('#erAddress').val());
    var newRoomId = $('#erResRoom').val();
    var roomType  = $('#erResRoom option:selected').data('roomtype') || '';
    var oldRoomId = $('#erOldRoomId').val();

    $('#editResAlertBox').hide();
    if (!checkIn || !checkOut) { showModalAlert('editResAlertBox', 'Check-in and check-out dates are required.'); return; }
    if (checkOut <= checkIn)   { showModalAlert('editResAlertBox', 'Check-out must be after check-in.'); return; }
    if (!newRoomId)            { showModalAlert('editResAlertBox', 'Please select a room.'); return; }

    var $btn = $('#btnSaveEditRes').prop('disabled', true).text('Saving…');
    $.ajax({
        url: apiBase, type: 'POST',
        data: { action: 'update', id: id, checkIn: checkIn, checkOut: checkOut,
                address: address, roomType: roomType,
                newRoomId: newRoomId, oldRoomId: oldRoomId },
        dataType: 'json',
        success: function(res) {
            if (res.success) {
                closeEditResModal();
                showAlert('success', '\u2713 ' + res.message);
                loadReservations();
                loadRooms();
            } else {
                showModalAlert('editResAlertBox', res.message);
            }
            $btn.prop('disabled', false).text('\u2713 Save Changes');
        },
        error: function(xhr) {
            var msg = 'Failed to update reservation.';
            try { msg = JSON.parse(xhr.responseText).message || msg; } catch(e) {}
            showModalAlert('editResAlertBox', msg);
            $btn.prop('disabled', false).text('\u2713 Save Changes');
        }
    });
}

// ── Cancel Reservation ─────────────────────────────────────────────────────
function openCancelResModal(id) {
    var r = allReservations.find(function(x){ return x.id === id; });
    if (!r) return;
    cancelResTarget = id;
    $('#cancelResLabel').text(r.reservationNumber + ' — ' + r.guestName);
    $('#cancelResModal').addClass('show');
}
function closeCancelResModal() { $('#cancelResModal').removeClass('show'); cancelResTarget = null; }

function confirmCancelReservation() {
    if (!cancelResTarget) return;
    var $btn = $('#btnConfirmCancelRes').prop('disabled', true).text('Cancelling…');
    $.ajax({
        url: apiBase, type: 'POST',
        data: { action: 'cancel', id: cancelResTarget },
        dataType: 'json',
        success: function(res) {
            closeCancelResModal();
            if (res.success) {
                showAlert('success', '\u2713 ' + res.message);
                loadReservations();
                loadRooms();
            } else {
                showAlert('error', res.message);
            }
            $btn.prop('disabled', false).text('Cancel Reservation');
        },
        error: function() {
            showAlert('error', 'Failed to cancel reservation.');
            $btn.prop('disabled', false).text('Cancel Reservation');
            closeCancelResModal();
        }
    });
}

$('.modal-overlay').on('click', function(e) {
    if ($(e.target).hasClass('modal-overlay')) {
        closeAddModal(); closeDetailModal(); closeBillModal();
        closeRegisterGuestModal(); closeGuestDetailModal();
        closeEditGuestModal(); closeDeleteGuestModal();
        closeEditResModal(); closeCancelResModal();
        closeEditStaffModal(); closeDeleteStaffModal();
    }
});

$(document).ready(function() {
    loadReservations(); loadRooms(); loadGuests(); loadStaff();
    // Poll every 60 s so scheduler-driven status changes (checked_out, available) appear automatically
    setInterval(function() { loadReservations(); loadRooms(); }, 60000);
});
</script>
</body>
</html>
