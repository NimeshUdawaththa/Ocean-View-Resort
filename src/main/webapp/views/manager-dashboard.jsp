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
        nav { background:linear-gradient(135deg,#0a4f6e,#1aa3c8); padding:0 32px; height:64px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 2px 12px rgba(0,50,80,.25); }
        .nav-brand { display:flex; align-items:center; gap:10px; color:white; font-size:20px; font-weight:700; }
        .nav-brand span { font-size:26px; }
        .nav-right { display:flex; align-items:center; gap:12px; }
        .nav-user { color:rgba(255,255,255,.9); font-size:14px; text-align:right; }
        .nav-user strong { display:block; font-size:15px; color:white; }
        .btn-nav { background:rgba(255,255,255,.15); color:white; border:1px solid rgba(255,255,255,.3); padding:8px 18px; border-radius:8px; cursor:pointer; font-size:13.5px; font-weight:600; text-decoration:none; transition:background .2s; }
        .btn-nav:hover { background:rgba(255,255,255,.28); }
        .btn-nav-primary { background:rgba(255,255,255,.9); color:#0a4f6e; border:none; padding:9px 20px; border-radius:8px; font-size:13.5px; font-weight:700; cursor:pointer; text-decoration:none; transition:all .2s; }
        .btn-nav-primary:hover { background:white; }

        main { max-width:1100px; margin:36px auto; padding:0 24px; }

        /* Welcome */
        .welcome { margin-bottom:28px; }
        .welcome h1 { font-size:22px; font-weight:700; color:#0a4f6e; }
        .welcome p  { color:#7a95a8; font-size:14px; margin-top:4px; }

        /* Stats */
        .stats { display:grid; grid-template-columns:repeat(auto-fit,minmax(170px,1fr)); gap:16px; margin-bottom:28px; }
        .stat-card { background:white; border-radius:14px; padding:20px 22px; box-shadow:0 3px 14px rgba(0,50,80,.08); display:flex; align-items:center; gap:16px; }
        .stat-icon { width:50px; height:50px; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0; }
        .stat-info .val { font-size:26px; font-weight:800; color:#0a4f6e; }
        .stat-info .lbl { font-size:12.5px; color:#8aacbc; margin-top:2px; }

        /* Quick Actions */
        .section-title { font-size:14px; font-weight:700; color:#7a95a8; text-transform:uppercase; letter-spacing:.6px; margin-bottom:14px; }
        .action-cards { display:flex; gap:14px; flex-wrap:wrap; margin-bottom:30px; }
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

        table { width:100%; border-collapse:collapse; }
        thead th { padding:12px 16px; text-align:left; font-size:12px; font-weight:700; color:#7a95a8; text-transform:uppercase; letter-spacing:.5px; background:#f6fafc; border-bottom:2px solid #e8f0f4; white-space:nowrap; }
        tbody tr { border-bottom:1px solid #eef4f7; transition:background .15s; cursor:pointer; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:#f0f9ff; }
        tbody td { padding:12px 16px; font-size:13.5px; vertical-align:middle; }

        .badge { display:inline-block; padding:4px 11px; border-radius:20px; font-size:12px; font-weight:700; }
        .badge-active     { background:#e8f8ee; color:#1b6b33; }
        .badge-checkedout { background:#e6f7fd; color:#0a4f6e; }
        .badge-cancelled  { background:#fde8e8; color:#c0392b; }

        .btn-view { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e6f7fd; color:#0a4f6e; transition:all .2s; margin-right:4px; }
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
        .rooms-section { margin-top:30px; }
        .section-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:14px; flex-wrap:wrap; gap:10px; }
        .section-header .section-title { margin-bottom:0; }

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

        @media print {
            nav, .action-cards, .filter-bar, #alertBox, .table-card, .modal-footer, .btn-close, .no-print { display:none !important; }
            .modal-overlay { position:static; background:none; }
            .modal { box-shadow:none; padding:0; max-height:none; }
        }
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
    </div>

    <!-- Rooms Section -->
    <div class="rooms-section">
        <div class="section-header">
            <div class="section-title">&#127968; Rooms</div>
            <button class="btn-add-res" onclick="openAddRoomModal()">&#43; Add Room</button>
        </div>
        <div class="table-card">
            <div id="roomTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading rooms…</p></div>
            </div>
        </div>
    </div>

    <!-- Filter tabs -->

    <div class="filter-bar">
        <button class="filter-btn active" id="filterAll"      onclick="applyFilter('all')">All</button>
        <button class="filter-btn"         id="filterActive"  onclick="applyFilter('active')">Active</button>
        <button class="filter-btn"         id="filterToday"   onclick="applyFilter('today')">Today's Check-ins</button>
    </div>

    <div id="alertBox" class="alert"></div>

    <!-- Reservations table -->
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
</main>

<!-- ── Add Reservation Modal ── -->
<div class="modal-overlay" id="addModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#128203; New Reservation</h2>
            <button class="btn-close no-print" onclick="closeAddModal()">&#10005;</button>
        </div>
        <div id="addAlertBox" class="modal-alert"></div>
        <form id="addForm" novalidate>
            <div class="fg"><label>Guest Name <span class="req">*</span></label><input type="text" id="guestName" placeholder="Full name of guest" /></div>
            <div class="form-row2">
                <div class="fg"><label>Contact Number <span class="req">*</span></label><input type="text" id="contactNumber" placeholder="e.g. +94 71 234 5678" /></div>
                <div class="fg">
                    <label>Room <span class="req">*</span></label>
                    <select id="roomType">
                        <option value="">Loading available rooms…</option>
                    </select>
                </div>
            </div>
            <div class="fg"><label>Address</label><textarea id="address" placeholder="Guest address (optional)"></textarea></div>
            <div class="form-row2">
                <div class="fg"><label>Check-in Date <span class="req">*</span></label><input type="date" id="checkIn" /></div>
                <div class="fg"><label>Check-out Date <span class="req">*</span></label><input type="date" id="checkOut" /></div>
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
        <div class="modal-footer no-print">
            <button class="btn-mcancel" onclick="closeBillModal()">Close</button>
            <button class="btn-print" onclick="window.print()">&#128424; Print Bill</button>
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

<script>
var allReservations = [];
var activeFilter    = 'all';
var currentDetailId = null;
var apiBase     = '<%= request.getContextPath() %>/api/reservations';
var roomApiBase = '<%= request.getContextPath() %>/api/rooms';
var today       = new Date().toISOString().split('T')[0];
var allRooms         = [];
var deleteRoomTarget = null;

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

// ── Filter ──────────────────────────────────────────────────────────────────
function applyFilter(f) {
    activeFilter = f;
    $('.filter-btn').removeClass('active');
    if (f === 'all')    $('#filterAll').addClass('active');
    if (f === 'active') $('#filterActive').addClass('active');
    if (f === 'today')  $('#filterToday').addClass('active');
    renderTable();
}

// ── Render table ─────────────────────────────────────────────────────────────
function renderTable() {
    var q = ($('#searchInput').val() || '').toLowerCase();
    var list = allReservations.filter(function(r) {
        var matchFilter = activeFilter === 'all' ||
            (activeFilter === 'active' && r.status === 'active') ||
            (activeFilter === 'today'  && r.checkInDate === today);
        var matchSearch = !q || r.guestName.toLowerCase().includes(q) ||
            r.reservationNumber.toLowerCase().includes(q) || r.roomType.toLowerCase().includes(q);
        return matchFilter && matchSearch;
    });

    if (!list.length) {
        $('#tableContainer').html('<div class="empty-state"><div class="es-icon">&#128100;</div><p>No reservations found.</p></div>');
        return;
    }
    var rows = list.map(function(r, i) {
        var badge = r.status === 'active' ? 'badge-active' : r.status === 'checked_out' ? 'badge-checkedout' : 'badge-cancelled';
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
    var $sel = $('#roomType');
    $sel.html('<option value="">Loading available rooms…</option>').prop('disabled', true);
    $.ajax({
        url: roomApiBase + '?status=available', type: 'GET', dataType: 'json',
        success: function(res) {
            $sel.prop('disabled', false);
            if (res.success && res.rooms.length) {
                var opts = '<option value="">-- Select a room --</option>';
                res.rooms.forEach(function(r) {
                    opts += '<option value="' + esc(r.roomType) + '">' +
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

function saveReservation() {
    var guestName     = $.trim($('#guestName').val());
    var contactNumber = $.trim($('#contactNumber').val());
    var roomType      = $('#roomType').val();
    var address       = $.trim($('#address').val());
    var checkIn       = $('#checkIn').val();
    var checkOut      = $('#checkOut').val();

    $('#addAlertBox').hide();
    if (!guestName || !contactNumber || !roomType || !checkIn || !checkOut) {
        showModalAlert('addAlertBox', 'Please fill in all required fields.'); return;
    }
    if (checkOut <= checkIn) {
        showModalAlert('addAlertBox', 'Check-out must be after check-in.'); return;
    }

    var $btn = $('#btnSaveRes');
    $btn.prop('disabled', true).text('Creating…');

    $.ajax({
        url: apiBase, type: 'POST',
        data: { action: 'add', guestName: guestName, contactNumber: contactNumber,
                roomType: roomType, address: address, checkIn: checkIn, checkOut: checkOut },
        dataType: 'json',
        success: function(res) {
            if (res.success) {
                closeAddModal();
                showAlert('success', '✓ ' + res.message);
                loadReservations();
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
    var html = '<div>' +
        row('Reservation #', '<strong>' + esc(r.reservationNumber) + '</strong>') +
        row('Status', '<span class="badge ' + (r.status === 'active' ? 'badge-active' : 'badge-checkedout') + '">' + esc(r.status) + '</span>') +
        row('Guest Name',   esc(r.guestName)) +
        row('Contact',      esc(r.contactNumber)) +
        row('Address',      esc(r.address) || '—') +
        row('Room Type',    esc(r.roomType)) +
        row('Check-in',     esc(r.checkInDate)) +
        row('Check-out',    esc(r.checkOutDate)) +
        row('Total Amount', '<strong>$' + esc(r.totalAmount) + '</strong>') +
        row('Created By',   esc(r.createdByName)) +
        row('Created At',   esc(r.createdAt)) +
    '</div>';
    $('#detailContent').html(html);
}

function showBillFromDetail() {
    closeDetailModal();
    if (currentDetailId) openBillModal(currentDetailId);
}

// ── Bill Modal ───────────────────────────────────────────────────────────────
function openBillModal(id) {
    $.ajax({
        url: apiBase + '?action=bill&id=' + id, type: 'GET', dataType: 'json',
        success: function(res) {
            if (res.success) showBillData(res.bill);
            else showAlert('error', res.message);
        }
    });
}
function closeBillModal() { $('#billModal').removeClass('show'); }

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
$('.modal-overlay').on('click', function(e) {
    if ($(e.target).hasClass('modal-overlay')) {
        closeAddModal(); closeDetailModal(); closeBillModal();
    }
});

$(document).ready(function() { loadReservations(); loadRooms(); });
</script>
</body>
</html>
