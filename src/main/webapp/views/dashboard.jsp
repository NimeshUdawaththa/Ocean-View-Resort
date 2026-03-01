<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    if (!"admin".equals(session.getAttribute("role"))) {
        String r = (String) session.getAttribute("role");
        if ("manager".equals(r)) response.sendRedirect(request.getContextPath() + "/views/manager-dashboard.jsp");
        else                     response.sendRedirect(request.getContextPath() + "/views/reception-dashboard.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("fullName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | OceanView Resort</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif; background:#f0f6fa; min-height:100vh; color:#1e3a4a; }

        /* Navbar */
        nav { background:linear-gradient(135deg,#0a4f6e,#1aa3c8); padding:0 32px; height:64px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 2px 12px rgba(0,50,80,.25); position:sticky; top:0; z-index:900; }
        .nav-brand { display:flex; align-items:center; gap:12px; color:white; font-size:20px; font-weight:700; }
        .nav-brand span { font-size:26px; }
        .nav-right { display:flex; align-items:center; gap:14px; }
        .nav-user { color:rgba(255,255,255,.9); font-size:14px; text-align:right; }
        .nav-user strong { display:block; font-size:15px; color:white; }
        .btn-nav { background:rgba(255,255,255,.15); color:white; border:1px solid rgba(255,255,255,.3); padding:8px 18px; border-radius:8px; cursor:pointer; font-size:13.5px; font-weight:600; text-decoration:none; transition:background .2s; }
        .btn-nav:hover { background:rgba(255,255,255,.28); }
        .btn-nav-primary { background:white; color:#0a4f6e; border:none; padding:9px 20px; border-radius:8px; cursor:pointer; font-size:13.5px; font-weight:700; transition:all .2s; }
        .btn-nav-primary:hover { background:#e6f7fd; }

        /* Layout */
        main { max-width:1200px; margin:36px auto; padding:0 24px; }
        .welcome { margin-bottom:28px; }
        .welcome h1 { font-size:26px; font-weight:800; color:#0a4f6e; }
        .welcome p  { margin-top:4px; color:#7a95a8; font-size:14.5px; }

        /* Stats */
        .stats { display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:16px; margin-bottom:28px; }
        .stat-card { background:white; border-radius:14px; padding:20px; display:flex; align-items:center; gap:14px; box-shadow:0 3px 14px rgba(0,50,80,.07); }
        .stat-icon { width:46px; height:46px; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0; }
        .stat-info .val { font-size:26px; font-weight:800; color:#0a4f6e; line-height:1; }
        .stat-info .lbl { font-size:12px; color:#7a95a8; font-weight:600; margin-top:4px; }

        /* Quick Actions */
        .section-title { font-size:15px; font-weight:700; color:#3a5a6e; text-transform:uppercase; letter-spacing:.6px; margin-bottom:14px; }
        .action-cards { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; margin-bottom:30px; }
        .action-card { background:white; border-radius:14px; padding:20px; display:flex; align-items:center; gap:14px; box-shadow:0 3px 14px rgba(0,50,80,.07); cursor:pointer; transition:transform .2s,box-shadow .2s; text-decoration:none; color:inherit; }
        .action-card:hover { transform:translateY(-3px); box-shadow:0 8px 24px rgba(0,50,80,.14); }
        .ac-icon { width:44px; height:44px; border-radius:11px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0; }
        .ac-text h4 { font-size:14px; font-weight:700; color:#1e3a4a; }
        .ac-text p  { font-size:12px; color:#8aacbc; margin-top:2px; }

        /* Tabs */
        .tab-nav { display:flex; gap:4px; margin-bottom:22px; background:white; padding:6px; border-radius:14px; box-shadow:0 3px 14px rgba(0,50,80,.07); width:fit-content; flex-wrap:wrap; }
        .tab-btn { padding:9px 22px; border:none; border-radius:10px; background:transparent; font-size:13.5px; font-weight:600; color:#5a8099; cursor:pointer; transition:all .2s; }
        .tab-btn.active { background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; box-shadow:0 3px 10px rgba(13,122,154,.3); }
        .tab-btn:hover:not(.active) { background:#f0f6fa; color:#0a4f6e; }
        .tab-pane { display:none; }
        .tab-pane.active { display:block; }

        /* Tables */
        .table-card { background:white; border-radius:16px; box-shadow:0 4px 20px rgba(0,50,80,.09); overflow:hidden; margin-bottom:24px; }
        .table-toolbar { padding:18px 24px; border-bottom:1px solid #e8f0f4; display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap; }
        .toolbar-title { font-size:16px; font-weight:700; color:#0a4f6e; }
        .search-box { position:relative; flex:1; min-width:200px; max-width:320px; }
        .search-box input { width:100%; padding:9px 14px 9px 38px; border:2px solid #dce8ee; border-radius:8px; font-size:14px; color:#1e3a4a; background:#f6fafc; outline:none; transition:border-color .25s; }
        .search-box input:focus { border-color:#1aa3c8; background:#fff; }
        .search-icon { position:absolute; left:11px; top:50%; transform:translateY(-50%); color:#8aacbc; }
        table { width:100%; border-collapse:collapse; }
        thead th { padding:12px 16px; text-align:left; font-size:12px; font-weight:700; color:#7a95a8; text-transform:uppercase; letter-spacing:.5px; background:#f6fafc; border-bottom:2px solid #e8f0f4; white-space:nowrap; }
        tbody tr { border-bottom:1px solid #eef4f7; transition:background .15s; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:#f0f9ff; }
        tbody td { padding:12px 16px; font-size:13.5px; vertical-align:middle; }

        /* Badges */
        .badge { display:inline-block; padding:4px 11px; border-radius:20px; font-size:12px; font-weight:700; }
        .badge-active     { background:#e8f8ee; color:#1b6b33; }
        .badge-checkedout { background:#e6f7fd; color:#0a4f6e; }
        .badge-cancelled  { background:#fde8e8; color:#c0392b; }
        .badge-available  { background:#e8f8ee; color:#1b6b33; }
        .badge-occupied   { background:#fde8e8; color:#c0392b; }
        .badge-maintenance{ background:#fff3e0; color:#b7690a; }
        .badge-manager    { background:#e6f7fd; color:#0a4f6e; }
        .badge-reception  { background:#e8f8ee; color:#1b6b33; }

        /* Buttons */
        .btn-add-res { padding:9px 18px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; border:none; border-radius:9px; font-size:13px; font-weight:700; cursor:pointer; box-shadow:0 3px 10px rgba(13,122,154,.28); transition:transform .2s; }
        .btn-add-res:hover { transform:translateY(-1px); }
        .btn-view   { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e6f7fd; color:#0a4f6e; transition:all .2s; margin-right:4px; }
        .btn-view:hover   { background:#1aa3c8; color:white; }
        .btn-bill   { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e8f8ee; color:#1b6b33; transition:all .2s; margin-right:4px; }
        .btn-bill:hover   { background:#34a853; color:white; }
        .btn-edit   { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fff3e0; color:#b7690a; transition:all .2s; margin-right:4px; }
        .btn-edit:hover   { background:#f59f00; color:white; }
        .btn-delete { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fde8e8; color:#c0392b; transition:all .2s; }
        .btn-delete:hover { background:#e04b3a; color:white; }

        /* Filter bar */
        .filter-bar { display:flex; gap:8px; margin-bottom:18px; flex-wrap:wrap; }
        .filter-btn { padding:7px 18px; border-radius:20px; border:2px solid #dce8ee; background:white; font-size:13px; font-weight:600; color:#3a5a6e; cursor:pointer; transition:all .2s; }
        .filter-btn:hover, .filter-btn.active { border-color:#1aa3c8; background:#e6f7fd; color:#0a4f6e; }

        /* Alert */
        .alert { display:none; padding:12px 16px; border-radius:10px; font-size:14px; font-weight:500; margin-bottom:18px; }
        .alert-success { background:#e8f8f0; color:#1e8449; border:1px solid #b8e8ce; }
        .alert-error   { background:#fde8e8; color:#c0392b; border:1px solid #f5c6c6; }

        /* Empty state */
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
        .fg input,.fg select,.fg textarea { width:100%; padding:10px 13px; border:2px solid #dce8ee; border-radius:9px; font-size:14px; color:#1e3a4a; background:#f6fafc; outline:none; font-family:inherit; transition:border-color .25s; }
        .fg input:focus,.fg select:focus,.fg textarea:focus { border-color:#1aa3c8; background:white; }
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
        .section-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; flex-wrap:wrap; gap:10px; }
        /* Staff */
        .avatar { width:36px; height:36px; border-radius:50%; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); display:inline-flex; align-items:center; justify-content:center; color:white; font-weight:700; font-size:14px; flex-shrink:0; }
        .avatar.reception { background:linear-gradient(135deg,#1e8449,#34a853); }
        .user-cell { display:flex; align-items:center; gap:12px; }
        .user-info .name  { font-weight:600; color:#1e3a4a; }
        .user-info .uname { font-size:12.5px; color:#8aacbc; margin-top:2px; }
        .pw-hint { font-size:12px; color:#9ab4c2; margin-top:5px; }
        .del-modal { max-width:420px; text-align:center; padding:36px 36px 30px; }
        .del-modal .del-icon { font-size:50px; margin-bottom:14px; }
        .del-modal h2 { font-size:20px; font-weight:700; color:#1e3a4a; margin-bottom:8px; }
        .del-modal p  { font-size:14.5px; color:#7a95a8; }
        .del-name { color:#0a4f6e; font-weight:700; }
        @media(max-width:760px){ .stats{grid-template-columns:1fr 1fr;} .form-row2{grid-template-columns:1fr;} }
        @media(max-width:480px){ .stats{grid-template-columns:1fr;} }
    </style>
</head>
<body>

<nav>
    <div class="nav-brand"><span>&#9875;</span> OceanView Resort</div>
    <div class="nav-right">
        <div class="nav-user">
            <strong><%= fullName != null ? fullName : "Admin" %></strong>
            Administrator
        </div>
        <button class="btn-nav-primary" onclick="openAddModal()">&#43; New Reservation</button>
        <a href="<%= request.getContextPath() %>/api/logout" class="btn-nav">Logout</a>
    </div>
</nav>

<main>
    <div class="welcome">
        <h1>Admin Dashboard &#128737;&#65039;</h1>
        
    </div>

    <!-- Stats -->
    <div class="stats">
        <div class="stat-card">
            <div class="stat-icon" style="background:#e6f7fd;">&#128197;</div>
            <div class="stat-info"><div class="val" id="statTotal">&#8211;</div><div class="lbl">Total Reservations</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#e8f8ee;">&#9989;</div>
            <div class="stat-info"><div class="val" id="statActive">&#8211;</div><div class="lbl">Active</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fff3e0;">&#128710;</div>
            <div class="stat-info"><div class="val" id="statToday">&#8211;</div><div class="lbl">Check-ins Today</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fde8e8;">&#128711;</div>
            <div class="stat-info"><div class="val" id="statOut">&#8211;</div><div class="lbl">Check-outs Today</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#f3e8ff;">&#127968;</div>
            <div class="stat-info"><div class="val" id="statRoomsAvail">&#8211;</div><div class="lbl">Rooms Available</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fef9e7;">&#128101;</div>
            <div class="stat-info"><div class="val" id="statGuests">&#8211;</div><div class="lbl">Registered Guests</div></div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#eee8ff;">&#128100;</div>
            <div class="stat-info"><div class="val" id="statStaff">&#8211;</div><div class="lbl">Staff Members</div></div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="section-title">&#9881; Quick Actions</div>
    <div class="action-cards">
        <div class="action-card" onclick="openAddModal()">
            <div class="ac-icon">&#128203;</div>
            <div class="ac-text"><h4>New Reservation</h4><p>Book a room for a guest</p></div>
        </div>
        <div class="action-card" onclick="openAddRoomModal()">
            <div class="ac-icon" style="background:linear-gradient(135deg,#7b2ff7,#9b5de5);">&#127968;</div>
            <div class="ac-text"><h4>Add Room</h4><p>Register a new hotel room</p></div>
        </div>
        <div class="action-card" onclick="openRegisterGuestModal()">
            <div class="ac-icon" style="background:linear-gradient(135deg,#e67e22,#f39c12);">&#128101;</div>
            <div class="ac-text"><h4>Register Guest</h4><p>Add a guest profile</p></div>
        </div>
        <a href="<%= request.getContextPath() %>/views/add-user.jsp" class="action-card">
            <div class="ac-icon" style="background:linear-gradient(135deg,#1e8449,#34a853);">&#128100;</div>
            <div class="ac-text"><h4>Add Staff</h4><p>Create a staff account</p></div>
        </a>
    </div>

    <!-- Tab Navigation -->
    <div class="tab-nav">
        <button class="tab-btn active" onclick="showTab('reservations')">&#128203; Reservations</button>
        <button class="tab-btn"        onclick="showTab('rooms')">&#127968; Rooms</button>
        <button class="tab-btn"        onclick="showTab('guests')">&#128101; Guests</button>
        <button class="tab-btn"        onclick="showTab('staff')">&#128100; Staff</button>
    </div>

    <div id="alertBox" class="alert"></div>

    <!-- RESERVATIONS TAB -->
    <div id="tab-reservations" class="tab-pane active">
        <div class="filter-bar">
            <button class="filter-btn active" id="filterAll"    onclick="applyFilter('all')">All</button>
            <button class="filter-btn"        id="filterActive" onclick="applyFilter('active')">Active</button>
            <button class="filter-btn"        id="filterToday"  onclick="applyFilter('today')">Today's Check-ins</button>
        </div>
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#128203; All Reservations</div>
                <div class="search-box">
                    <span class="search-icon">&#128269;</span>
                    <input type="text" id="searchInput" placeholder="Search guest, room or res #&hellip;" oninput="renderTable()" />
                </div>
                <button class="btn-add-res" onclick="openAddModal()">&#43; New Reservation</button>
            </div>
            <div id="tableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading reservations&hellip;</p></div>
            </div>
        </div>
    </div>

    <!-- ROOMS TAB -->
    <div id="tab-rooms" class="tab-pane">
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#127968; Room Inventory</div>
                <button class="btn-add-res" onclick="openAddRoomModal()">&#43; Add Room</button>
            </div>
            <div id="roomTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading rooms&hellip;</p></div>
            </div>
        </div>
    </div>

    <!-- GUESTS TAB -->
    <div id="tab-guests" class="tab-pane">
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#128101; Guest Directory</div>
                <div class="search-box">
                    <span class="search-icon">&#128269;</span>
                    <input type="text" id="guestSearchInput" placeholder="Name, mobile or email&hellip;" oninput="renderGuestTable()" />
                </div>
                <button class="btn-add-res" onclick="openRegisterGuestModal()">&#43; Register Guest</button>
            </div>
            <div id="guestTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading guests&hellip;</p></div>
            </div>
        </div>
    </div>

    <!-- STAFF TAB -->
    <div id="tab-staff" class="tab-pane">
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#128100; Staff Accounts</div>
                <div class="search-box">
                    <span class="search-icon">&#128269;</span>
                    <input type="text" id="staffSearchInput" placeholder="Search by name or username&hellip;" oninput="renderStaffTable()" />
                </div>
                <a href="<%= request.getContextPath() %>/views/add-user.jsp" class="btn-add-res" style="text-decoration:none;">&#43; Add Staff</a>
            </div>
            <div style="padding:12px 24px 0;display:flex;gap:8px;border-bottom:1px solid #e8f0f4;flex-wrap:wrap;">
                <button class="filter-btn active" id="staffFilterAll"       onclick="applyStaffFilter('all')">All</button>
                <button class="filter-btn"        id="staffFilterManager"   onclick="applyStaffFilter('manager')">Managers</button>
                <button class="filter-btn"        id="staffFilterReception" onclick="applyStaffFilter('reception')">Reception</button>
            </div>
            <div id="staffTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading staff&hellip;</p></div>
            </div>
        </div>
    </div>
</main>

<!-- ======= MODALS ======= -->

<!-- Add Reservation -->
<div class="modal-overlay" id="addModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#128203; New Reservation</h2>
            <button class="btn-close" onclick="closeAddModal()">&#10005;</button>
        </div>
        <div id="addAlertBox" class="modal-alert"></div>
        <div id="guestLookupSection" style="background:#f0f7fb;border:1.5px solid #b8d4e8;border-radius:8px;padding:14px;margin-bottom:12px;">
            <div style="font-weight:700;color:#1a3c4e;font-size:12.5px;text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;">&#128101; Step 1 &mdash; Find Registered Guest <span class="req">*</span></div>
            <div style="display:flex;gap:8px;">
                <input type="text" id="resGuestSearch" placeholder="Name, mobile, email or NIC&hellip;" style="flex:1;" onkeydown="if(event.key==='Enter')searchGuestForRes();" />
                <button class="btn-msave" style="white-space:nowrap;padding:0 16px;" onclick="searchGuestForRes()">&#128269; Find</button>
            </div>
            <div id="guestLookupResult" style="margin-top:8px;"></div>
        </div>
        <div id="selectedGuestBanner" style="display:none;background:#eaf6f0;border:1.5px solid #27ae60;border-radius:8px;padding:10px 14px;margin-bottom:10px;">
            <div style="display:flex;align-items:center;justify-content:space-between;gap:8px;">
                <div>
                    <div style="font-weight:700;color:#196f3d;font-size:14px;" id="selectedGuestInfo"></div>
                    <div style="color:#5d8a6f;font-size:12px;margin-top:2px;" id="selectedGuestSubInfo"></div>
                </div>
                <button onclick="clearGuestForRes()" style="background:none;border:1px solid #c0392b;color:#c0392b;cursor:pointer;font-size:12px;font-weight:600;padding:4px 10px;border-radius:5px;">Change Guest</button>
            </div>
        </div>
        <form id="addForm" novalidate>
            <div class="form-row2">
                <div class="fg"><label>Check-in Date <span class="req">*</span></label><input type="date" id="checkIn" /></div>
                <div class="fg"><label>Check-out Date <span class="req">*</span></label><input type="date" id="checkOut" /></div>
            </div>
            <div class="fg">
                <label>Room <span class="req">*</span></label>
                <select id="roomType"><option value="">Loading available rooms&hellip;</option></select>
            </div>
        </form>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeAddModal()">Cancel</button>
            <button class="btn-msave" id="btnSaveRes" onclick="saveReservation()">Create Reservation</button>
        </div>
    </div>
</div>

<!-- Detail Modal -->
<div class="modal-overlay" id="detailModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#128196; Reservation Details</h2>
            <button class="btn-close" onclick="closeDetailModal()">&#10005;</button>
        </div>
        <div id="detailContent"></div>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeDetailModal()">Close</button>
            <button class="btn-msave" onclick="showBillFromDetail()">&#128203; View Bill</button>
        </div>
    </div>
</div>

<!-- Bill Modal -->
<div class="modal-overlay" id="billModal">
    <div class="modal bill-modal-inner">
        <div class="modal-header">
            <h2>&#129534; Guest Bill</h2>
            <button class="btn-close" onclick="closeBillModal()">&#10005;</button>
        </div>
        <div id="billContent"></div>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeBillModal()">Close</button>
            <button class="btn-print" onclick="printBill()">&#128424; Print Bill</button>
        </div>
    </div>
</div>

<!-- Edit Reservation Modal -->
<div class="modal-overlay" id="editResModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#9998; Edit Reservation</h2>
            <button class="btn-close" onclick="closeEditResModal()">&#10005;</button>
        </div>
        <div id="editResAlertBox" class="modal-alert"></div>
        <input type="hidden" id="erResId" />
        <div class="form-row2" style="margin-bottom:8px;">
            <div class="fg"><label>Reservation #</label><div id="erResNumber" style="padding:8px 0;font-weight:700;color:#0a4f6e;font-size:14px;"></div></div>
            <div class="fg"><label>Guest</label><div id="erGuestName" style="padding:8px 0;font-size:13.5px;color:#3a5a6e;"></div></div>
        </div>
        <div class="form-row2">
            <div class="fg"><label>Check-in Date <span class="req">*</span></label><input type="date" id="erCheckIn" /></div>
            <div class="fg"><label>Check-out Date <span class="req">*</span></label><input type="date" id="erCheckOut" /></div>
        </div>
        <div class="fg">
            <label>Room <span class="req">*</span></label>
            <select id="erResRoom"><option value="">Loading rooms&hellip;</option></select>
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

<!-- Cancel Reservation Confirm -->
<div class="modal-overlay" id="cancelResModal">
    <div class="modal del-modal">
        <div class="del-icon">&#9888;</div>
        <h2>Cancel Reservation?</h2>
        <p>Cancel <strong id="cancelResLabel" class="del-name"></strong>? This cannot be undone.</p>
        <div class="modal-footer" style="justify-content:center;margin-top:20px;">
            <button class="btn-mcancel" onclick="closeCancelResModal()">Keep Reservation</button>
            <button class="btn-msave" id="btnConfirmCancelRes" style="background:linear-gradient(135deg,#c0392b,#e04b3a);" onclick="confirmCancelReservation()">Cancel Reservation</button>
        </div>
    </div>
</div>

<!-- Add Room Modal -->
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
        <div class="fg"><label>Description</label><textarea id="arDescription" placeholder="Optional room description&hellip;"></textarea></div>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeAddRoomModal()">Cancel</button>
            <button class="btn-msave" id="btnSaveRoom" onclick="saveNewRoom()">Add Room</button>
        </div>
    </div>
</div>

<!-- Edit Room Modal -->
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

<!-- Delete Room Confirm -->
<div class="modal-overlay" id="deleteRoomModal">
    <div class="modal del-modal">
        <div class="del-icon">&#128465;&#65039;</div>
        <h2>Delete Room?</h2>
        <p>Delete <strong id="deleteRoomLabel" class="del-name"></strong>? This cannot be undone.</p>
        <div class="modal-footer" style="justify-content:center;margin-top:20px;">
            <button class="btn-mcancel" onclick="closeDeleteRoomModal()">Cancel</button>
            <button class="btn-msave" id="btnConfirmDeleteRoom" style="background:linear-gradient(135deg,#c0392b,#e04b3a);" onclick="confirmDeleteRoom()">Delete</button>
        </div>
    </div>
</div>

<!-- Register Guest Modal -->
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
            <div class="fg"><label>Notes</label><textarea id="gNotes" rows="3" placeholder="Any additional notes&hellip;"></textarea></div>
        </form>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeRegisterGuestModal()">Cancel</button>
            <button class="btn-msave" id="btnSaveGuest" onclick="saveGuest()">&#128101; Register Guest</button>
        </div>
    </div>
</div>

<!-- Guest Detail Modal -->
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

<!-- Edit Guest Modal -->
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

<!-- Delete Guest Confirm -->
<div class="modal-overlay" id="deleteGuestModal">
    <div class="modal del-modal">
        <div class="del-icon">&#128465;&#65039;</div>
        <h2>Delete Guest?</h2>
        <p>Delete <strong id="deleteGuestLabel" class="del-name"></strong>? This cannot be undone.</p>
        <div class="modal-footer" style="justify-content:center;margin-top:20px;">
            <button class="btn-mcancel" onclick="closeDeleteGuestModal()">Cancel</button>
            <button class="btn-msave" id="btnConfirmDeleteGuest" style="background:linear-gradient(135deg,#c0392b,#e04b3a);" onclick="confirmDeleteGuest()">Delete Guest</button>
        </div>
    </div>
</div>

<!-- Edit Staff Modal -->
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
        <div class="form-row2">
            <div class="fg"><label>Username <span class="req">*</span></label><input type="text" id="editStaffUsername" placeholder="Username" autocomplete="off" /></div>
            <div class="fg">
                <label>Role <span class="req">*</span></label>
                <select id="editStaffRole">
                    <option value="manager">Manager</option>
                    <option value="reception">Reception</option>
                </select>
            </div>
        </div>
        <div class="fg">
            <label>New Password</label>
            <input type="password" id="editStaffPassword" placeholder="Leave blank to keep current" autocomplete="new-password" />
            <div class="pw-hint">Only fill to change the password (min. 6 chars).</div>
        </div>
        <div class="modal-footer">
            <button class="btn-mcancel" onclick="closeEditStaffModal()">Cancel</button>
            <button class="btn-msave" id="btnSaveStaffEdit" onclick="saveStaffEdit()">Save Changes</button>
        </div>
    </div>
</div>

<!-- Delete Staff Confirm -->
<div class="modal-overlay" id="deleteStaffModal">
    <div class="modal del-modal">
        <div class="del-icon">&#128465;</div>
        <h2>Delete Account?</h2>
        <p>Permanently delete <strong id="deleteStaffTargetName" class="del-name"></strong>. This cannot be undone.</p>
        <input type="hidden" id="deleteStaffTargetId" />
        <div class="modal-footer" style="justify-content:center;margin-top:20px;">
            <button class="btn-mcancel" onclick="closeDeleteStaffModal()">Cancel</button>
            <button class="btn-msave" id="btnConfirmDelStaff" style="background:linear-gradient(135deg,#c0392b,#e04b3a);" onclick="confirmDeleteStaff()">Yes, Delete</button>
        </div>
    </div>
</div>

<!-- ======= SCRIPTS ======= -->
<script>
var allReservations   = [];
var activeFilter      = 'all';
var currentDetailId   = null;
var cancelResTarget   = null;
var allRooms          = [];
var deleteRoomTarget  = null;
var allGuests         = [];
var selectedGuest     = null;
var allStaff          = [];
var activeStaffFilter = 'all';

var apiBase     = '<%= request.getContextPath() %>/api/reservations';
var roomApiBase = '<%= request.getContextPath() %>/api/rooms';
var guestApiBase= '<%= request.getContextPath() %>/api/guests';
var userApiBase = '<%= request.getContextPath() %>/api/users';
var today       = new Date().toISOString().split('T')[0];

// ── Tabs ─────────────────────────────────────────────────────────────────────
function showTab(name) {
    $('.tab-pane').removeClass('active');
    $('#tab-' + name).addClass('active');
    $('.tab-btn').removeClass('active');
    $('.tab-btn').each(function(){
        if ($(this).attr('onclick') && $(this).attr('onclick').indexOf("'" + name + "'") !== -1)
            $(this).addClass('active');
    });
}

// ── Helpers ───────────────────────────────────────────────────────────────────
function esc(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function row(label, value) {
    return '<div class="detail-row"><div class="detail-label">' + label + '</div><div class="detail-value">' + value + '</div></div>';
}
function gdetailRow(label, value) {
    return '<tr><td style="padding:9px 8px;color:#6b8fa5;font-size:13px;font-weight:600;width:38%;border-bottom:1px solid #e8f0f5;">' + label +
           '</td><td style="padding:9px 8px;color:#1a3c4e;font-size:13.5px;border-bottom:1px solid #e8f0f5;">' + esc(String(value)) + '</td></tr>';
}
function getInitials(name) {
    if (!name) return '?';
    var p = name.trim().split(' ');
    return p.length >= 2 ? (p[0][0] + p[p.length-1][0]).toUpperCase() : name[0].toUpperCase();
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

// ── Reservations ──────────────────────────────────────────────────────────────
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

function applyFilter(f) {
    activeFilter = f;
    $('.filter-btn[id^=filter]').removeClass('active');
    if (f === 'all')    $('#filterAll').addClass('active');
    if (f === 'active') $('#filterActive').addClass('active');
    if (f === 'today')  $('#filterToday').addClass('active');
    renderTable();
}

function renderTable() {
    var q = ($('#searchInput').val() || '').toLowerCase();
    var list = allReservations.filter(function(r) {
        var mf = activeFilter === 'all' ||
            (activeFilter === 'active' && r.status === 'active') ||
            (activeFilter === 'today'  && r.checkInDate === today);
        var ms = !q || r.guestName.toLowerCase().includes(q) ||
            r.reservationNumber.toLowerCase().includes(q) || r.roomType.toLowerCase().includes(q);
        return mf && ms;
    });
    if (!list.length) { $('#tableContainer').html('<div class="empty-state"><div class="es-icon">&#128100;</div><p>No reservations found.</p></div>'); return; }
    var rows = list.map(function(r, i) {
        var badge = r.status === 'active' ? 'badge-active' : r.status === 'checked_out' ? 'badge-checkedout' : 'badge-cancelled';
        return '<tr onclick="openDetailModal(' + r.id + ')">' +
            '<td>' + (i+1) + '</td><td><strong>' + esc(r.reservationNumber) + '</strong></td>' +
            '<td>' + esc(r.guestName) + '</td><td>' + esc(r.roomType) + '</td>' +
            '<td>' + esc(r.checkInDate) + '</td><td>' + esc(r.checkOutDate) + '</td>' +
            '<td><span class="badge ' + badge + '">' + esc(r.status) + '</span></td>' +
            '<td><strong>$' + esc(r.totalAmount) + '</strong></td>' +
            '<td>' + esc(r.createdByName) + '</td>' +
            '<td onclick="event.stopPropagation()">' +
              '<button class="btn-view" onclick="openDetailModal(' + r.id + ')">Details</button>' +
              '<button class="btn-bill" onclick="openBillModal(' + r.id + ')">Bill</button>' +
              (r.status === 'active' ? '<button class="btn-edit" onclick="openEditResModal(' + r.id + ')">&#9998; Edit</button>' : '') +
            '</td></tr>';
    }).join('');
    $('#tableContainer').html(
        '<table><thead><tr><th>#</th><th>Res #</th><th>Guest</th><th>Room</th><th>Check-in</th><th>Check-out</th><th>Status</th><th>Total</th><th>Created By</th><th>Actions</th></tr></thead>' +
        '<tbody>' + rows + '</tbody></table>'
    );
}

function openAddModal() {
    $('#addForm')[0].reset(); $('#checkIn').val(today); $('#addAlertBox').hide();
    selectedGuest = null; window._guestSearchResults = [];
    $('#resGuestSearch').val(''); $('#guestLookupResult').html('');
    $('#selectedGuestBanner').hide(); $('#guestLookupSection').show();
    var $sel = $('#roomType').html('<option value="">Loading available rooms\u2026</option>').prop('disabled', true);
    $.ajax({
        url: roomApiBase + '?status=available', type: 'GET', dataType: 'json',
        success: function(res) {
            $sel.prop('disabled', false);
            if (res.success && res.rooms.length) {
                var opts = '<option value="">-- Select a room --</option>';
                res.rooms.forEach(function(r) {
                    opts += '<option value="' + r.id + '" data-roomtype="' + esc(r.roomType) + '">Room ' + esc(r.roomNumber) + ' \u2013 ' + esc(r.roomType) + ' ($' + esc(r.ratePerNight) + '/night)</option>';
                });
                $sel.html(opts);
            } else { $sel.html('<option value="">No rooms available</option>'); }
        },
        error: function() { $sel.prop('disabled', false).html('<option value="">Failed to load rooms</option>'); }
    });
    $('#addModal').addClass('show');
}
function closeAddModal() { $('#addModal').removeClass('show'); }

function buildGuestResultCard(g) {
    return '<div style="background:#eaf6f0;border:1.5px solid #27ae60;border-radius:7px;padding:10px 12px;margin-bottom:6px;">' +
        '<div style="display:flex;align-items:center;justify-content:space-between;gap:8px;"><div>' +
        '<div style="font-weight:700;color:#196f3d;font-size:13.5px;">&#10003; ' + esc(g.fullName) + '</div>' +
        '<div style="color:#5d8a6f;font-size:12px;margin-top:2px;">' + esc(g.mobileNumber) +
        (g.email ? ' &nbsp;|&nbsp; ' + esc(g.email) : '') +
        (g.nicNumber ? ' &nbsp;|&nbsp; NIC: ' + esc(g.nicNumber) : '') + '</div></div>' +
        '<button class="btn-msave" style="padding:5px 14px;font-size:12.5px;white-space:nowrap;" onclick="selectGuestForRes(' + g.id + ')">&#10003; Select</button>' +
        '</div></div>';
}

function searchGuestForRes() {
    var q = $.trim($('#resGuestSearch').val());
    if (!q) { $('#guestLookupResult').html('<span style="color:#c0392b;font-size:13px;">Please enter a name, mobile, email or NIC.</span>'); return; }
    $('#guestLookupResult').html('<span style="color:#8aacbc;font-size:13px;">Searching\u2026</span>');
    $.ajax({
        url: guestApiBase + '?keyword=' + encodeURIComponent(q), type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success && res.guests && res.guests.length) {
                window._guestSearchResults = res.guests;
                if (res.guests.length === 1) {
                    $('#guestLookupResult').html(buildGuestResultCard(res.guests[0]));
                } else {
                    var html = '<div style="font-size:12px;color:#5d7a8a;margin-bottom:6px;">' + res.guests.length + ' guests found:</div><div style="max-height:210px;overflow-y:auto;">';
                    res.guests.forEach(function(g){ html += buildGuestResultCard(g); });
                    html += '</div>';
                    $('#guestLookupResult').html(html);
                }
            } else {
                window._guestSearchResults = [];
                $('#guestLookupResult').html(
                    '<div style="background:#fdf2f0;border:1.5px solid #e74c3c;border-radius:7px;padding:10px 12px;">' +
                    '<div style="color:#c0392b;font-weight:600;font-size:13px;">&#10006; No registered guest found.</div>' +
                    '<div style="color:#888;font-size:12px;margin-top:3px;">Register the guest first before creating a reservation.</div></div>'
                );
            }
        },
        error: function() { $('#guestLookupResult').html('<span style="color:#c0392b;font-size:13px;">Server error. Please try again.</span>'); }
    });
}

function selectGuestForRes(id) {
    var list = window._guestSearchResults || [], g = null;
    for (var i = 0; i < list.length; i++) { if (list[i].id === id) { g = list[i]; break; } }
    if (!g) { for (var j = 0; j < allGuests.length; j++) { if (allGuests[j].id === id) { g = allGuests[j]; break; } } }
    if (!g) return;
    selectedGuest = g;
    $('#guestLookupSection').hide();
    $('#selectedGuestInfo').text('\u2713 ' + g.fullName);
    $('#selectedGuestSubInfo').text(g.mobileNumber + (g.email ? '  |  ' + g.email : '') + (g.nicNumber ? '  |  NIC: ' + g.nicNumber : ''));
    $('#selectedGuestBanner').show(); $('#addAlertBox').hide();
}
function clearGuestForRes() {
    selectedGuest = null; window._guestSearchResults = [];
    $('#resGuestSearch').val(''); $('#guestLookupResult').html('');
    $('#selectedGuestBanner').hide(); $('#guestLookupSection').show();
}

function saveReservation() {
    if (!selectedGuest) { showModalAlert('addAlertBox', 'Please find and select a registered guest first.'); return; }
    var roomId = $('#roomType').val(), roomType = $('#roomType option:selected').data('roomtype');
    var checkIn = $('#checkIn').val(), checkOut = $('#checkOut').val();
    $('#addAlertBox').hide();
    if (!roomId || !checkIn || !checkOut) { showModalAlert('addAlertBox', 'Please select a room and set check-in / check-out dates.'); return; }
    if (checkOut <= checkIn) { showModalAlert('addAlertBox', 'Check-out must be after check-in.'); return; }
    var $btn = $('#btnSaveRes').prop('disabled', true).text('Creating\u2026');
    $.ajax({
        url: apiBase, type: 'POST', dataType: 'json',
        data: { action:'add', guestName: selectedGuest.fullName, contactNumber: selectedGuest.mobileNumber,
                roomType: roomType, roomId: roomId, address: selectedGuest.address || '', checkIn: checkIn, checkOut: checkOut },
        success: function(res) {
            if (res.success) {
                closeAddModal(); showAlert('success', '\u2713 ' + res.message); loadReservations(); loadRooms();
                if (res.bill) setTimeout(function(){ showBillData(res.bill); }, 400);
            } else showModalAlert('addAlertBox', res.message);
            $btn.prop('disabled', false).text('Create Reservation');
        },
        error: function(xhr) {
            var msg = 'Failed to create reservation.';
            try { msg = JSON.parse(xhr.responseText).message || msg; } catch(e) {}
            showModalAlert('addAlertBox', msg); $btn.prop('disabled', false).text('Create Reservation');
        }
    });
}

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
    var bc = r.status === 'active' ? 'badge-active' : r.status === 'checked_out' ? 'badge-checkedout' : 'badge-cancelled';
    $('#detailContent').html('<div>' +
        row('Reservation #', '<strong>' + esc(r.reservationNumber) + '</strong>') +
        row('Status', '<span class="badge ' + bc + '">' + esc(r.status) + '</span>') +
        row('Guest Name', esc(r.guestName)) + row('Contact', esc(r.contactNumber)) +
        row('Address', esc(r.address) || '\u2014') + row('Room Type', esc(r.roomType)) +
        row('Check-in', esc(r.checkInDate)) + row('Check-out', esc(r.checkOutDate)) +
        row('Total Amount', '<strong>$' + esc(r.totalAmount) + '</strong>') +
        row('Created By', esc(r.createdByName)) + row('Created At', esc(r.createdAt)) +
    '</div>');
}
function showBillFromDetail() { closeDetailModal(); if (currentDetailId) openBillModal(currentDetailId); }

function openBillModal(id) {
    $.ajax({
        url: apiBase + '?action=bill&id=' + id, type: 'GET', dataType: 'json',
        success: function(res) { if (res.success) showBillData(res.bill); else showAlert('error', res.message); }
    });
}
function closeBillModal() { $('#billModal').removeClass('show'); }
function showBillData(b) {
    $('#billContent').html(
        '<div class="bill-header-box"><h3>&#9875; OceanView Resort</h3><p>Guest Bill &amp; Invoice</p></div>' +
        '<table class="bill-table">' +
        '<tr><td class="lbl">Reservation No.</td><td class="val">' + esc(b.reservationNumber) + '</td></tr>' +
        '<tr><td class="lbl">Guest Name</td><td class="val">'      + esc(b.guestName)         + '</td></tr>' +
        '<tr><td class="lbl">Address</td><td class="val">'         + (esc(b.address)||'\u2014')+ '</td></tr>' +
        '<tr><td class="lbl">Contact</td><td class="val">'         + esc(b.contactNumber)     + '</td></tr>' +
        '<tr><td class="lbl">Room Type</td><td class="val">'       + esc(b.roomType)           + '</td></tr>' +
        '<tr><td class="lbl">Check-in</td><td class="val">'        + esc(b.checkInDate)        + '</td></tr>' +
        '<tr><td class="lbl">Check-out</td><td class="val">'       + esc(b.checkOutDate)       + '</td></tr>' +
        '<tr><td class="lbl">Nights</td><td class="val">'          + b.nights                  + '</td></tr>' +
        '<tr><td class="lbl">Rate / Night</td><td class="val">$'   + b.ratePerNight            + '</td></tr>' +
        '<tr><td class="lbl">Subtotal</td><td class="val">$'       + b.subtotal                + '</td></tr>' +
        '<tr><td class="lbl">Tax (' + b.taxRate + ')</td><td class="val">$' + b.tax          + '</td></tr>' +
        '<tr class="bill-total-row"><td class="lbl">TOTAL</td><td class="val">$' + b.total  + '</td></tr>' +
        '</table>'
    );
    $('#billModal').addClass('show');
}
function printBill() {
    var w = window.open('', '_blank', 'width=800,height=900');
    w.document.write('<!DOCTYPE html><html><head><title>OceanView Resort \u2013 Bill</title>' +
        '<style>body{font-family:Arial,sans-serif;padding:48px 56px;color:#1e3a4a;}' +
        '.bill-header-box{text-align:center;padding:28px;background:linear-gradient(135deg,#0a4f6e,#1aa3c8);border-radius:12px;color:white;margin-bottom:32px;}' +
        '.bill-header-box h3{font-size:26px;font-weight:700;margin:0;}.bill-header-box p{font-size:16px;opacity:.85;margin-top:6px;}' +
        '.bill-table{width:100%;border-collapse:collapse;margin-bottom:16px;}' +
        '.bill-table td{padding:12px 8px;font-size:16px;border-bottom:1px solid #eef4f7;}' +
        '.bill-table .lbl{color:#7a95a8;}.bill-table .val{text-align:right;font-weight:600;color:#1e3a4a;}' +
        '.bill-total-row td{font-size:19px;font-weight:800;color:#0a4f6e;border-top:2px solid #0a4f6e;padding-top:16px;}' +
        '</style></head><body>' + document.getElementById('billContent').innerHTML + '</body></html>');
    w.document.close(); w.focus(); w.print(); w.close();
}

// ── Edit Reservation ──────────────────────────────────────────────────────────
function openEditResModal(id) {
    var r = allReservations.find(function(x){ return x.id === id; });
    if (!r) return;
    $('#erResId').val(r.id); $('#erResNumber').text(r.reservationNumber);
    $('#erGuestName').text(r.guestName + '  \u2014  ' + r.contactNumber);
    $('#erCheckIn').val(r.checkInDate); $('#erCheckOut').val(r.checkOutDate);
    $('#erAddress').val(r.address || ''); $('#editResAlertBox').hide();
    var currentRoom = allRooms.find(function(rm){ return rm.id === r.roomId; });
    $('#erOldRoomId').val(currentRoom ? currentRoom.id : '');
    var $sel = $('#erResRoom').html('<option value="">Loading rooms\u2026</option>').prop('disabled', true);
    $.ajax({
        url: roomApiBase + '?status=available', type: 'GET', dataType: 'json',
        success: function(res) {
            $sel.prop('disabled', false);
            var opts = '';
            if (currentRoom) {
                opts += '<option value="' + currentRoom.id + '" data-roomtype="' + esc(currentRoom.roomType) + '" selected>Room ' +
                        esc(currentRoom.roomNumber) + ' \u2013 ' + esc(currentRoom.roomType) +
                        ' ($' + esc(currentRoom.ratePerNight) + '/night) [current]</option>';
            }
            if (res.success && res.rooms) {
                res.rooms.forEach(function(rm) {
                    if (currentRoom && rm.id === currentRoom.id) return;
                    opts += '<option value="' + rm.id + '" data-roomtype="' + esc(rm.roomType) + '">Room ' +
                            esc(rm.roomNumber) + ' \u2013 ' + esc(rm.roomType) + ' ($' + esc(rm.ratePerNight) + '/night)</option>';
                });
            }
            $sel.html(opts || '<option value="">No rooms available</option>');
        },
        error: function() { $sel.prop('disabled', false).html('<option value="">Failed to load rooms</option>'); }
    });
    $('#editResModal').addClass('show');
}
function closeEditResModal() { $('#editResModal').removeClass('show'); }

function saveEditReservation() {
    var id = parseInt($('#erResId').val());
    var checkIn = $('#erCheckIn').val(), checkOut = $('#erCheckOut').val();
    var address = $.trim($('#erAddress').val());
    var newRoomId = $('#erResRoom').val();
    var roomType = $('#erResRoom option:selected').data('roomtype') || '';
    var oldRoomId = $('#erOldRoomId').val();
    $('#editResAlertBox').hide();
    if (!checkIn || !checkOut) { showModalAlert('editResAlertBox', 'Check-in and check-out dates are required.'); return; }
    if (checkOut <= checkIn)   { showModalAlert('editResAlertBox', 'Check-out must be after check-in.'); return; }
    if (!newRoomId)            { showModalAlert('editResAlertBox', 'Please select a room.'); return; }
    var $btn = $('#btnSaveEditRes').prop('disabled', true).text('Saving\u2026');
    $.ajax({
        url: apiBase, type: 'POST', dataType: 'json',
        data: { action:'update', id:id, checkIn:checkIn, checkOut:checkOut, address:address, roomType:roomType, newRoomId:newRoomId, oldRoomId:oldRoomId },
        success: function(res) {
            if (res.success) { closeEditResModal(); showAlert('success', '\u2713 ' + res.message); loadReservations(); loadRooms(); }
            else showModalAlert('editResAlertBox', res.message);
            $btn.prop('disabled', false).text('\u2713 Save Changes');
        },
        error: function(xhr) {
            var msg = 'Failed to update reservation.';
            try { msg = JSON.parse(xhr.responseText).message || msg; } catch(e) {}
            showModalAlert('editResAlertBox', msg); $btn.prop('disabled', false).text('\u2713 Save Changes');
        }
    });
}
function cancelFromEditModal() { var id = parseInt($('#erResId').val()); closeEditResModal(); openCancelResModal(id); }
function openCancelResModal(id) {
    var r = allReservations.find(function(x){ return x.id === id; });
    if (!r) return;
    cancelResTarget = id;
    $('#cancelResLabel').text(r.reservationNumber + ' \u2014 ' + r.guestName);
    $('#cancelResModal').addClass('show');
}
function closeCancelResModal() { $('#cancelResModal').removeClass('show'); cancelResTarget = null; }
function confirmCancelReservation() {
    if (!cancelResTarget) return;
    var $btn = $('#btnConfirmCancelRes').prop('disabled', true).text('Cancelling\u2026');
    $.ajax({
        url: apiBase, type: 'POST', dataType: 'json',
        data: { action:'cancel', id:cancelResTarget },
        success: function(res) {
            closeCancelResModal();
            if (res.success) { showAlert('success', '\u2713 ' + res.message); loadReservations(); loadRooms(); }
            else showAlert('error', res.message);
            $btn.prop('disabled', false).text('Cancel Reservation');
        },
        error: function() { showAlert('error', 'Failed to cancel reservation.'); $btn.prop('disabled', false).text('Cancel Reservation'); closeCancelResModal(); }
    });
}

// ── Rooms ──────────────────────────────────────────────────────────────────────
function loadRooms() {
    $.ajax({
        url: roomApiBase, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success) {
                allRooms = res.rooms;
                $('#statRoomsAvail').text(allRooms.filter(function(r){ return r.status === 'available'; }).length);
                renderRoomTable();
            }
        },
        error: function() { $('#roomTableContainer').html('<div class="empty-state"><p>Failed to load rooms.</p></div>'); }
    });
}
function renderRoomTable() {
    if (!allRooms.length) { $('#roomTableContainer').html('<div class="empty-state"><div class="es-icon">&#127968;</div><p>No rooms yet. Add your first room.</p></div>'); return; }
    var rows = allRooms.map(function(r, i) {
        var st = r.status === 'available' ? 'badge-available' : r.status === 'occupied' ? 'badge-occupied' : 'badge-maintenance';
        return '<tr><td>' + (i+1) + '</td><td><strong>' + esc(r.roomNumber) + '</strong></td><td>' + esc(r.roomType) + '</td>' +
            '<td>Floor ' + esc(r.floor) + '</td><td><strong>$' + esc(r.ratePerNight) + '</strong></td>' +
            '<td><span class="badge ' + st + '">' + esc(r.status) + '</span></td>' +
            '<td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + (esc(r.description) || '<span style="color:#aaa">\u2014</span>') + '</td>' +
            '<td><button class="btn-edit" onclick="openEditRoomModal(' + r.id + ')">Edit</button>' +
                 '<button class="btn-delete" onclick="openDeleteRoomModal(' + r.id + ',\'' + esc(r.roomNumber) + '\')">Delete</button></td></tr>';
    }).join('');
    $('#roomTableContainer').html(
        '<table><thead><tr><th>#</th><th>Room #</th><th>Type</th><th>Floor</th><th>Rate/Night</th><th>Status</th><th>Description</th><th>Actions</th></tr></thead><tbody>' + rows + '</tbody></table>'
    );
}
function openAddRoomModal() {
    $('#arRoomNumber').val(''); $('#arFloor').val(1); $('#arRoomType').val(''); $('#arRate').val('');
    $('#arStatus').val('available'); $('#arDescription').val(''); $('#addRoomAlertBox').hide();
    $('#addRoomModal').addClass('show');
}
function closeAddRoomModal() { $('#addRoomModal').removeClass('show'); }
function saveNewRoom() {
    var rn = $.trim($('#arRoomNumber').val()), rt = $('#arRoomType').val(), rate = $('#arRate').val();
    if (!rn || !rt || !rate) { showModalAlert('addRoomAlertBox', 'Please fill in all required fields.'); return; }
    var $btn = $('#btnSaveRoom').prop('disabled', true).text('Adding\u2026');
    $.ajax({
        url: roomApiBase, type: 'POST', dataType: 'json',
        data: { action:'add', roomNumber:rn, roomType:rt, ratePerNight:rate, status:$('#arStatus').val(), floor:$('#arFloor').val(), description:$('#arDescription').val() },
        success: function(res) {
            if (res.success) { closeAddRoomModal(); showAlert('success', '\u2713 ' + res.message); loadRooms(); }
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
    $('#erRate').val(r.ratePerNight); $('#erStatus').val(r.status); $('#erFloor').val(r.floor); $('#erDescription').val(r.description);
    $('#editRoomAlertBox').hide(); $('#editRoomModal').addClass('show');
}
function closeEditRoomModal() { $('#editRoomModal').removeClass('show'); }
function updateRoom() {
    var rn = $.trim($('#erRoomNumber').val()), rt = $('#erRoomType').val(), rate = $('#erRate').val();
    if (!rn || !rt || !rate) { showModalAlert('editRoomAlertBox', 'Please fill in all required fields.'); return; }
    var $btn = $('#btnUpdateRoom').prop('disabled', true).text('Saving\u2026');
    $.ajax({
        url: roomApiBase, type: 'POST', dataType: 'json',
        data: { action:'update', id:$('#erId').val(), roomNumber:rn, roomType:rt, ratePerNight:rate, status:$('#erStatus').val(), floor:$('#erFloor').val(), description:$('#erDescription').val() },
        success: function(res) {
            if (res.success) { closeEditRoomModal(); showAlert('success', '\u2713 ' + res.message); loadRooms(); }
            else showModalAlert('editRoomAlertBox', res.message);
            $btn.prop('disabled', false).text('Save Changes');
        },
        error: function() { showModalAlert('editRoomAlertBox', 'Failed to update.'); $btn.prop('disabled', false).text('Save Changes'); }
    });
}
function openDeleteRoomModal(id, number) { deleteRoomTarget = id; $('#deleteRoomLabel').text('Room ' + number); $('#deleteRoomModal').addClass('show'); }
function closeDeleteRoomModal() { $('#deleteRoomModal').removeClass('show'); deleteRoomTarget = null; }
function confirmDeleteRoom() {
    if (!deleteRoomTarget) return;
    var $btn = $('#btnConfirmDeleteRoom').prop('disabled', true).text('Deleting\u2026');
    $.ajax({
        url: roomApiBase, type: 'POST', dataType: 'json',
        data: { action:'delete', id:deleteRoomTarget },
        success: function(res) {
            closeDeleteRoomModal();
            if (res.success) { showAlert('success', '\u2713 ' + res.message); loadRooms(); } else showAlert('error', res.message);
            $btn.prop('disabled', false).text('Delete');
        },
        error: function() { showAlert('error', 'Failed to delete.'); $btn.prop('disabled', false).text('Delete'); }
    });
}

// ── Guests ─────────────────────────────────────────────────────────────────────
function loadGuests() {
    $.ajax({
        url: guestApiBase, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success) { allGuests = res.guests; $('#statGuests').text(allGuests.length); renderGuestTable(); }
        },
        error: function() { $('#guestTableContainer').html('<div class="empty-state"><p>Failed to load guests.</p></div>'); }
    });
}
function renderGuestTable() {
    var kw = ($('#guestSearchInput').val() || '').toLowerCase();
    var list = allGuests.filter(function(g) {
        return !kw || g.fullName.toLowerCase().includes(kw) ||
               g.mobileNumber.toLowerCase().includes(kw) ||
               (g.email && g.email.toLowerCase().includes(kw));
    });
    if (!list.length) { $('#guestTableContainer').html('<div class="empty-state"><div class="es-icon">&#128101;</div><p>No guests found.</p></div>'); return; }
    var html = '<table><thead><tr><th>Name</th><th>Mobile</th><th>Email</th><th>NIC / ID</th><th>Address</th><th>Registered</th><th>Actions</th></tr></thead><tbody>';
    list.forEach(function(g) {
        html += '<tr><td><strong>' + esc(g.fullName) + '</strong></td>' +
            '<td>' + esc(g.mobileNumber) + '</td>' +
            '<td>' + (g.email ? esc(g.email) : '<span style="color:#aaa">\u2014</span>') + '</td>' +
            '<td>' + (g.nicNumber ? esc(g.nicNumber) : '<span style="color:#aaa">\u2014</span>') + '</td>' +
            '<td>' + (g.address ? esc(g.address) : '<span style="color:#aaa">\u2014</span>') + '</td>' +
            '<td style="color:#8aacbc;font-size:12px;">' + esc((g.createdAt || '').substring(0,10)) + '</td>' +
            '<td style="white-space:nowrap;">' +
              '<button onclick="openGuestDetailModal(' + g.id + ')" style="background:linear-gradient(135deg,#1a6985,#2389b0);color:#fff;border:none;border-radius:6px;padding:4px 10px;cursor:pointer;font-size:11.5px;margin-right:3px;">Details</button>' +
              '<button onclick="openEditGuestModal(' + g.id + ')" style="background:linear-gradient(135deg,#1a7a4e,#27ae60);color:#fff;border:none;border-radius:6px;padding:4px 10px;cursor:pointer;font-size:11.5px;margin-right:3px;">&#9998; Edit</button>' +
              '<button onclick="openDeleteGuestModal(' + g.id + ',\'' + esc(g.fullName) + '\')" style="background:linear-gradient(135deg,#c0392b,#e04b3a);color:#fff;border:none;border-radius:6px;padding:4px 10px;cursor:pointer;font-size:11.5px;">&#10006; Delete</button>' +
            '</td></tr>';
    });
    html += '</tbody></table>';
    $('#guestTableContainer').html(html);
}
function openRegisterGuestModal() { $('#guestForm')[0].reset(); $('#guestAlertBox').hide(); $('#guestModal').addClass('show'); }
function closeRegisterGuestModal() { $('#guestModal').removeClass('show'); }
function saveGuest() {
    var fullName = $.trim($('#gFullName').val()), mobile = $.trim($('#gMobile').val());
    if (!fullName || !mobile) { $('#guestAlertBox').show().text('Full name and mobile number are required.'); return; }
    var $btn = $('#btnSaveGuest').prop('disabled', true).text('Saving\u2026');
    $.ajax({
        url: guestApiBase, type: 'POST', dataType: 'json',
        data: { action:'register', fullName:fullName, mobileNumber:mobile, email:$.trim($('#gEmail').val()), address:$.trim($('#gAddress').val()), nicNumber:$.trim($('#gNic').val()), notes:$.trim($('#gNotes').val()) },
        success: function(res) {
            $btn.prop('disabled', false).text('Register Guest');
            if (res.success) { closeRegisterGuestModal(); showAlert('success', res.message); loadGuests(); }
            else $('#guestAlertBox').show().text(res.message);
        },
        error: function() { $btn.prop('disabled', false).text('Register Guest'); $('#guestAlertBox').show().text('Server error.'); }
    });
}
function openGuestDetailModal(id) {
    $('#guestDetailContent').html('<div style="padding:20px;text-align:center;color:#8aacbc;">Loading\u2026</div>');
    $('#guestDetailModal').addClass('show');
    $.ajax({
        url: guestApiBase + '?id=' + id, type: 'GET', dataType: 'json',
        success: function(res) {
            if (!res.success) { $('#guestDetailContent').html('<p style="color:#c0392b;">' + esc(res.message) + '</p>'); return; }
            var g = res.guest, reservations = res.reservations || [];
            var html = '<table style="width:100%;border-collapse:collapse;margin-bottom:18px;">' +
                gdetailRow('Full Name', g.fullName) + gdetailRow('Mobile', g.mobileNumber) +
                gdetailRow('Email', g.email || '\u2014') + gdetailRow('NIC / Passport', g.nicNumber || '\u2014') +
                gdetailRow('Address', g.address || '\u2014') + gdetailRow('Notes', g.notes || '\u2014') +
                gdetailRow('Registered', (g.createdAt || '').substring(0,10)) + '</table>';
            html += '<div style="font-weight:700;color:#1a3c4e;font-size:12.5px;text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;border-top:2px solid #dceef7;padding-top:14px;">&#128203; Reservation History (' + reservations.length + ')</div>';
            if (!reservations.length) {
                html += '<div style="color:#aaa;font-size:13px;padding:8px 0;">No reservations found for this guest.</div>';
            } else {
                html += '<table style="width:100%;border-collapse:collapse;font-size:13px;"><thead><tr>' +
                    '<th style="text-align:left;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Res #</th>' +
                    '<th style="text-align:left;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Room</th>' +
                    '<th style="text-align:left;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Check-in</th>' +
                    '<th style="text-align:left;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Check-out</th>' +
                    '<th style="text-align:right;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Total</th>' +
                    '<th style="text-align:center;padding:7px 8px;background:#f0f7fb;color:#5d7a8a;font-weight:600;border-bottom:2px solid #dceef7;">Status</th>' +
                    '</tr></thead><tbody>';
                reservations.forEach(function(r) {
                    var bc = r.status === 'active' ? 'background:#d5f5e3;color:#1e8449;' : 'background:#f0f0f0;color:#777;';
                    html += '<tr><td style="padding:7px 8px;border-bottom:1px solid #eef4f8;color:#2980b9;font-weight:600;">' + esc(r.reservationNumber) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;">' + esc(r.roomType) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;">' + esc(r.checkInDate) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;">' + esc(r.checkOutDate) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;text-align:right;font-weight:600;">$' + esc(r.totalAmount) + '</td>' +
                        '<td style="padding:7px 8px;border-bottom:1px solid #eef4f8;text-align:center;"><span style="' + bc + 'border-radius:4px;padding:2px 8px;font-size:11.5px;font-weight:600;">' + esc(r.status) + '</span></td></tr>';
                });
                html += '</tbody></table>';
            }
            $('#guestDetailContent').html(html);
        },
        error: function() { $('#guestDetailContent').html('<p style="color:#c0392b;">Failed to load guest details.</p>'); }
    });
}
function closeGuestDetailModal() { $('#guestDetailModal').removeClass('show'); }
function openEditGuestModal(id) {
    var g = allGuests.find(function(x){ return x.id === id; });
    if (!g) return;
    $('#editGuestForm')[0].reset(); $('#editGuestAlertBox').hide();
    $('#editGuestId').val(g.id); $('#egFullName').val(g.fullName); $('#egMobile').val(g.mobileNumber);
    $('#egEmail').val(g.email || ''); $('#egNic').val(g.nicNumber || ''); $('#egAddress').val(g.address || ''); $('#egNotes').val(g.notes || '');
    $('#editGuestModal').addClass('show');
}
function closeEditGuestModal() { $('#editGuestModal').removeClass('show'); }
function saveEditGuest() {
    var id = parseInt($('#editGuestId').val());
    var fullName = $.trim($('#egFullName').val()), mobile = $.trim($('#egMobile').val());
    if (!fullName || !mobile) { $('#editGuestAlertBox').show().text('Full name and mobile are required.'); return; }
    var $btn = $('#btnSaveEditGuest').prop('disabled', true).text('Saving\u2026');
    $.ajax({
        url: guestApiBase, type: 'POST', dataType: 'json',
        data: { action:'update', id:id, fullName:fullName, mobileNumber:mobile, email:$.trim($('#egEmail').val()), address:$.trim($('#egAddress').val()), nicNumber:$.trim($('#egNic').val()), notes:$.trim($('#egNotes').val()) },
        success: function(res) {
            $btn.prop('disabled', false).text('\u2713 Save Changes');
            if (res.success) { closeEditGuestModal(); showAlert('success', '\u2713 ' + res.message); loadGuests(); }
            else $('#editGuestAlertBox').show().text(res.message);
        },
        error: function() { $btn.prop('disabled', false).text('\u2713 Save Changes'); $('#editGuestAlertBox').show().text('Server error.'); }
    });
}
var deleteGuestTargetId = null;
function openDeleteGuestModal(id, name) { deleteGuestTargetId = id; $('#deleteGuestLabel').text(name); $('#deleteGuestModal').addClass('show'); }
function closeDeleteGuestModal() { $('#deleteGuestModal').removeClass('show'); deleteGuestTargetId = null; }
function confirmDeleteGuest() {
    if (!deleteGuestTargetId) return;
    var $btn = $('#btnConfirmDeleteGuest').prop('disabled', true).text('Deleting\u2026');
    $.ajax({
        url: guestApiBase, type: 'POST', dataType: 'json',
        data: { action:'delete', id:deleteGuestTargetId },
        success: function(res) {
            $btn.prop('disabled', false).text('Delete Guest');
            if (res.success) { closeDeleteGuestModal(); showAlert('success', '\u2713 ' + res.message); loadGuests(); }
            else { closeDeleteGuestModal(); showAlert('error', res.message); }
        },
        error: function() { $btn.prop('disabled', false).text('Delete Guest'); closeDeleteGuestModal(); showAlert('error', 'Failed to delete guest.'); }
    });
}

// ── Staff ──────────────────────────────────────────────────────────────────────
function loadStaff() {
    $.ajax({
        url: userApiBase, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success) { allStaff = res.users; $('#statStaff').text(allStaff.length); renderStaffTable(); }
            else showAlert('error', 'Failed to load staff: ' + res.message);
        },
        error: function() { $('#staffTableContainer').html('<div class="empty-state"><p>Failed to load staff data.</p></div>'); }
    });
}
function applyStaffFilter(f) {
    activeStaffFilter = f;
    $('#staffFilterAll,#staffFilterManager,#staffFilterReception').removeClass('active');
    if (f === 'all')       $('#staffFilterAll').addClass('active');
    if (f === 'manager')   $('#staffFilterManager').addClass('active');
    if (f === 'reception') $('#staffFilterReception').addClass('active');
    renderStaffTable();
}
function renderStaffTable() {
    var search = ($('#staffSearchInput').val() || '').toLowerCase();
    var filtered = allStaff.filter(function(u) {
        var mRole   = activeStaffFilter === 'all' || u.role === activeStaffFilter;
        var mSearch = !search || u.fullName.toLowerCase().includes(search) || u.username.toLowerCase().includes(search) || (u.email && u.email.toLowerCase().includes(search));
        return mRole && mSearch;
    });
    if (!filtered.length) { $('#staffTableContainer').html('<div class="empty-state"><div class="es-icon">&#128100;</div><p>No staff members found.</p></div>'); return; }
    var rows = filtered.map(function(u, i) {
        var initials = getInitials(u.fullName);
        var roleCls  = u.role === 'manager' ? '' : ' reception';
        var badgeCls = u.role === 'manager' ? 'badge-manager' : 'badge-reception';
        var roleLabel = u.role.charAt(0).toUpperCase() + u.role.slice(1);
        return '<tr><td>' + (i+1) + '</td>' +
            '<td><div class="user-cell"><div class="avatar' + roleCls + '">' + esc(initials) + '</div>' +
                 '<div class="user-info"><div class="name">' + esc(u.fullName) + '</div><div class="uname">@' + esc(u.username) + '</div></div></div></td>' +
            '<td>' + (u.email ? esc(u.email) : '<span style="color:#b0c8d4">\u2014</span>') + '</td>' +
            '<td><span class="badge ' + badgeCls + '">' + roleLabel + '</span></td>' +
            '<td><button class="btn-edit" onclick="openEditStaffModal(' + u.id + ')">Edit</button>' +
                 '<button class="btn-delete" onclick="openDeleteStaffModal(' + u.id + ',\'' + esc(u.fullName) + '\')">Delete</button></td></tr>';
    }).join('');
    $('#staffTableContainer').html(
        '<table><thead><tr><th>#</th><th>Staff Member</th><th>Email</th><th>Role</th><th>Actions</th></tr></thead><tbody>' + rows + '</tbody></table>'
    );
}
function openEditStaffModal(id) {
    var u = allStaff.find(function(x){ return x.id === id; });
    if (!u) return;
    $('#editStaffId').val(u.id); $('#editStaffFullName').val(u.fullName); $('#editStaffEmail').val(u.email || '');
    $('#editStaffUsername').val(u.username); $('#editStaffRole').val(u.role); $('#editStaffPassword').val('');
    $('#editStaffAlertBox').hide(); $('#editStaffModal').addClass('show');
}
function closeEditStaffModal() { $('#editStaffModal').removeClass('show'); $('#editStaffAlertBox').hide(); }
function saveStaffEdit() {
    var id = $('#editStaffId').val(), fullName = $.trim($('#editStaffFullName').val()), username = $.trim($('#editStaffUsername').val());
    var email = $.trim($('#editStaffEmail').val()), role = $('#editStaffRole').val(), password = $.trim($('#editStaffPassword').val());
    $('#editStaffAlertBox').hide();
    if (!fullName || !username) { showModalAlert('editStaffAlertBox', 'Full name and username are required.'); return; }
    if (password && password.length < 6) { showModalAlert('editStaffAlertBox', 'Password must be at least 6 characters.'); return; }
    var $btn = $('#btnSaveStaffEdit').prop('disabled', true).text('Saving\u2026');
    $.ajax({
        url: userApiBase, type: 'POST', dataType: 'json',
        data: { action:'update', id:id, fullName:fullName, email:email, username:username, role:role, password:password },
        success: function(res) {
            if (res.success) { closeEditStaffModal(); showAlert('success', '\u2713 ' + res.message); loadStaff(); }
            else showModalAlert('editStaffAlertBox', res.message);
            $btn.prop('disabled', false).text('Save Changes');
        },
        error: function(xhr) {
            var msg = 'Failed to update user.';
            try { msg = JSON.parse(xhr.responseText).message || msg; } catch(e) {}
            showModalAlert('editStaffAlertBox', msg); $btn.prop('disabled', false).text('Save Changes');
        }
    });
}
function openDeleteStaffModal(id, name) { $('#deleteStaffTargetId').val(id); $('#deleteStaffTargetName').text(name); $('#deleteStaffModal').addClass('show'); }
function closeDeleteStaffModal() { $('#deleteStaffModal').removeClass('show'); }
function confirmDeleteStaff() {
    var id = $('#deleteStaffTargetId').val();
    var $btn = $('#btnConfirmDelStaff').prop('disabled', true).text('Deleting\u2026');
    $.ajax({
        url: userApiBase, type: 'POST', dataType: 'json',
        data: { action:'delete', id:id },
        success: function(res) {
            closeDeleteStaffModal();
            if (res.success) { showAlert('success', '\u2713 ' + res.message); loadStaff(); } else showAlert('error', res.message);
            $btn.prop('disabled', false).text('Yes, Delete');
        },
        error: function(xhr) {
            closeDeleteStaffModal();
            var msg = 'Failed to delete user.'; try { msg = JSON.parse(xhr.responseText).message || msg; } catch(e) {}
            showAlert('error', msg); $btn.prop('disabled', false).text('Yes, Delete');
        }
    });
}

// ── Backdrop click closes any open modal ─────────────────────────────────────
$('.modal-overlay').on('click', function(e) {
    if ($(e.target).hasClass('modal-overlay')) {
        closeAddModal(); closeDetailModal(); closeBillModal();
        closeEditResModal(); closeCancelResModal();
        closeAddRoomModal(); closeEditRoomModal(); closeDeleteRoomModal();
        closeRegisterGuestModal(); closeGuestDetailModal(); closeEditGuestModal(); closeDeleteGuestModal();
        closeEditStaffModal(); closeDeleteStaffModal();
    }
});

// ── Init ──────────────────────────────────────────────────────────────────────
$(document).ready(function() {
    loadReservations();
    loadRooms();
    loadGuests();
    loadStaff();
    // Auto-refresh every 60 s so scheduler-driven changes appear automatically
    setInterval(function() { loadReservations(); loadRooms(); }, 60000);
});
</script>
</body>
</html>

