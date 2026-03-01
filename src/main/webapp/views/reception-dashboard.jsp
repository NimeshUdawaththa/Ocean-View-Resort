<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    if (!"reception".equals(session.getAttribute("role"))) {
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
    <title>Reception Dashboard | OceanView Resort</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif; background:#f0f6fa; min-height:100vh; color:#1e3a4a; }

        /* Navbar */
        nav { background:linear-gradient(135deg,#0a4f6e,#1aa3c8); padding:0 32px; height:64px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 2px 12px rgba(0,50,80,.25); position:sticky; top:0; z-index:900; }
        .nav-brand { display:flex; align-items:center; gap:10px; color:white; font-size:20px; font-weight:700; }
        .nav-brand span { font-size:26px; }
        .nav-right { display:flex; align-items:center; gap:10px; }
        .nav-user { color:rgba(255,255,255,.9); font-size:13.5px; text-align:right; }
        .nav-user strong { display:block; font-size:14.5px; color:white; }
        .btn-nav { background:rgba(255,255,255,.15); color:white; border:1px solid rgba(255,255,255,.3); padding:8px 18px; border-radius:8px; cursor:pointer; font-size:13px; font-weight:600; text-decoration:none; transition:background .2s; }
        .btn-nav:hover { background:rgba(255,255,255,.28); }
        .btn-nav-add { background:white; color:#0a4f6e; border:none; padding:9px 18px; border-radius:8px; font-size:13px; font-weight:700; cursor:pointer; transition:all .2s; }
        .btn-nav-add:hover { background:#e6f7fd; }
        .btn-nav-guest { background:rgba(255,255,255,.22); color:white; border:1px solid rgba(255,255,255,.4); padding:9px 18px; border-radius:8px; font-size:13px; font-weight:700; cursor:pointer; transition:all .2s; }
        .btn-nav-guest:hover { background:rgba(255,255,255,.32); }

        /* Layout */
        main { max-width:1200px; margin:32px auto; padding:0 24px; }
        .welcome { margin-bottom:24px; }
        .welcome h1 { font-size:22px; font-weight:700; color:#0a4f6e; }
        .welcome p  { color:#7a95a8; font-size:14px; margin-top:4px; }

        /* Stats */
        .stats { display:grid; grid-template-columns:repeat(5,1fr); gap:14px; margin-bottom:28px; }
        .stat-card { background:white; border-radius:14px; padding:18px 20px; box-shadow:0 3px 14px rgba(0,50,80,.08); display:flex; align-items:center; gap:14px; }
        .stat-icon { width:46px; height:46px; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0; }
        .stat-info .val { font-size:24px; font-weight:800; color:#0a4f6e; }
        .stat-info .lbl { font-size:12px; color:#8aacbc; margin-top:2px; font-weight:600; }

        /* Alert */
        .alert { display:none; padding:12px 16px; border-radius:10px; font-size:14px; font-weight:500; margin-bottom:18px; }
        .alert-success { background:#e8f8f0; color:#1e8449; border:1px solid #b8e8ce; }
        .alert-error   { background:#fde8e8; color:#c0392b; border:1px solid #f5c6c6; }

        /* Tabs */
        .tab-nav { display:flex; gap:4px; margin-bottom:22px; background:white; padding:6px; border-radius:14px; box-shadow:0 3px 14px rgba(0,50,80,.07); width:fit-content; }
        .tab-btn { padding:9px 26px; border:none; border-radius:10px; background:transparent; font-size:13.5px; font-weight:600; color:#5a8099; cursor:pointer; transition:all .2s; }
        .tab-btn.active { background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; box-shadow:0 3px 10px rgba(13,122,154,.3); }
        .tab-btn:hover:not(.active) { background:#f0f6fa; color:#0a4f6e; }
        .tab-pane { display:none; }
        .tab-pane.active { display:block; }

        /* Table card */
        .table-card { background:white; border-radius:16px; box-shadow:0 4px 20px rgba(0,50,80,.09); overflow:hidden; margin-bottom:24px; }
        .table-toolbar { padding:16px 22px; border-bottom:1px solid #e8f0f4; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px; }
        .toolbar-title { font-size:15px; font-weight:700; color:#0a4f6e; }
        .toolbar-actions { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
        .search-box { position:relative; min-width:200px; }
        .search-box input { width:100%; padding:9px 14px 9px 36px; border:2px solid #dce8ee; border-radius:8px; font-size:13.5px; color:#1e3a4a; background:#f6fafc; outline:none; transition:border-color .25s; }
        .search-box input:focus { border-color:#1aa3c8; background:white; }
        .search-icon { position:absolute; left:11px; top:50%; transform:translateY(-50%); color:#8aacbc; font-size:14px; }

        table { width:100%; border-collapse:collapse; }
        thead th { padding:11px 16px; text-align:left; font-size:11.5px; font-weight:700; color:#7a95a8; text-transform:uppercase; letter-spacing:.5px; background:#f6fafc; border-bottom:2px solid #e8f0f4; white-space:nowrap; }
        tbody tr { border-bottom:1px solid #eef4f7; transition:background .15s; cursor:pointer; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:#f0f9ff; }
        tbody td { padding:12px 16px; font-size:13.5px; vertical-align:middle; }

        /* Badges */
        .badge { display:inline-block; padding:4px 11px; border-radius:20px; font-size:11.5px; font-weight:700; }
        .badge-active     { background:#e8f8ee; color:#1b6b33; }
        .badge-checkedout { background:#e6f7fd; color:#0a4f6e; }
        .badge-checkin    { background:#fff8e1; color:#e65100; }
        .badge-cancelled  { background:#fde8e8; color:#c0392b; }
        .btn-checkin  { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fff3cd; color:#856404; transition:all .2s; margin-right:3px; }
        .btn-checkin:hover  { background:#ffc107; color:#1a1a1a; }
        .btn-checkout { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#d1ecf1; color:#0c5460; transition:all .2s; margin-right:3px; }
        .btn-checkout:hover { background:#17a2b8; color:white; }
        .btn-view   { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e6f7fd; color:#0a4f6e; transition:all .2s; margin-right:3px; }
        .btn-view:hover   { background:#1aa3c8; color:white; }
        .btn-bill   { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e8f8ee; color:#1b6b33; transition:all .2s; margin-right:3px; }
        .btn-bill:hover   { background:#34a853; color:white; }
        .btn-edit   { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fff3e0; color:#b7690a; transition:all .2s; margin-right:3px; }
        .btn-edit:hover   { background:#f59f00; color:white; }
        .btn-cancel-res { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#fde8e8; color:#c0392b; transition:all .2s; margin-right:3px; }
        .btn-cancel-res:hover { background:#e04b3a; color:white; }
        .btn-guest-view { padding:5px 12px; border-radius:7px; font-size:12px; font-weight:600; border:none; cursor:pointer; background:#e6f7fd; color:#0a4f6e; transition:all .2s; margin-right:3px; }
        .btn-guest-view:hover { background:#1aa3c8; color:white; }

        /* Primary/secondary buttons */
        .btn-primary   { display:inline-flex; align-items:center; gap:7px; padding:9px 20px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; border:none; border-radius:9px; font-size:13.5px; font-weight:700; cursor:pointer; box-shadow:0 4px 12px rgba(13,122,154,.28); transition:transform .2s; }
        .btn-primary:hover { transform:translateY(-2px); }
        .btn-secondary { display:inline-flex; align-items:center; gap:7px; padding:9px 20px; background:linear-gradient(135deg,#1b6b33,#34a853); color:white; border:none; border-radius:9px; font-size:13.5px; font-weight:700; cursor:pointer; box-shadow:0 4px 12px rgba(52,168,83,.28); transition:transform .2s; }
        .btn-secondary:hover { transform:translateY(-2px); }

        /* Filter bar */
        .filter-bar { display:flex; gap:8px; margin-bottom:16px; flex-wrap:wrap; }
        .filter-btn { padding:6px 16px; border-radius:20px; border:2px solid #dce8ee; background:white; font-size:13px; font-weight:600; color:#3a5a6e; cursor:pointer; transition:all .2s; }
        .filter-btn.active,.filter-btn:hover { border-color:#1aa3c8; background:#e6f7fd; color:#0a4f6e; }

        /* Empty state */
        .empty-state { text-align:center; padding:60px 20px; color:#9ab4c2; }
        .empty-state .es-icon { font-size:48px; margin-bottom:12px; }

        /* Modals */
        .modal-overlay { display:none; position:fixed; inset:0; background:rgba(10,40,60,.5); z-index:1000; align-items:center; justify-content:center; }
        .modal-overlay.show { display:flex; }
        .modal { background:white; border-radius:18px; padding:32px 34px 28px; width:100%; max-width:580px; box-shadow:0 20px 60px rgba(0,30,60,.3); animation:mIn .25s ease; max-height:92vh; overflow-y:auto; }
        .modal-lg { max-width:680px; }
        .modal-sm { max-width:440px; }
        @keyframes mIn { from{transform:translateY(-16px);opacity:0} to{transform:translateY(0);opacity:1} }
        .modal-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:20px; }
        .modal-header h2 { font-size:18px; font-weight:700; color:#0a4f6e; }
        .btn-close { background:none; border:none; font-size:20px; color:#8aacbc; cursor:pointer; padding:4px; transition:color .2s; line-height:1; }
        .btn-close:hover { color:#e04b3a; }

        .fg { margin-bottom:14px; }
        .fg label { display:block; font-size:11.5px; font-weight:700; color:#3a5a6e; margin-bottom:5px; text-transform:uppercase; letter-spacing:.4px; }
        .fg input,.fg select,.fg textarea { width:100%; padding:10px 13px; border:2px solid #dce8ee; border-radius:9px; font-size:14px; color:#1e3a4a; background:#f6fafc; outline:none; font-family:inherit; transition:border-color .25s; }
        .fg input:focus,.fg select:focus,.fg textarea:focus { border-color:#1aa3c8; background:white; }
        .fg textarea { resize:vertical; min-height:64px; }
        .req { color:#e04b3a; }
        .form-row2 { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        .form-row3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:12px; }
        .modal-alert { display:none; padding:9px 13px; border-radius:8px; font-size:13.5px; margin-bottom:14px; }
        .modal-alert-error   { background:#fde8e8; color:#c0392b; border:1px solid #f5c6c6; }
        .modal-alert-success { background:#e8f8f0; color:#1e8449; border:1px solid #b8e8ce; }
        .modal-footer { display:flex; gap:10px; justify-content:flex-end; margin-top:20px; }
        .btn-mcancel { padding:10px 22px; border:2px solid #dce8ee; border-radius:9px; background:white; color:#3a5a6e; font-size:14px; font-weight:600; cursor:pointer; transition:border-color .2s; }
        .btn-mcancel:hover { border-color:#1aa3c8; }
        .btn-msave { padding:10px 24px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; border:none; border-radius:9px; font-size:14px; font-weight:700; cursor:pointer; box-shadow:0 4px 14px rgba(13,122,154,.3); transition:transform .2s; }
        .btn-msave:hover { transform:translateY(-1px); }
        .btn-msave:disabled { opacity:.65; cursor:not-allowed; transform:none; }
        .btn-mgreen { padding:10px 24px; background:linear-gradient(135deg,#1b6b33,#34a853); color:white; border:none; border-radius:9px; font-size:14px; font-weight:700; cursor:pointer; box-shadow:0 4px 14px rgba(52,168,83,.3); transition:transform .2s; }
        .btn-mgreen:hover { transform:translateY(-1px); }
        .btn-mgreen:disabled { opacity:.65; cursor:not-allowed; transform:none; }
        .btn-mdanger { padding:10px 24px; background:linear-gradient(135deg,#c0392b,#e04b3a); color:white; border:none; border-radius:9px; font-size:14px; font-weight:700; cursor:pointer; box-shadow:0 4px 14px rgba(192,57,43,.3); transition:transform .2s; }
        .btn-mdanger:hover { transform:translateY(-1px); }

        /* Detail rows */
        .detail-row { display:flex; border-bottom:1px solid #eef4f7; padding:10px 0; }
        .detail-row:last-child { border-bottom:none; }
        .detail-label { width:150px; font-size:13px; font-weight:700; color:#7a95a8; flex-shrink:0; }
        .detail-value { font-size:13.5px; color:#1e3a4a; }

        /* Guest lookup */
        .lookup-strip { display:flex; gap:8px; margin-bottom:14px; }
        .lookup-strip input { flex:1; padding:10px 13px; border:2px solid #dce8ee; border-radius:9px; font-size:14px; color:#1e3a4a; background:#f6fafc; outline:none; transition:border-color .25s; }
        .lookup-strip input:focus { border-color:#1aa3c8; background:white; }
        .btn-lookup { padding:10px 18px; background:#e6f7fd; color:#0a4f6e; border:none; border-radius:9px; font-size:13.5px; font-weight:700; cursor:pointer; transition:all .2s; white-space:nowrap; }
        .btn-lookup:hover { background:#1aa3c8; color:white; }
        .lookup-found { background:#e8f8f0; border:1px solid #b8e8ce; border-radius:9px; padding:10px 14px; margin-bottom:14px; font-size:13.5px; color:#1b6b33; display:none; }

        /* Bill */
        .bill-header-box { text-align:center; padding:18px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); border-radius:10px; color:white; margin-bottom:20px; }
        .bill-header-box h3 { font-size:18px; font-weight:700; }
        .bill-header-box p  { font-size:13px; opacity:.85; margin-top:3px; }
        .bill-table { width:100%; border-collapse:collapse; margin-bottom:12px; }
        .bill-table td { padding:8px 4px; font-size:13.5px; border-bottom:1px solid #eef4f7; }
        .bill-table tr:last-child td { border-bottom:none; }
        .bill-table .lbl { color:#7a95a8; }
        .bill-table .val { text-align:right; font-weight:600; color:#1e3a4a; }
        .bill-total-row td { font-size:15px; font-weight:800; color:#0a4f6e; border-top:2px solid #0a4f6e; padding-top:12px; }
        .btn-print { padding:10px 24px; background:linear-gradient(135deg,#1e8449,#34a853); color:white; border:none; border-radius:9px; font-size:14px; font-weight:700; cursor:pointer; box-shadow:0 4px 14px rgba(52,168,83,.3); transition:transform .2s; }
        .btn-print:hover { transform:translateY(-1px); }

        /* Guest history */
        .history-table { width:100%; border-collapse:collapse; font-size:13px; margin-top:6px; }
        .history-table th { padding:8px 10px; background:#f6fafc; font-size:11.5px; font-weight:700; color:#7a95a8; text-transform:uppercase; letter-spacing:.4px; border-bottom:2px solid #e8f0f4; }
        .history-table td { padding:8px 10px; border-bottom:1px solid #eef4f7; }
        .history-table tr:last-child td { border-bottom:none; }

        /* Cancel warning */
        .cancel-warning { background:#fff3e0; border:1px solid #f5c6a0; border-radius:10px; padding:14px 16px; margin-bottom:16px; font-size:14px; color:#b7690a; }

        /* Section separator */
        .section-sep { font-size:11px; font-weight:700; color:#8aacbc; text-transform:uppercase; letter-spacing:.6px; margin:16px 0 10px; border-bottom:1px solid #e8f0f4; padding-bottom:4px; }

        @media(max-width:900px){ .stats{grid-template-columns:repeat(3,1fr);} }
        @media(max-width:640px){ .stats{grid-template-columns:1fr 1fr;} .form-row2{grid-template-columns:1fr;} .form-row3{grid-template-columns:1fr;} }
        @media(max-width:420px){ .stats{grid-template-columns:1fr;} }
    </style>
</head>
<body>

<nav>
    <div class="nav-brand"><span>&#9875;</span> OceanView Resort</div>
    <div class="nav-right">
        <div class="nav-user">
            <strong><%= fullName != null ? fullName : "Staff" %></strong>
            Front Desk
        </div>
        <button class="btn-nav-guest" onclick="openRegisterGuestModal()">&#43; Register Guest</button>
        <button class="btn-nav-add"   onclick="openAddResModal(null)">&#43; New Reservation</button>
        <a href="<%= request.getContextPath() %>/api/logout" class="btn-nav">Logout</a>
    </div>
</nav>

<main>
    <div class="welcome">
        <h1>Welcome, <%= fullName != null ? fullName : "Staff" %> &#128075;</h1>
        <p>Front Desk &mdash; manage reservations and guest records.</p>
    </div>

    <div class="stats">
        <div class="stat-card">
            <div class="stat-icon" style="background:#e6f7fd;">&#128197;</div>
            <div class="stat-info"><div class="val" id="statTotal">&#8211;</div><div class="lbl">All Reservations</div></div>
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
            <div class="stat-icon" style="background:#f3e8ff;">&#128100;</div>
            <div class="stat-info"><div class="val" id="statGuests">&#8211;</div><div class="lbl">Registered Guests</div></div>
        </div>
    </div>

    <div id="alertBox" class="alert"></div>

    <div class="tab-nav">
        <button class="tab-btn active" onclick="switchTab('res',this)">&#128203; Reservations</button>
        <button class="tab-btn"        onclick="switchTab('guests',this)">&#128100; Guests</button>
        <button class="tab-btn"        onclick="switchTab('rooms',this)">&#127968; Rooms</button>
    </div>

    <!-- RESERVATIONS TAB -->
    <div class="tab-pane active" id="tab-res">
        <div class="filter-bar">
            <button class="filter-btn active" onclick="setFilter('all',this)">All</button>
            <button class="filter-btn" onclick="setFilter('active',this)">Active</button>
            <button class="filter-btn" onclick="setFilter('checked_in',this)">Checked In</button>
            <button class="filter-btn" onclick="setFilter('checked_out',this)">Checked Out</button>
            <button class="filter-btn" onclick="setFilter('cancelled',this)">Cancelled</button>
        </div>
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#128203; All Reservations</div>
                <div class="toolbar-actions">
                    <div class="search-box">
                        <span class="search-icon">&#128269;</span>
                        <input type="text" id="resSearch" placeholder="Search guest, res #, contact&#8230;" oninput="renderResTable()" />
                    </div>
                    <button class="btn-primary" onclick="openAddResModal(null)">&#43; New Reservation</button>
                </div>
            </div>
            <div id="resTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading reservations&#8230;</p></div>
            </div>
        </div>
    </div>

    <!-- GUESTS TAB -->
    <div class="tab-pane" id="tab-guests">
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#128100; Registered Guests</div>
                <div class="toolbar-actions">
                    <div class="search-box">
                        <span class="search-icon">&#128269;</span>
                        <input type="text" id="guestSearch" placeholder="Search name, mobile, NIC&#8230;" oninput="renderGuestTable()" />
                    </div>
                    <button class="btn-secondary" onclick="openRegisterGuestModal()">&#43; Register Guest</button>
                </div>
            </div>
            <div id="guestTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading guests&#8230;</p></div>
            </div>
        </div>
    </div>
    <!-- ROOMS TAB -->
    <div class="tab-pane" id="tab-rooms">
        <div class="filter-bar">
            <button class="filter-btn active" onclick="setRoomFilter('all',this)">All</button>
            <button class="filter-btn" onclick="setRoomFilter('available',this)">Available</button>
            <button class="filter-btn" onclick="setRoomFilter('occupied',this)">Occupied</button>
            <button class="filter-btn" onclick="setRoomFilter('maintenance',this)">Maintenance</button>
        </div>
        <div class="table-card">
            <div class="table-toolbar">
                <div class="toolbar-title">&#127968; All Rooms</div>
                <div class="toolbar-actions">
                    <div class="search-box">
                        <span class="search-icon">&#128269;</span>
                        <input type="text" id="roomSearch" placeholder="Search room number, type&#8230;" oninput="renderRoomsTable()" />
                    </div>
                </div>
            </div>
            <div id="roomTableContainer">
                <div class="empty-state"><div class="es-icon">&#8987;</div><p>Loading rooms&#8230;</p></div>
            </div>
        </div>
    </div>
</main>


<!-- MODAL: New Reservation -->
<div class="modal-overlay" id="addResModal">
  <div class="modal modal-lg">
    <div class="modal-header">
        <h2>&#128203; New Reservation</h2>
        <button class="btn-close" onclick="closeAddResModal()">&#10005;</button>
    </div>
    <div id="addResAlert" class="modal-alert"></div>
    <div id="arGuestLookupSection" style="background:#f0f7fb;border:1.5px solid #b8d4e8;border-radius:8px;padding:14px;margin-bottom:12px;">
        <div style="font-weight:700;color:#1a3c4e;font-size:12.5px;text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px;">&#128101; Step 1 &mdash; Find Registered Guest <span class="req">*</span></div>
        <div style="display:flex;gap:8px;">
            <input type="text" id="arResGuestSearch" placeholder="Name, mobile, email or NIC&hellip;" style="flex:1;padding:10px 13px;border:2px solid #dce8ee;border-radius:9px;font-size:14px;color:#1e3a4a;background:#f6fafc;outline:none;font-family:inherit;" onkeydown="if(event.key==='Enter')searchGuestForRes();" />
            <button class="btn-msave" style="white-space:nowrap;padding:0 16px;" onclick="searchGuestForRes()">&#128269; Find</button>
        </div>
        <div id="arGuestLookupResult" style="margin-top:8px;"></div>
    </div>
    <div id="arSelectedGuestBanner" style="display:none;background:#eaf6f0;border:1.5px solid #27ae60;border-radius:8px;padding:10px 14px;margin-bottom:12px;">
        <div style="display:flex;align-items:center;justify-content:space-between;gap:8px;">
            <div>
                <div style="font-weight:700;color:#196f3d;font-size:14px;" id="arSelectedGuestInfo"></div>
                <div style="color:#5d8a6f;font-size:12px;margin-top:2px;" id="arSelectedGuestSubInfo"></div>
            </div>
            <button onclick="clearGuestForRes()" style="background:none;border:1px solid #c0392b;color:#c0392b;cursor:pointer;font-size:12px;font-weight:600;padding:4px 10px;border-radius:5px;">Change Guest</button>
        </div>
    </div>
    <div class="section-sep">Reservation Details</div>
    <div class="form-row3">
        <div class="fg"><label>Room <span class="req">*</span></label><select id="arRoom"><option value="">Loading&#8230;</option></select></div>
        <div class="fg"><label>Check-in <span class="req">*</span></label><input type="date" id="arCheckIn" /></div>
        <div class="fg"><label>Check-out <span class="req">*</span></label><input type="date" id="arCheckOut" /></div>
    </div>
    <div class="modal-footer">
        <button class="btn-mcancel" onclick="closeAddResModal()">Cancel</button>
        <button class="btn-msave"   id="btnSaveRes" onclick="saveNewReservation()">&#128203; Create Reservation</button>
    </div>
  </div>
</div>


<!-- MODAL: Register Guest -->
<div class="modal-overlay" id="registerGuestModal">
  <div class="modal modal-lg">
    <div class="modal-header">
        <h2>&#128100; Register New Guest</h2>
        <button class="btn-close" onclick="closeRegisterGuestModal()">&#10005;</button>
    </div>
    <div id="regGuestAlert" class="modal-alert"></div>
    <div class="form-row2">
        <div class="fg"><label>Full Name <span class="req">*</span></label><input type="text" id="rgFullName" placeholder="Guest full name" /></div>
        <div class="fg"><label>Mobile Number <span class="req">*</span></label><input type="text" id="rgMobile" placeholder="+94 71 234 5678" /></div>
    </div>
    <div class="form-row2">
        <div class="fg"><label>Email Address</label><input type="email" id="rgEmail" placeholder="guest@email.com (optional)" /></div>
        <div class="fg"><label>NIC / Passport No.</label><input type="text" id="rgNic" placeholder="National ID or passport number" /></div>
    </div>
    <div class="fg"><label>Address</label><textarea id="rgAddress" placeholder="Guest address (optional)"></textarea></div>
    <div class="fg"><label>Notes</label><textarea id="rgNotes" placeholder="Any special notes (optional)"></textarea></div>
    <div class="modal-footer">
        <button class="btn-mcancel" onclick="closeRegisterGuestModal()">Cancel</button>
        <button class="btn-mgreen"  id="btnSaveGuest" onclick="saveNewGuest()">&#128100; Register Guest</button>
    </div>
  </div>
</div>


<!-- MODAL: Reservation Details -->
<div class="modal-overlay" id="detailModal">
  <div class="modal">
    <div class="modal-header">
        <h2>&#128196; Reservation Details</h2>
        <button class="btn-close" onclick="closeDetailModal()">&#10005;</button>
    </div>
    <div id="detailContent"></div>
    <div class="modal-footer">
        <button class="btn-mcancel" onclick="closeDetailModal()">Close</button>
        <button class="btn-msave"   onclick="showBillFromDetail()">&#129534; View Bill</button>
    </div>
  </div>
</div>


<!-- MODAL: Edit Reservation -->
<div class="modal-overlay" id="editResModal">
  <div class="modal">
    <div class="modal-header">
        <h2>&#9998; Edit Reservation</h2>
        <button class="btn-close" onclick="closeEditResModal()">&#10005;</button>
    </div>
    <div id="editResAlert" class="modal-alert"></div>
    <div class="form-row2">
        <div class="fg"><label>Reservation #</label><input type="text" id="erResNum" readonly style="background:#eef4f7;color:#5a8099;" /></div>
        <div class="fg"><label>Guest Name</label><input type="text" id="erGuestName" readonly style="background:#eef4f7;color:#5a8099;" /></div>
    </div>
    <div class="fg"><label>Room <span class="req">*</span></label><select id="erRoom"><option value="">Loading&#8230;</option></select></div>
    <div class="form-row2">
        <div class="fg"><label>Check-in <span class="req">*</span></label><input type="date" id="erCheckIn" /></div>
        <div class="fg"><label>Check-out <span class="req">*</span></label><input type="date" id="erCheckOut" /></div>
    </div>
    <div class="fg"><label>Address</label><textarea id="erAddress"></textarea></div>
    <input type="hidden" id="erResId" />
    <input type="hidden" id="erOldRoomId" />
    <div class="modal-footer">
        <button class="btn-mcancel"  onclick="closeEditResModal()">Cancel</button>
        <button class="btn-mdanger"  onclick="cancelFromEditModal()">&#10006; Cancel Reservation</button>
        <button class="btn-msave"    id="btnSaveEdit" onclick="saveEditReservation()">Save Changes</button>
    </div>
  </div>
</div>


<!-- MODAL: Cancel Confirmation -->
<div class="modal-overlay" id="cancelResModal">
  <div class="modal modal-sm">
    <div class="modal-header">
        <h2>&#10006; Cancel Reservation</h2>
        <button class="btn-close" onclick="closeCancelResModal()">&#10005;</button>
    </div>
    <div class="cancel-warning">&#9888; This action cannot be undone. The reservation will be permanently cancelled and the room will be freed.</div>
    <p id="cancelResLabel" style="font-size:14.5px;color:#1e3a4a;margin-bottom:4px;"></p>
    <div class="modal-footer">
        <button class="btn-mcancel"  onclick="closeCancelResModal()">Go Back</button>
        <button class="btn-mdanger"  id="btnConfirmCancel" onclick="confirmCancelReservation()">Yes, Cancel It</button>
    </div>
  </div>
</div>


<!-- MODAL: Bill -->
<div class="modal-overlay" id="billModal">
  <div class="modal" style="max-width:480px;">
    <div class="modal-header">
        <h2>&#129534; Guest Bill</h2>
        <button class="btn-close" onclick="closeBillModal()">&#10005;</button>
    </div>
    <div id="billContent"></div>
    <div class="modal-footer">
        <button class="btn-mcancel" onclick="closeBillModal()">Close</button>
        <button class="btn-print"   onclick="printBill()">&#128424; Print Bill</button>
    </div>
  </div>
</div>


<!-- MODAL: Guest Profile -->
<div class="modal-overlay" id="guestDetailModal">
  <div class="modal modal-lg">
    <div class="modal-header">
        <h2>&#128100; Guest Profile</h2>
        <button class="btn-close" onclick="closeGuestDetailModal()">&#10005;</button>
    </div>
    <div id="guestDetailContent"></div>
    <div class="modal-footer">
        <button class="btn-mcancel" onclick="closeGuestDetailModal()">Close</button>
        <button class="btn-edit"    style="padding:10px 22px;font-size:14px;" onclick="openEditGuestModal()">&#9998; Edit Guest</button>
        <button class="btn-msave"   onclick="newResFromGuest()">&#128203; New Reservation</button>
    </div>
  </div>
</div>


<!-- MODAL: Edit Guest -->
<div class="modal-overlay" id="editGuestModal">
  <div class="modal">
    <div class="modal-header">
        <h2>&#9998; Edit Guest</h2>
        <button class="btn-close" onclick="closeEditGuestModal()">&#10005;</button>
    </div>
    <div id="editGuestAlert" class="modal-alert"></div>
    <div class="form-row2">
        <div class="fg"><label>Full Name <span class="req">*</span></label><input type="text" id="egFullName" /></div>
        <div class="fg"><label>Mobile Number <span class="req">*</span></label><input type="text" id="egMobile" /></div>
    </div>
    <div class="form-row2">
        <div class="fg"><label>Email Address</label><input type="email" id="egEmail" /></div>
        <div class="fg"><label>NIC / Passport No.</label><input type="text" id="egNic" /></div>
    </div>
    <div class="fg"><label>Address</label><textarea id="egAddress"></textarea></div>
    <div class="fg"><label>Notes</label><textarea id="egNotes"></textarea></div>
    <input type="hidden" id="egId" />
    <div class="modal-footer">
        <button class="btn-mcancel" onclick="closeEditGuestModal()">Cancel</button>
        <button class="btn-msave"   id="btnSaveEditGuest" onclick="saveEditGuest()">Save Changes</button>
    </div>
  </div>
</div>


<script>
/* === GLOBALS === */
var allReservations = [];
var allGuests       = [];
var allRooms        = [];
var roomFilter      = 'all';
var cancelResTarget = null;
var selectedGuest   = null;
var guestForNewRes  = null;
var currentDetailId = null;
var currentGuestId  = null;
var resFilter       = 'all';

var apiRes    = '<%= request.getContextPath() %>/api/reservations';
var apiRooms  = '<%= request.getContextPath() %>/api/rooms';
var apiGuests = '<%= request.getContextPath() %>/api/guests';
var today     = new Date().toISOString().split('T')[0];

/* === TABS === */
function switchTab(name, btn) {
    $('.tab-pane').removeClass('active');
    $('.tab-btn').removeClass('active');
    $('#tab-' + name).addClass('active');
    $(btn).addClass('active');
    if (name === 'guests' && allGuests.length === 0) loadGuests();
    if (name === 'rooms'  && allRooms.length  === 0) loadRooms();
}

/* === STATS === */
function updateStats() {
    var tot    = allReservations.length;
    var active = allReservations.filter(function(r){ return r.status === 'active'; }).length;
    var ci     = allReservations.filter(function(r){ return r.checkInDate  === today; }).length;
    var co     = allReservations.filter(function(r){ return r.checkOutDate === today; }).length;
    $('#statTotal').text(tot); $('#statActive').text(active);
    $('#statToday').text(ci);  $('#statOut').text(co);
}

/* === ROOMS (read-only) === */
function loadRooms() {
    $.ajax({ url: apiRooms, type:'GET', dataType:'json',
        success: function(res) {
            if (res.success) { allRooms = res.rooms || []; renderRoomsTable(); }
            else showAlert('error', res.message);
        },
        error: function(){ showAlert('error','Failed to load rooms.'); }
    });
}

function setRoomFilter(f, btn) {
    roomFilter = f;
    $('.filter-bar .filter-btn', $('#tab-rooms')).removeClass('active');
    $(btn).addClass('active');
    renderRoomsTable();
}

function renderRoomsTable() {
    var q = ($('#roomSearch').val()||'').toLowerCase();
    var list = allRooms.filter(function(r){
        if (roomFilter !== 'all' && r.status !== roomFilter) return false;
        return !q || (r.roomNumber||'').toLowerCase().includes(q) ||
               (r.roomType||'').toLowerCase().includes(q) ||
               (r.description||'').toLowerCase().includes(q);
    });

    if (!list.length) {
        $('#roomTableContainer').html('<div class="empty-state"><div class="es-icon">&#127968;</div><p>No rooms found.</p></div>');
        return;
    }

    var rows = list.map(function(r, i) {
        var badge = r.status === 'available'   ? 'badge-active' :
                    r.status === 'occupied'    ? 'badge-cancelled' : 'badge-checkedout';
        return '<tr>' +
            '<td>'+(i+1)+'</td>' +
            '<td><strong>'+esc(r.roomNumber)+'</strong></td>' +
            '<td>'+esc(r.roomType)+'</td>' +
            '<td>'+esc(r.floor)+'</td>' +
            '<td>'+esc(r.description||'\u2014')+'</td>' +
            '<td><strong>$'+esc(r.ratePerNight)+'</strong></td>' +
            '<td><span class="badge '+badge+'">'+esc(r.status)+'</span></td>' +
            '</tr>';
    }).join('');

    $('#roomTableContainer').html(
        '<table><thead><tr><th>#</th><th>Room No.</th><th>Type</th><th>Floor</th>' +
        '<th>Description</th><th>Rate/Night</th><th>Status</th></tr></thead>' +
        '<tbody>'+rows+'</tbody></table>'
    );
}

/* === RESERVATIONS === */
function loadReservations() {
    $.ajax({ url:apiRes, type:'GET', dataType:'json',
        success: function(res) {
            if (res.success) { allReservations = res.reservations; updateStats(); renderResTable(); }
            else showAlert('error', res.message);
        },
        error: function(){ showAlert('error','Failed to load reservations.'); }
    });
}

function setFilter(f, btn) {
    resFilter = f;
    $('.filter-btn').removeClass('active'); $(btn).addClass('active');
    renderResTable();
}

function renderResTable() {
    var q = ($('#resSearch').val()||'').toLowerCase();
    var list = allReservations.filter(function(r){
        if (resFilter !== 'all' && r.status !== resFilter) return false;
        return !q || r.guestName.toLowerCase().includes(q) ||
               r.reservationNumber.toLowerCase().includes(q) ||
               (r.contactNumber||'').includes(q) ||
               (r.roomType||'').toLowerCase().includes(q);
    });

    if (!list.length) {
        $('#resTableContainer').html('<div class="empty-state"><div class="es-icon">&#128197;</div><p>No reservations found.</p></div>');
        return;
    }

    var rows = list.map(function(r, i) {
        var badge = r.status === 'active' ? 'badge-active' :
                    r.status === 'checked_in' ? 'badge-checkin' :
                    r.status === 'checked_out' ? 'badge-checkedout' : 'badge-cancelled';
        var actBtns =
            (r.status === 'active' ? '<button class="btn-checkin" onclick="event.stopPropagation();doCheckIn('+r.id+')">&#10003; Check In</button>' : '') +
            (r.status === 'checked_in' ? '<button class="btn-checkout" onclick="event.stopPropagation();doCheckOut('+r.id+')">&#10004; Check Out</button>' : '') +
            (r.status === 'active' ? '<button class="btn-edit" onclick="event.stopPropagation();openEditResModal(' + r.id + ')">&#9998; Edit</button>' : '');
        return '<tr onclick="openDetailModal(' + r.id + ')">' +
            '<td>'+(i+1)+'</td>' +
            '<td><strong>'+esc(r.reservationNumber)+'</strong></td>' +
            '<td>'+esc(r.guestName)+'</td>' +
            '<td>'+esc(r.roomType)+'</td>' +
            '<td>'+esc(r.checkInDate)+'</td>' +
            '<td>'+esc(r.checkOutDate)+'</td>' +
            '<td><span class="badge '+badge+'">'+esc(r.status)+'</span></td>' +
            '<td><strong>$'+esc(r.totalAmount)+'</strong></td>' +
            '<td>'+esc(r.createdByName||'&#8212;')+'</td>' +
            '<td onclick="event.stopPropagation()">' +
              '<button class="btn-view" onclick="openDetailModal('+r.id+')">Details</button>' +
              '<button class="btn-bill" onclick="openBillModal('+r.id+')">Bill</button>' +
              actBtns +
            '</td></tr>';
    }).join('');

    $('#resTableContainer').html(
        '<table><thead><tr><th>#</th><th>Res #</th><th>Guest</th><th>Room</th>' +
        '<th>Check-in</th><th>Check-out</th><th>Status</th><th>Total</th>' +
        '<th>Created By</th><th>Actions</th></tr></thead>' +
        '<tbody>'+rows+'</tbody></table>'
    );
}

/* === NEW RESERVATION MODAL === */
function openAddResModal(g) {
    selectedGuest = null; window._arGuestSearchResults = [];
    $('#addResAlert').hide();
    $('#arResGuestSearch').val(''); $('#arGuestLookupResult').html('');
    $('#arSelectedGuestBanner').hide(); $('#arGuestLookupSection').show();
    $('#arCheckIn').val(today); $('#arCheckOut').val('');
    loadAvailableRooms('#arRoom', null);
    if (g && g.id) setTimeout(function(){ selectGuestForRes(g.id); }, 80);
    $('#addResModal').addClass('show');
}
function closeAddResModal() { $('#addResModal').removeClass('show'); selectedGuest = null; }

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
    var q = $.trim($('#arResGuestSearch').val());
    if (!q) { $('#arGuestLookupResult').html('<span style="color:#c0392b;font-size:13px;">Please enter a name, mobile, email or NIC.</span>'); return; }
    $('#arGuestLookupResult').html('<span style="color:#8aacbc;font-size:13px;">Searching…</span>');
    $.ajax({ url: apiGuests + '?keyword=' + encodeURIComponent(q), type:'GET', dataType:'json',
        success: function(res) {
            if (res.success && res.guests && res.guests.length) {
                window._arGuestSearchResults = res.guests;
                if (res.guests.length === 1) {
                    $('#arGuestLookupResult').html(buildGuestResultCard(res.guests[0]));
                } else {
                    var html = '<div style="font-size:12px;color:#5d7a8a;margin-bottom:6px;">' + res.guests.length + ' guests found:</div><div style="max-height:210px;overflow-y:auto;">';
                    res.guests.forEach(function(g){ html += buildGuestResultCard(g); });
                    html += '</div>';
                    $('#arGuestLookupResult').html(html);
                }
            } else {
                window._arGuestSearchResults = [];
                $('#arGuestLookupResult').html(
                    '<div style="background:#fdf2f0;border:1.5px solid #e74c3c;border-radius:7px;padding:10px 12px;">' +
                    '<div style="color:#c0392b;font-weight:600;font-size:13px;">&#10006; No registered guest found.</div>' +
                    '<div style="color:#888;font-size:12px;margin-top:3px;">Register the guest first before creating a reservation.</div></div>'
                );
            }
        },
        error: function(){ $('#arGuestLookupResult').html('<span style="color:#c0392b;font-size:13px;">Server error. Please try again.</span>'); }
    });
}

function selectGuestForRes(id) {
    var list = window._arGuestSearchResults || [], g = null;
    for (var i = 0; i < list.length; i++) { if (list[i].id === id) { g = list[i]; break; } }
    if (!g) { for (var j = 0; j < allGuests.length; j++) { if (allGuests[j].id === id) { g = allGuests[j]; break; } } }
    if (!g) return;
    selectedGuest = g;
    $('#arGuestLookupSection').hide();
    $('#arSelectedGuestInfo').text('\u2713 ' + g.fullName);
    $('#arSelectedGuestSubInfo').text(g.mobileNumber + (g.email ? '  |  ' + g.email : '') + (g.nicNumber ? '  |  NIC: ' + g.nicNumber : ''));
    $('#arSelectedGuestBanner').show(); $('#addResAlert').hide();
}

function clearGuestForRes() {
    selectedGuest = null; window._arGuestSearchResults = [];
    $('#arResGuestSearch').val(''); $('#arGuestLookupResult').html('');
    $('#arSelectedGuestBanner').hide(); $('#arGuestLookupSection').show();
}

function loadAvailableRooms(selector, currentRoomId) {
    var $sel = $(selector).html('<option value="">Loading rooms&#8230;</option>').prop('disabled',true);
    $.ajax({ url: apiRooms + '?status=available', type:'GET', dataType:'json',
        success: function(res) {
            $sel.prop('disabled',false);
            if (res.success && res.rooms && res.rooms.length) {
                var opts = '<option value="">-- Select a room --</option>';
                res.rooms.forEach(function(r) {
                    var sel = (currentRoomId && r.id == currentRoomId) ? ' selected' : '';
                    opts += '<option value="'+r.id+'" data-roomtype="'+esc(r.roomType)+'"'+sel+'>' +
                            'Room '+esc(r.roomNumber)+' \u2013 '+esc(r.roomType)+
                            ' ($'+esc(r.ratePerNight)+'/night)</option>';
                });
                $sel.html(opts);
            } else {
                $sel.html('<option value="">No available rooms</option>');
            }
        },
        error: function(){ $sel.prop('disabled',false).html('<option value="">Failed to load rooms</option>'); }
    });
}

function saveNewReservation() {
    if (!selectedGuest) { showModalAlert('addResAlert','Please find and select a registered guest first.'); return; }
    var roomId   = $('#arRoom').val();
    var roomType = $('#arRoom option:selected').data('roomtype');
    var checkIn  = $('#arCheckIn').val();
    var checkOut = $('#arCheckOut').val();
    if (!roomId || !checkIn || !checkOut) { showModalAlert('addResAlert','Please select a room and set check-in / check-out dates.'); return; }
    if (checkOut <= checkIn) { showModalAlert('addResAlert','Check-out date must be after check-in date.'); return; }

    var $btn = $('#btnSaveRes').prop('disabled',true).text('Creating\u2026');
    $.ajax({ url:apiRes, type:'POST', dataType:'json',
        data:{ action:'add', guestName:selectedGuest.fullName, contactNumber:selectedGuest.mobileNumber,
               address:selectedGuest.address || '', roomType:roomType, roomId:roomId,
               checkIn:checkIn, checkOut:checkOut },
        success: function(res) {
            if (res.success) {
                closeAddResModal();
                showAlert('success','\u2713 '+res.message);
                loadReservations();
                if (res.bill) setTimeout(function(){ showBillData(res.bill); }, 350);
            } else { showModalAlert('addResAlert', res.message); }
            $btn.prop('disabled',false).text('Create Reservation');
        },
        error: function(xhr) {
            var msg = 'Failed to create reservation.';
            try{ msg = JSON.parse(xhr.responseText).message || msg; }catch(e){}
            showModalAlert('addResAlert', msg);
            $btn.prop('disabled',false).text('Create Reservation');
        }
    });
}

/* === REGISTER GUEST MODAL === */
function openRegisterGuestModal() {
    $('#regGuestAlert').hide();
    $('#rgFullName,#rgMobile,#rgEmail,#rgNic,#rgAddress,#rgNotes').val('');
    $('#registerGuestModal').addClass('show');
}
function closeRegisterGuestModal() { $('#registerGuestModal').removeClass('show'); }

function saveNewGuest() {
    var fullName = $.trim($('#rgFullName').val());
    var mobile   = $.trim($('#rgMobile').val());
    if (!fullName || !mobile) {
        showModalAlert('regGuestAlert','Full name and mobile number are required.'); return;
    }

    var $btn = $('#btnSaveGuest').prop('disabled',true).text('Registering\u2026');
    $.ajax({ url:apiGuests, type:'POST', dataType:'json',
        data:{ action:'register', fullName:fullName, mobileNumber:mobile,
               email:$.trim($('#rgEmail').val()), nicNumber:$.trim($('#rgNic').val()),
               address:$.trim($('#rgAddress').val()), notes:$.trim($('#rgNotes').val()) },
        success: function(res) {
            if (res.success) {
                closeRegisterGuestModal();
                showAlert('success','\u2713 '+res.message);
                loadGuests();
            } else { showModalAlert('regGuestAlert', res.message); }
            $btn.prop('disabled',false).text('Register Guest');
        },
        error: function(xhr) {
            var msg = 'Failed to register guest.';
            try{ msg = JSON.parse(xhr.responseText).message || msg; }catch(e){}
            showModalAlert('regGuestAlert', msg);
            $btn.prop('disabled',false).text('Register Guest');
        }
    });
}

/* === RESERVATION DETAILS === */
function openDetailModal(id) {
    currentDetailId = id;
    $.ajax({ url:apiRes+'?id='+id, type:'GET', dataType:'json',
        success: function(res) {
            if (res.success) { renderDetailContent(res.reservation); $('#detailModal').addClass('show'); }
            else showAlert('error', res.message);
        }
    });
}
function closeDetailModal() { $('#detailModal').removeClass('show'); }

function renderDetailContent(r) {
    var badge = r.status === 'active' ? 'badge-active' :
                r.status === 'checked_in' ? 'badge-checkin' :
                r.status === 'checked_out' ? 'badge-checkedout' : 'badge-cancelled';
    var actionBtns = r.status === 'active' ? '<button class="btn-checkin" onclick="closeDetailModal();doCheckIn('+r.id+')">&#10003; Check In</button>' :
                     r.status === 'checked_in' ? '<button class="btn-checkout" onclick="closeDetailModal();doCheckOut('+r.id+')">&#10004; Check Out</button>' : '';
    $('#detailContent').html(
        drow('Reservation #','<strong>'+esc(r.reservationNumber)+'</strong>') +
        drow('Status','<span class="badge '+badge+'">'+esc(r.status)+'</span>') +
        drow('Guest Name', esc(r.guestName)) +
        drow('Contact',    esc(r.contactNumber)) +
        drow('Address',    esc(r.address)||'\u2014') +
        drow('Room Type',  esc(r.roomType)) +
        drow('Check-in',   esc(r.checkInDate)) +
        drow('Check-out',  esc(r.checkOutDate)) +
        drow('Total',      '<strong>$'+esc(r.totalAmount)+'</strong>') +
        drow('Created By', esc(r.createdByName||'\u2014')) +
        drow('Created At', esc(r.createdAt)) +
        (actionBtns ? '<div style="margin-top:16px;text-align:right;">' + actionBtns + '</div>' : '')
    );
}

function showBillFromDetail() {
    closeDetailModal();
    if (currentDetailId) openBillModal(currentDetailId);
}
function doCheckIn(id) {
    $.ajax({ url: apiRes, type: 'POST', dataType: 'json', data: { action: 'checkin', id: id },
        success: function(res) {
            if (res.success) { showAlert('success', '\u2713 ' + res.message); loadReservations(); }
            else showAlert('error', res.message);
        }
    });
}
function doCheckOut(id) {
    $.ajax({ url: apiRes, type: 'POST', dataType: 'json', data: { action: 'checkout', id: id },
        success: function(res) {
            if (res.success) { showAlert('success', '\u2713 ' + res.message); loadReservations(); loadRooms(); }
            else showAlert('error', res.message);
        }
    });
}
function openEditResModal(id) {
    $.ajax({ url:apiRes+'?id='+id, type:'GET', dataType:'json',
        success: function(res) {
            if (!res.success) { showAlert('error', res.message); return; }
            var r = res.reservation;
            $('#erResId').val(r.id);
            $('#erResNum').val(r.reservationNumber);
            $('#erGuestName').val(r.guestName);
            $('#erCheckIn').val(r.checkInDate);
            $('#erCheckOut').val(r.checkOutDate);
            $('#erAddress').val(r.address||'');
            $('#erOldRoomId').val(r.roomId);
            $('#editResAlert').hide();
            loadAvailableRooms('#erRoom', r.roomId);
            $('#editResModal').addClass('show');
        }
    });
}
function closeEditResModal() { $('#editResModal').removeClass('show'); }

function saveEditReservation() {
    var id       = $('#erResId').val();
    var checkIn  = $('#erCheckIn').val();
    var checkOut = $('#erCheckOut').val();
    var address  = $.trim($('#erAddress').val());
    var newRoom  = $('#erRoom').val();
    var oldRoom  = $('#erOldRoomId').val();
    var roomType = $('#erRoom option:selected').data('roomtype')||'';

    if (!checkIn || !checkOut || !newRoom) { showModalAlert('editResAlert','Room, check-in and check-out are required.'); return; }
    if (checkOut <= checkIn) { showModalAlert('editResAlert','Check-out must be after check-in.'); return; }

    var $btn = $('#btnSaveEdit').prop('disabled',true).text('Saving\u2026');
    $.ajax({ url:apiRes, type:'POST', dataType:'json',
        data:{ action:'update', id:id, checkIn:checkIn, checkOut:checkOut,
               address:address, roomType:roomType, newRoomId:newRoom, oldRoomId:oldRoom },
        success: function(res) {
            if (res.success) { closeEditResModal(); showAlert('success','\u2713 Reservation updated.'); loadReservations(); }
            else { showModalAlert('editResAlert', res.message); }
            $btn.prop('disabled',false).text('Save Changes');
        },
        error: function(xhr) {
            var msg='Failed to update.';
            try{ msg=JSON.parse(xhr.responseText).message||msg; }catch(e){}
            showModalAlert('editResAlert', msg);
            $btn.prop('disabled',false).text('Save Changes');
        }
    });
}

/* === CANCEL RESERVATION === */
function openCancelResModal(id, resNum) {
    cancelResTarget = { id:id, resNum:resNum };
    $('#cancelResLabel').text('Reservation: ' + resNum);
    $('#cancelResModal').addClass('show');
}
function closeCancelResModal() { $('#cancelResModal').removeClass('show'); cancelResTarget = null; }

function cancelFromEditModal() {
    var id = $('#erResId').val(), resNum = $('#erResNum').val();
    closeEditResModal();
    setTimeout(function(){ openCancelResModal(id, resNum); }, 200);
}

function confirmCancelReservation() {
    if (!cancelResTarget) return;
    var $btn = $('#btnConfirmCancel').prop('disabled',true).text('Cancelling\u2026');
    $.ajax({ url:apiRes, type:'POST', dataType:'json',
        data:{ action:'cancel', id: cancelResTarget.id },
        success: function(res) {
            closeCancelResModal();
            showAlert(res.success ? 'success' : 'error', res.message);
            if (res.success) loadReservations();
            $btn.prop('disabled',false).text('Yes, Cancel It');
        },
        error: function(){ showAlert('error','Failed to cancel reservation.'); $btn.prop('disabled',false).text('Yes, Cancel It'); }
    });
}

/* === BILL === */
function openBillModal(id) {
    $.ajax({ url:apiRes+'?action=bill&id='+id, type:'GET', dataType:'json',
        success: function(res) {
            if (res.success) showBillData(res.bill);
            else showAlert('error', res.message);
        }
    });
}
function closeBillModal() { $('#billModal').removeClass('show'); }

function printBill() {
    var c = document.getElementById('billContent').innerHTML;
    var w = window.open('','_blank','width=800,height=900');
    w.document.write('<!DOCTYPE html><html><head><title>OceanView \u2013 Bill</title>' +
        '<style>body{font-family:Arial,sans-serif;padding:48px 56px;color:#1e3a4a;}' +
        '.bill-header-box{text-align:center;padding:28px;background:linear-gradient(135deg,#0a4f6e,#1aa3c8);border-radius:12px;color:white;margin-bottom:32px;}' +
        '.bill-header-box h3{font-size:26px;font-weight:700;margin:0;}' +
        '.bill-header-box p{font-size:16px;opacity:.85;margin-top:6px;}' +
        '.bill-table{width:100%;border-collapse:collapse;margin-bottom:16px;}' +
        '.bill-table td{padding:12px 8px;font-size:16px;border-bottom:1px solid #eef4f7;}' +
        '.bill-table .lbl{color:#7a95a8;}.bill-table .val{text-align:right;font-weight:600;}' +
        '.bill-total-row td{font-size:19px;font-weight:800;color:#0a4f6e;border-top:2px solid #0a4f6e;padding-top:16px;}' +
        '</style></head><body>'+c+'</body></html>');
    w.document.close(); w.focus(); w.print(); w.close();
}

function showBillData(b) {
    $('#billContent').html(
        '<div class="bill-header-box"><h3>&#9875; OceanView Resort</h3><p>Guest Bill &amp; Invoice</p></div>' +
        '<table class="bill-table">' +
        '<tr><td class="lbl">Reservation No.</td><td class="val">'+esc(b.reservationNumber)+'</td></tr>' +
        '<tr><td class="lbl">Guest Name</td><td class="val">'+esc(b.guestName)+'</td></tr>' +
        '<tr><td class="lbl">Address</td><td class="val">'+(esc(b.address)||'\u2014')+'</td></tr>' +
        '<tr><td class="lbl">Contact</td><td class="val">'+esc(b.contactNumber)+'</td></tr>' +
        '<tr><td class="lbl">Room Type</td><td class="val">'+esc(b.roomType)+'</td></tr>' +
        '<tr><td class="lbl">Check-in</td><td class="val">'+esc(b.checkInDate)+'</td></tr>' +
        '<tr><td class="lbl">Check-out</td><td class="val">'+esc(b.checkOutDate)+'</td></tr>' +
        '<tr><td class="lbl">Nights</td><td class="val">'+b.nights+'</td></tr>' +
        '<tr><td class="lbl">Rate/Night</td><td class="val">$'+b.ratePerNight+'</td></tr>' +
        '<tr><td class="lbl">Subtotal</td><td class="val">$'+b.subtotal+'</td></tr>' +
        '<tr><td class="lbl">Tax ('+b.taxRate+')</td><td class="val">$'+b.tax+'</td></tr>' +
        '<tr class="bill-total-row"><td class="lbl">TOTAL</td><td class="val">$'+b.total+'</td></tr>' +
        '</table>'
    );
    $('#billModal').addClass('show');
}

/* === GUESTS === */
function loadGuests() {
    $.ajax({ url:apiGuests, type:'GET', dataType:'json',
        success: function(res) {
            if (res.success) { allGuests = res.guests||[]; $('#statGuests').text(allGuests.length); renderGuestTable(); }
            else showAlert('error', res.message);
        },
        error: function(){ showAlert('error','Failed to load guests.'); }
    });
}

function renderGuestTable() {
    var q = ($('#guestSearch').val()||'').toLowerCase();
    var list = allGuests.filter(function(g){
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
        return '<tr onclick="openGuestDetailModal('+g.id+')">' +
            '<td>'+(i+1)+'</td>' +
            '<td><strong>'+esc(g.fullName)+'</strong></td>' +
            '<td>'+esc(g.mobileNumber)+'</td>' +
            '<td>'+esc(g.email||'\u2014')+'</td>' +
            '<td>'+esc(g.nicNumber||'\u2014')+'</td>' +
            '<td>'+esc(g.address||'\u2014')+'</td>' +
            '<td onclick="event.stopPropagation()">' +
              '<button class="btn-guest-view" onclick="openGuestDetailModal('+g.id+')">Profile</button>' +
              '<button class="btn-primary" style="padding:5px 12px;font-size:12px;box-shadow:none;" onclick="event.stopPropagation();newResForGuest('+g.id+')">&#128203; Reserve</button>' +
            '</td></tr>';
    }).join('');

    $('#guestTableContainer').html(
        '<table><thead><tr><th>#</th><th>Full Name</th><th>Mobile</th>' +
        '<th>Email</th><th>NIC / Passport</th><th>Address</th><th>Actions</th>' +
        '</tr></thead><tbody>'+rows+'</tbody></table>'
    );
}

/* === GUEST DETAIL MODAL === */
function openGuestDetailModal(id) {
    $.ajax({ url:apiGuests+'?id='+id, type:'GET', dataType:'json',
        success: function(res) {
            if (!res.success) { showAlert('error', res.message); return; }
            var g   = res.guest;
            var his = res.reservations || [];
            guestForNewRes = { fullName:g.fullName, mobile:g.mobileNumber, address:g.address };
            currentGuestId = g.id;

            var info =
                drow('Full Name',     '<strong>'+esc(g.fullName)+'</strong>') +
                drow('Mobile',        esc(g.mobileNumber)) +
                drow('Email',         esc(g.email||'\u2014')) +
                drow('NIC/Passport',  esc(g.nicNumber||'\u2014')) +
                drow('Address',       esc(g.address||'\u2014')) +
                drow('Notes',         esc(g.notes||'\u2014')) +
                drow('Registered At', esc(g.createdAt));

            var histHtml = '';
            if (his.length) {
                var hrows = his.map(function(r){
                    var b = r.status==='active'?'badge-active':r.status==='checked_out'?'badge-checkedout':'badge-cancelled';
                    return '<tr><td>'+esc(r.reservationNumber)+'</td><td>'+esc(r.roomType)+'</td>' +
                           '<td>'+esc(r.checkInDate)+'</td><td>'+esc(r.checkOutDate)+'</td>' +
                           '<td><span class="badge '+b+'">'+esc(r.status)+'</span></td>' +
                           '<td><strong>$'+esc(r.totalAmount)+'</strong></td></tr>';
                }).join('');
                histHtml = '<div style="margin-top:18px;"><div class="section-sep">Reservation History ('+his.length+')</div>' +
                    '<table class="history-table"><thead><tr><th>Res #</th><th>Room</th>' +
                    '<th>Check-in</th><th>Check-out</th><th>Status</th><th>Total</th>' +
                    '</tr></thead><tbody>'+hrows+'</tbody></table></div>';
            } else {
                histHtml = '<div style="margin-top:18px;"><div class="section-sep">Reservation History</div>' +
                    '<p style="color:#8aacbc;font-size:13.5px;padding:10px 0;">No reservations on record for this guest.</p></div>';
            }

            $('#guestDetailContent').html(info + histHtml);
            $('#guestDetailModal').addClass('show');
        }
    });
}
function closeGuestDetailModal() { $('#guestDetailModal').removeClass('show'); guestForNewRes = null; }

/* === EDIT GUEST === */
function openEditGuestModal() {
    if (!currentGuestId) return;
    var g = allGuests.find(function(x){ return x.id === currentGuestId; });
    if (!g) return;
    $('#egId').val(g.id);
    $('#egFullName').val(g.fullName||'');
    $('#egMobile').val(g.mobileNumber||'');
    $('#egEmail').val(g.email||'');
    $('#egNic').val(g.nicNumber||'');
    $('#egAddress').val(g.address||'');
    $('#egNotes').val(g.notes||'');
    $('#editGuestAlert').hide();
    closeGuestDetailModal();
    setTimeout(function(){ $('#editGuestModal').addClass('show'); }, 200);
}
function closeEditGuestModal() { $('#editGuestModal').removeClass('show'); }

function saveEditGuest() {
    var id       = $('#egId').val();
    var fullName = $.trim($('#egFullName').val());
    var mobile   = $.trim($('#egMobile').val());
    if (!fullName || !mobile) { showModalAlert('editGuestAlert','Full name and mobile number are required.'); return; }

    var $btn = $('#btnSaveEditGuest').prop('disabled',true).text('Saving\u2026');
    $.ajax({ url:apiGuests, type:'POST', dataType:'json',
        data:{ action:'update', id:id, fullName:fullName, mobileNumber:mobile,
               email:$.trim($('#egEmail').val()), nicNumber:$.trim($('#egNic').val()),
               address:$.trim($('#egAddress').val()), notes:$.trim($('#egNotes').val()) },
        success: function(res) {
            if (res.success) {
                closeEditGuestModal();
                showAlert('success','\u2713 '+res.message);
                loadGuests();
            } else { showModalAlert('editGuestAlert', res.message); }
            $btn.prop('disabled',false).text('Save Changes');
        },
        error: function(xhr) {
            var msg='Failed to update guest.';
            try{ msg=JSON.parse(xhr.responseText).message||msg; }catch(e){}
            showModalAlert('editGuestAlert', msg);
            $btn.prop('disabled',false).text('Save Changes');
        }
    });
}

function newResFromGuest() {
    var id = currentGuestId;
    closeGuestDetailModal();
    setTimeout(function(){
        openAddResModal(null);
        if (id) setTimeout(function(){ selectGuestForRes(id); }, 100);
    }, 200);
}

function newResForGuest(id) {
    openAddResModal(null);
    setTimeout(function(){ selectGuestForRes(id); }, 100);
}

/* === HELPERS === */
function drow(label, value) {
    return '<div class="detail-row"><div class="detail-label">'+label+'</div><div class="detail-value">'+value+'</div></div>';
}
function esc(s) {
    return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function showAlert(type, msg) {
    $('#alertBox').removeClass('alert-success alert-error')
        .addClass(type==='success'?'alert-success':'alert-error')
        .html(msg).stop(true).fadeIn(200);
    if (type==='success') setTimeout(function(){ $('#alertBox').fadeOut(400); }, 4500);
}
function showModalAlert(id, msg) {
    $('#'+id).removeClass('modal-alert-error modal-alert-success')
        .addClass('modal-alert modal-alert-error').html(msg).show();
}

/* Backdrop close */
$('.modal-overlay').on('click', function(e) {
    if (!$(e.target).hasClass('modal-overlay')) return;
    closeAddResModal(); closeDetailModal(); closeBillModal();
    closeEditResModal(); closeCancelResModal();
    closeRegisterGuestModal(); closeGuestDetailModal(); closeEditGuestModal();
});

$(document).ready(function() {
    loadReservations();
    loadGuests();
    setInterval(loadReservations, 60000);
});
</script>
</body>
</html>