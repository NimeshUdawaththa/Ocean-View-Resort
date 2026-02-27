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
        nav { background:linear-gradient(135deg,#0a4f6e,#1aa3c8); padding:0 32px; height:64px; display:flex; align-items:center; justify-content:space-between; box-shadow:0 2px 12px rgba(0,50,80,.25); }
        .nav-brand { display:flex; align-items:center; gap:10px; color:white; font-size:20px; font-weight:700; }
        .nav-brand span { font-size:26px; }
        .nav-right { display:flex; align-items:center; gap:14px; }
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
        .stats { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:32px; }
        .stat-card { background:white; border-radius:14px; padding:20px 22px; box-shadow:0 3px 14px rgba(0,50,80,.08); display:flex; align-items:center; gap:16px; }
        .stat-icon { width:50px; height:50px; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0; }
        .stat-info .val { font-size:26px; font-weight:800; color:#0a4f6e; }
        .stat-info .lbl { font-size:12.5px; color:#8aacbc; margin-top:2px; }

        /* Alert */
        .alert { display:none; padding:12px 16px; border-radius:10px; font-size:14px; font-weight:500; margin-bottom:18px; }
        .alert-success { background:#e8f8f0; color:#1e8449; border:1px solid #b8e8ce; }
        .alert-error   { background:#fde8e8; color:#c0392b; border:1px solid #f5c6c6; }

        /* Table card */
        .table-card { background:white; border-radius:16px; box-shadow:0 4px 20px rgba(0,50,80,.09); overflow:hidden; }
        .table-toolbar { padding:18px 22px; border-bottom:1px solid #e8f0f4; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px; }
        .toolbar-title { font-size:16px; font-weight:700; color:#0a4f6e; }
        .search-box { position:relative; min-width:200px; max-width:280px; }
        .search-box input { width:100%; padding:9px 14px 9px 38px; border:2px solid #dce8ee; border-radius:8px; font-size:14px; color:#1e3a4a; background:#f6fafc; outline:none; transition:border-color .25s; }
        .search-box input:focus { border-color:#1aa3c8; background:white; }
        .search-icon { position:absolute; left:11px; top:50%; transform:translateY(-50%); color:#8aacbc; }
        .btn-add-res { display:inline-flex; align-items:center; gap:7px; padding:10px 20px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; border:none; border-radius:9px; font-size:13.5px; font-weight:700; cursor:pointer; box-shadow:0 4px 12px rgba(13,122,154,.3); transition:transform .2s; }
        .btn-add-res:hover { transform:translateY(-2px); }

        table { width:100%; border-collapse:collapse; }
        thead th { padding:12px 16px; text-align:left; font-size:12px; font-weight:700; color:#7a95a8; text-transform:uppercase; letter-spacing:.5px; background:#f6fafc; border-bottom:2px solid #e8f0f4; }
        tbody tr { border-bottom:1px solid #eef4f7; transition:background .15s; cursor:pointer; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:#f0f9ff; }
        tbody td { padding:13px 16px; font-size:14px; vertical-align:middle; }

        .badge { display:inline-block; padding:4px 11px; border-radius:20px; font-size:12px; font-weight:700; }
        .badge-active   { background:#e8f8ee; color:#1b6b33; }
        .badge-checkedout { background:#e6f7fd; color:#0a4f6e; }
        .badge-cancelled { background:#fde8e8; color:#c0392b; }

        .btn-view { padding:5px 13px; border-radius:7px; font-size:12.5px; font-weight:600; border:none; cursor:pointer; background:#e6f7fd; color:#0a4f6e; transition:all .2s; margin-right:4px; }
        .btn-view:hover { background:#1aa3c8; color:white; }
        .btn-bill { padding:5px 13px; border-radius:7px; font-size:12.5px; font-weight:600; border:none; cursor:pointer; background:#e8f8ee; color:#1b6b33; transition:all .2s; }
        .btn-bill:hover { background:#34a853; color:white; }

        .empty-state { text-align:center; padding:60px 20px; color:#9ab4c2; }
        .empty-state .es-icon { font-size:48px; margin-bottom:12px; }

        /* ── Modals ── */
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
        .btn-cancel { padding:10px 22px; border:2px solid #dce8ee; border-radius:9px; background:white; color:#3a5a6e; font-size:14px; font-weight:600; cursor:pointer; transition:border-color .2s; }
        .btn-cancel:hover { border-color:#1aa3c8; }
        .btn-save { padding:10px 24px; background:linear-gradient(135deg,#0a4f6e,#1aa3c8); color:white; border:none; border-radius:9px; font-size:14px; font-weight:700; cursor:pointer; box-shadow:0 4px 14px rgba(13,122,154,.3); transition:transform .2s; }
        .btn-save:hover { transform:translateY(-1px); }
        .btn-save:disabled { opacity:.7; cursor:not-allowed; transform:none; }

        /* Detail modal */
        .detail-row { display:flex; gap:0; border-bottom:1px solid #eef4f7; padding:10px 0; }
        .detail-row:last-child { border-bottom:none; }
        .detail-label { width:150px; font-size:13px; font-weight:700; color:#7a95a8; flex-shrink:0; }
        .detail-value { font-size:13.5px; color:#1e3a4a; }

        /* Bill modal */
        .bill-modal { max-width:480px; }
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


        @media(max-width:760px) { .stats{grid-template-columns:1fr 1fr;} .form-row2{grid-template-columns:1fr;} }
        @media(max-width:480px) { .stats{grid-template-columns:1fr;} }
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
        <button class="btn-nav-primary" onclick="openAddModal()">&#43; New Reservation</button>
        <a href="<%= request.getContextPath() %>/api/logout" class="btn-nav">Logout</a>
    </div>
</nav>

<main>
    <div class="welcome">
        <h1>Welcome, <%= fullName != null ? fullName : "Staff" %> &#128075;</h1>
        <p>Manage guest reservations from your dashboard.</p>
    </div>

    <!-- Stats -->
    <div class="stats">
        <div class="stat-card">
            <div class="stat-icon" style="background:#e6f7fd;">&#128197;</div>
            <div class="stat-info"><div class="val" id="statTotal">–</div><div class="lbl">My Reservations</div></div>
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
    </div>

    <div id="alertBox" class="alert"></div>

    <!-- Reservations table -->
    <div class="table-card">
        <div class="table-toolbar">
            <div class="toolbar-title">&#128203; My Reservations</div>
            <div class="search-box">
                <span class="search-icon">&#128269;</span>
                <input type="text" id="searchInput" placeholder="Search guest or reservation #…" oninput="renderTable()" />
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
            <button class="btn-close" onclick="closeAddModal()">&#10005;</button>
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
            <button class="btn-cancel" onclick="closeAddModal()">Cancel</button>
            <button class="btn-save" id="btnSaveRes" onclick="saveReservation()">Create Reservation</button>
        </div>
    </div>
</div>

<!-- ── View Details Modal ── -->
<div class="modal-overlay" id="detailModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#128196; Reservation Details</h2>
            <button class="btn-close" onclick="closeDetailModal()">&#10005;</button>
        </div>
        <div id="detailContent"></div>
        <div class="modal-footer no-print">
            <button class="btn-cancel" onclick="closeDetailModal()">Close</button>
            <button class="btn-save" onclick="showBillFromDetail()">&#128203; View Bill</button>
        </div>
    </div>
</div>

<!-- ── Bill Modal ── -->
<div class="modal-overlay" id="billModal">
    <div class="modal bill-modal">
        <div class="modal-header">
            <h2>&#129534; Guest Bill</h2>
            <button class="btn-close no-print" onclick="closeBillModal()">&#10005;</button>
        </div>
        <div id="billContent"></div>
        <div class="modal-footer no-print">
            <button class="btn-cancel" onclick="closeBillModal()">Close</button>
            <button class="btn-print" onclick="printBill()">&#128424; Print Bill</button>
        </div>
    </div>
</div>

<script>
var allReservations = [];
var currentDetailId = null;
var apiBase     = '<%= request.getContextPath() %>/api/reservations';
var roomApiBase = '<%= request.getContextPath() %>/api/rooms';
var today       = new Date().toISOString().split('T')[0];

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

// ── Render table ─────────────────────────────────────────────────────────────
function renderTable() {
    var q = ($('#searchInput').val() || '').toLowerCase();
    var list = allReservations.filter(function(r) {
        return !q || r.guestName.toLowerCase().includes(q) || r.reservationNumber.toLowerCase().includes(q) || r.contactNumber.includes(q);
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
            '<td onclick="event.stopPropagation()">' +
              '<button class="btn-view" onclick="openDetailModal(' + r.id + ')">Details</button>' +
              '<button class="btn-bill" onclick="openBillModal(' + r.id + ')">Bill</button>' +
            '</td>' +
        '</tr>';
    }).join('');
    $('#tableContainer').html(
        '<table><thead><tr><th>#</th><th>Res #</th><th>Guest</th><th>Room</th><th>Check-in</th><th>Check-out</th><th>Status</th><th>Total</th><th>Actions</th></tr></thead>' +
        '<tbody>' + rows + '</tbody></table>'
    );
}

// ── Add Reservation ──────────────────────────────────────────────────────────
function openAddModal() {
    $('#addForm')[0].reset();
    $('#checkIn').val(today);
    $('#addAlertBox').hide();
    // Populate available rooms dynamically
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

function saveReservation() {
    var guestName     = $.trim($('#guestName').val());
    var contactNumber = $.trim($('#contactNumber').val());
    var roomId        = $('#roomType').val();
    var roomType      = $('#roomType option:selected').data('roomtype');
    var address       = $.trim($('#address').val());
    var checkIn       = $('#checkIn').val();
    var checkOut      = $('#checkOut').val();

    $('#addAlertBox').hide();
    if (!guestName || !contactNumber || !roomId || !checkIn || !checkOut) {
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
                roomType: roomType, roomId: roomId, address: address, checkIn: checkIn, checkOut: checkOut },
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
        row('Guest Name',    esc(r.guestName)) +
        row('Contact',       esc(r.contactNumber)) +
        row('Address',       esc(r.address) || '—') +
        row('Room Type',     esc(r.roomType)) +
        row('Check-in',      esc(r.checkInDate)) +
        row('Check-out',     esc(r.checkOutDate)) +
        row('Total Amount',  '<strong>$' + esc(r.totalAmount) + '</strong>') +
        row('Created By',    esc(r.createdByName)) +
        row('Created At',    esc(r.createdAt)) +
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
            if (res.success) { showBillData(res.bill); }
            else showAlert('error', res.message);
        }
    });
}
function closeBillModal() { $('#billModal').removeClass('show'); }

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
    $('#billContent').html(html);
    $('#billModal').addClass('show');
}

// ── Helpers ───────────────────────────────────────────────────────────────────
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

$(document).ready(function() { loadReservations(); });
</script>
</body>
</html>
