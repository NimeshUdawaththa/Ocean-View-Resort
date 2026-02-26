<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    if (!"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
        return;
    }
    String adminName = (String) session.getAttribute("fullName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users | OceanView Resort</title>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
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
        .nav-brand { display: flex; align-items: center; gap: 12px; color: white; font-size: 20px; font-weight: 700; }
        .nav-brand span { font-size: 26px; }
        .nav-right { display: flex; align-items: center; gap: 14px; }
        .nav-user { color: rgba(255,255,255,.9); font-size: 14px; text-align: right; }
        .nav-user strong { display: block; font-size: 15px; color: white; }
        .btn-nav {
            background: rgba(255,255,255,.15); color: white;
            border: 1px solid rgba(255,255,255,.3);
            padding: 8px 18px; border-radius: 8px;
            cursor: pointer; font-size: 13.5px; font-weight: 600;
            text-decoration: none; transition: background .2s;
        }
        .btn-nav:hover { background: rgba(255,255,255,.28); }

        /* ── Page ── */
        main { max-width: 1050px; margin: 40px auto; padding: 0 24px; }

        .page-header {
            display: flex; align-items: center;
            justify-content: space-between;
            margin-bottom: 28px; flex-wrap: wrap; gap: 14px;
        }
        .page-header h1 { font-size: 24px; font-weight: 700; color: #0a4f6e; }
        .page-header p  { margin-top: 4px; color: #7a95a8; font-size: 14px; }

        .btn-add {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 11px 22px;
            background: linear-gradient(135deg, #0a4f6e, #1aa3c8);
            color: white; border: none; border-radius: 10px;
            font-size: 14px; font-weight: 700; cursor: pointer;
            text-decoration: none;
            box-shadow: 0 4px 14px rgba(13,122,154,.35);
            transition: transform .2s, box-shadow .2s;
        }
        .btn-add:hover { transform: translateY(-2px); box-shadow: 0 7px 20px rgba(13,122,154,.45); }

        /* ── Filter tabs ── */
        .filter-bar {
            display: flex; gap: 8px; margin-bottom: 20px; flex-wrap: wrap;
        }
        .filter-btn {
            padding: 7px 18px; border-radius: 20px;
            border: 2px solid #dce8ee; background: white;
            font-size: 13px; font-weight: 600; color: #3a5a6e;
            cursor: pointer; transition: all .2s;
        }
        .filter-btn:hover, .filter-btn.active {
            border-color: #1aa3c8; background: #e6f7fd; color: #0a4f6e;
        }
        .filter-btn.active-reception.active {
            border-color: #34a853; background: #e8f8ee; color: #1b6b33;
        }

        /* ── Alert ── */
        .alert {
            display: none; padding: 12px 16px; border-radius: 10px;
            font-size: 14px; font-weight: 500; margin-bottom: 18px;
        }
        .alert-success { background: #e8f8f0; color: #1e8449; border: 1px solid #b8e8ce; }
        .alert-error   { background: #fde8e8; color: #c0392b; border: 1px solid #f5c6c6; }

        /* ── Table card ── */
        .table-card {
            background: white; border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,50,80,.09); overflow: hidden;
        }

        .table-toolbar {
            padding: 18px 24px; border-bottom: 1px solid #e8f0f4;
            display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
        }

        .search-box {
            position: relative; flex: 1; min-width: 200px; max-width: 320px;
        }
        .search-box input {
            width: 100%; padding: 9px 14px 9px 38px;
            border: 2px solid #dce8ee; border-radius: 8px;
            font-size: 14px; color: #1e3a4a; background: #f6fafc; outline: none;
            transition: border-color .25s;
        }
        .search-box input:focus { border-color: #1aa3c8; background: #fff; }
        .search-box .s-icon {
            position: absolute; left: 11px; top: 50%;
            transform: translateY(-50%); color: #8aacbc;
        }

        .user-count { font-size: 13.5px; color: #7a95a8; font-weight: 500; }
        .user-count strong { color: #0a4f6e; }

        table { width: 100%; border-collapse: collapse; }
        thead tr { background: #f6fafc; }
        thead th {
            padding: 13px 18px; text-align: left;
            font-size: 12px; font-weight: 700; color: #7a95a8;
            text-transform: uppercase; letter-spacing: .5px;
            border-bottom: 2px solid #e8f0f4;
        }
        tbody tr { border-bottom: 1px solid #eef4f7; transition: background .15s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #f8fbfd; }
        tbody td { padding: 14px 18px; font-size: 14px; vertical-align: middle; }

        .avatar {
            width: 36px; height: 36px; border-radius: 50%;
            background: linear-gradient(135deg, #0a4f6e, #1aa3c8);
            display: inline-flex; align-items: center; justify-content: center;
            color: white; font-weight: 700; font-size: 14px; flex-shrink: 0;
        }
        .avatar.reception { background: linear-gradient(135deg, #1e8449, #34a853); }

        .user-cell { display: flex; align-items: center; gap: 12px; }
        .user-info .name { font-weight: 600; color: #1e3a4a; }
        .user-info .uname { font-size: 12.5px; color: #8aacbc; margin-top: 2px; }

        .badge {
            display: inline-block; padding: 4px 12px; border-radius: 20px;
            font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px;
        }
        .badge-manager   { background: #e6f7fd; color: #0a4f6e; }
        .badge-reception { background: #e8f8ee; color: #1b6b33; }

        .actions { display: flex; gap: 8px; }
        .btn-edit, .btn-delete {
            padding: 6px 14px; border-radius: 8px; font-size: 13px;
            font-weight: 600; cursor: pointer; border: none; transition: all .2s;
        }
        .btn-edit   { background: #e6f7fd; color: #0a4f6e; }
        .btn-edit:hover { background: #1aa3c8; color: white; }
        .btn-delete { background: #fde8e8; color: #c0392b; }
        .btn-delete:hover { background: #e04b3a; color: white; }

        .empty-state {
            text-align: center; padding: 60px 20px; color: #9ab4c2;
        }
        .empty-state .es-icon { font-size: 48px; margin-bottom: 12px; }
        .empty-state p { font-size: 15px; }

        /* ── Modal overlay ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(10,40,60,.5); z-index: 1000;
            align-items: center; justify-content: center;
        }
        .modal-overlay.show { display: flex; }

        .modal {
            background: white; border-radius: 18px;
            padding: 36px 36px 32px; width: 100%; max-width: 500px;
            box-shadow: 0 20px 60px rgba(0,30,60,.3);
            animation: slideIn .25s ease;
        }
        @keyframes slideIn {
            from { transform: translateY(-20px); opacity: 0; }
            to   { transform: translateY(0);     opacity: 1; }
        }

        .modal-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 24px;
        }
        .modal-header h2 { font-size: 20px; font-weight: 700; color: #0a4f6e; }
        .btn-close-modal {
            background: none; border: none; font-size: 22px; color: #8aacbc;
            cursor: pointer; line-height: 1; transition: color .2s; padding: 4px;
        }
        .btn-close-modal:hover { color: #e04b3a; }

        /* Modal form */
        .modal .form-group { margin-bottom: 16px; }
        .modal .form-group label {
            display: block; font-size: 12px; font-weight: 700; color: #3a5a6e;
            margin-bottom: 6px; text-transform: uppercase; letter-spacing: .4px;
        }
        .modal .form-group input,
        .modal .form-group select {
            width: 100%; padding: 11px 14px; border: 2px solid #dce8ee;
            border-radius: 10px; font-size: 14px; color: #1e3a4a; background: #f6fafc;
            outline: none; transition: border-color .25s, box-shadow .25s;
        }
        .modal .form-group input:focus,
        .modal .form-group select:focus {
            border-color: #1aa3c8; background: #fff;
            box-shadow: 0 0 0 4px rgba(26,163,200,.12);
        }
        .modal .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .modal .pw-hint  { font-size: 12px; color: #9ab4c2; margin-top: 5px; }

        .modal-alert { display:none; padding:10px 14px; border-radius:8px; font-size:13.5px; font-weight:500; margin-bottom:14px; }
        .modal-alert-error { background:#fde8e8; color:#c0392b; border:1px solid #f5c6c6; }

        .modal-footer { display: flex; gap: 10px; justify-content: flex-end; margin-top: 22px; }
        .btn-modal-cancel {
            padding: 11px 22px; border: 2px solid #dce8ee; border-radius: 10px;
            background: white; color: #3a5a6e; font-size: 14px; font-weight: 600;
            cursor: pointer; transition: border-color .2s;
        }
        .btn-modal-cancel:hover { border-color: #1aa3c8; }
        .btn-modal-save {
            padding: 11px 24px; background: linear-gradient(135deg, #0a4f6e, #1aa3c8);
            color: white; border: none; border-radius: 10px;
            font-size: 14px; font-weight: 700; cursor: pointer;
            box-shadow: 0 4px 14px rgba(13,122,154,.35);
            transition: transform .2s, box-shadow .2s;
        }
        .btn-modal-save:hover { transform: translateY(-1px); }
        .btn-modal-save:disabled { opacity: .7; cursor: not-allowed; transform: none; }

        /* ── Delete confirm modal ── */
        .del-modal { max-width: 420px; text-align: center; padding: 40px 36px; }
        .del-modal .del-icon { font-size: 50px; margin-bottom: 14px; }
        .del-modal h2 { font-size: 20px; font-weight: 700; color: #1e3a4a; margin-bottom: 8px; }
        .del-modal p  { font-size: 14.5px; color: #7a95a8; margin-bottom: 24px; }
        .del-modal .del-name { color: #0a4f6e; font-weight: 700; }
        .btn-confirm-del {
            padding: 12px 26px; background: linear-gradient(135deg, #c0392b, #e04b3a);
            color: white; border: none; border-radius: 10px;
            font-weight: 700; font-size: 14px; cursor: pointer;
            box-shadow: 0 4px 14px rgba(224,75,58,.35);
            transition: transform .2s;
        }
        .btn-confirm-del:hover { transform: translateY(-1px); }
        .btn-confirm-del:disabled { opacity: .7; cursor: not-allowed; transform: none; }

        @media (max-width: 600px) {
            .modal .form-row { grid-template-columns: 1fr; }
            .modal { padding: 28px 20px 24px; }
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
            <strong><%= adminName != null ? adminName : "Admin" %></strong>
            Admin
        </div>
        <a href="<%= request.getContextPath() %>/views/dashboard.jsp" class="btn-nav">&#8592; Dashboard</a>
        <a href="<%= request.getContextPath() %>/api/logout" class="btn-nav">Logout</a>
    </div>
</nav>

<main>
    <div class="page-header">
        <div>
            <h1>&#128101; Manage Staff</h1>
            <p>View, edit and delete Manager &amp; Reception accounts.</p>
        </div>
        <a href="<%= request.getContextPath() %>/views/add-user.jsp" class="btn-add">&#43; Add Staff</a>
    </div>

    <!-- Filter tabs -->
    <div class="filter-bar">
        <button class="filter-btn active" id="filterAll"        onclick="applyFilter('all')">All</button>
        <button class="filter-btn"        id="filterManager"    onclick="applyFilter('manager')">Managers</button>
        <button class="filter-btn active-reception" id="filterReception" onclick="applyFilter('reception')">Reception</button>
    </div>

    <!-- Alert -->
    <div id="alertBox" class="alert"></div>

    <!-- Table card -->
    <div class="table-card">
        <div class="table-toolbar">
            <div class="search-box">
                <span class="s-icon">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                    </svg>
                </span>
                <input type="text" id="searchInput" placeholder="Search by name or username..." oninput="renderTable()" />
            </div>
            <div class="user-count" id="userCount">Loading...</div>
        </div>

        <div id="tableContainer">
            <div class="empty-state">
                <div class="es-icon">&#8987;</div>
                <p>Loading staff data...</p>
            </div>
        </div>
    </div>
</main>

<!-- ── Edit Modal ── -->
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <div class="modal-header">
            <h2>&#9998; Edit Staff Account</h2>
            <button class="btn-close-modal" onclick="closeEditModal()">&#10005;</button>
        </div>
        <div id="editAlertBox" class="modal-alert"></div>
        <form id="editForm" novalidate>
            <input type="hidden" id="editId" />
            <div class="form-row">
                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" id="editFullName" placeholder="Full name" required />
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" id="editEmail" placeholder="Email address" />
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Username *</label>
                    <input type="text" id="editUsername" placeholder="Username" autocomplete="off" required />
                </div>
                <div class="form-group">
                    <label>Role *</label>
                    <select id="editRole">
                        <option value="manager">Manager</option>
                        <option value="reception">Reception</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label>New Password</label>
                <input type="password" id="editPassword" placeholder="Leave blank to keep current" autocomplete="new-password" />
                <div class="pw-hint">Only fill this if you want to change the password (min. 6 chars).</div>
            </div>
        </form>
        <div class="modal-footer">
            <button class="btn-modal-cancel" onclick="closeEditModal()">Cancel</button>
            <button class="btn-modal-save" id="btnSaveEdit" onclick="saveEdit()">Save Changes</button>
        </div>
    </div>
</div>

<!-- ── Delete Confirm Modal ── -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal del-modal">
        <div class="del-icon">&#128465;</div>
        <h2>Delete Account?</h2>
        <p>You are about to permanently delete <span class="del-name" id="deleteTargetName"></span>. This action cannot be undone.</p>
        <input type="hidden" id="deleteTargetId" />
        <div class="modal-footer" style="justify-content:center;">
            <button class="btn-modal-cancel" onclick="closeDeleteModal()">Cancel</button>
            <button class="btn-confirm-del" id="btnConfirmDel" onclick="confirmDelete()">Yes, Delete</button>
        </div>
    </div>
</div>

<script>
    var allUsers   = [];
    var activeFilter = 'all';
    var apiBase    = '<%= request.getContextPath() %>/api/users';

    // ── Load all users ────────────────────────────────────────
    function loadUsers() {
        $.ajax({
            url: apiBase, type: 'GET', dataType: 'json',
            success: function (res) {
                if (res.success) {
                    allUsers = res.users;
                    renderTable();
                } else {
                    showAlert('error', res.message);
                }
            },
            error: function () { showAlert('error', 'Failed to load staff data.'); }
        });
    }

    // ── Render table ──────────────────────────────────────────
    function renderTable() {
        var search  = $('#searchInput').val().toLowerCase();
        var filtered = allUsers.filter(function (u) {
            var matchRole   = (activeFilter === 'all') || (u.role === activeFilter);
            var matchSearch = !search ||
                u.fullName.toLowerCase().includes(search) ||
                u.username.toLowerCase().includes(search) ||
                (u.email && u.email.toLowerCase().includes(search));
            return matchRole && matchSearch;
        });

        $('#userCount').html('<strong>' + filtered.length + '</strong> staff member' + (filtered.length !== 1 ? 's' : ''));

        if (filtered.length === 0) {
            $('#tableContainer').html(
                '<div class="empty-state"><div class="es-icon">&#128100;</div><p>No staff members found.</p></div>'
            );
            return;
        }

        var rows = filtered.map(function (u, i) {
            var initials = getInitials(u.fullName);
            var roleCls  = u.role === 'manager' ? '' : ' reception';
            var badgeCls = u.role === 'manager' ? 'badge-manager' : 'badge-reception';
            var roleLabel = u.role.charAt(0).toUpperCase() + u.role.slice(1);
            return '<tr>' +
                '<td>' + (i + 1) + '</td>' +
                '<td><div class="user-cell">' +
                    '<div class="avatar' + roleCls + '">' + initials + '</div>' +
                    '<div class="user-info"><div class="name">' + esc(u.fullName) + '</div>' +
                    '<div class="uname">@' + esc(u.username) + '</div></div></div></td>' +
                '<td>' + (u.email ? esc(u.email) : '<span style="color:#b0c8d4">—</span>') + '</td>' +
                '<td><span class="badge ' + badgeCls + '">' + roleLabel + '</span></td>' +
                '<td><div class="actions">' +
                    '<button class="btn-edit"   onclick="openEditModal(' + u.id + ')" >Edit</button>' +
                    '<button class="btn-delete" onclick="openDeleteModal(' + u.id + ', \'' + esc(u.fullName) + '\')">Delete</button>' +
                '</div></td>' +
            '</tr>';
        }).join('');

        $('#tableContainer').html(
            '<table><thead><tr>' +
            '<th>#</th><th>Staff Member</th><th>Email</th><th>Role</th><th>Actions</th>' +
            '</tr></thead><tbody>' + rows + '</tbody></table>'
        );
    }

    // ── Filter tabs ───────────────────────────────────────────
    function applyFilter(filter) {
        activeFilter = filter;
        $('.filter-btn').removeClass('active');
        if (filter === 'all')       $('#filterAll').addClass('active');
        if (filter === 'manager')   $('#filterManager').addClass('active');
        if (filter === 'reception') $('#filterReception').addClass('active');
        renderTable();
    }

    // ── Edit modal ────────────────────────────────────────────
    function openEditModal(id) {
        var u = allUsers.find(function(x) { return x.id === id; });
        if (!u) return;
        $('#editId').val(u.id);
        $('#editFullName').val(u.fullName);
        $('#editEmail').val(u.email);
        $('#editUsername').val(u.username);
        $('#editRole').val(u.role);
        $('#editPassword').val('');
        $('#editModal').addClass('show');
    }

    function closeEditModal() {
        $('#editModal').removeClass('show');
        $('#editAlertBox').hide();
    }

    function showEditAlert(msg) {
        $('#editAlertBox')
            .removeClass('modal-alert-error')
            .addClass('modal-alert modal-alert-error')
            .html(msg).stop(true).show();
    }

    function saveEdit() {
        var id       = $('#editId').val();
        var fullName = $.trim($('#editFullName').val());
        var email    = $.trim($('#editEmail').val());
        var username = $.trim($('#editUsername').val());
        var role     = $('#editRole').val();
        var password = $.trim($('#editPassword').val());

        $('#editAlertBox').hide();

        if (!fullName || !username) {
            showEditAlert('Full name and username are required.'); return;
        }
        if (password && password.length < 6) {
            showEditAlert('New password must be at least 6 characters.'); return;
        }

        var $btn = $('#btnSaveEdit');
        $btn.prop('disabled', true).text('Saving...');

        $.ajax({
            url: apiBase, type: 'POST',
            data: { action: 'update', id: id, fullName: fullName, email: email,
                    username: username, role: role, password: password },
            dataType: 'json',
            success: function (res) {
                if (res.success) {
                    closeEditModal();
                    showAlert('success', '&#10003; ' + res.message);
                    loadUsers();
                } else {
                    showEditAlert(res.message);
                }
                $btn.prop('disabled', false).text('Save Changes');
            },
            error: function (xhr) {
                var msg = 'Failed to update user.';
                try { msg = JSON.parse(xhr.responseText).message || msg; } catch(e) {}
                showEditAlert(msg);
                $btn.prop('disabled', false).text('Save Changes');
            }
        });
    }

    // ── Delete modal ──────────────────────────────────────────
    function openDeleteModal(id, name) {
        $('#deleteTargetId').val(id);
        $('#deleteTargetName').text(name);
        $('#deleteModal').addClass('show');
    }

    function closeDeleteModal() { $('#deleteModal').removeClass('show'); }

    function confirmDelete() {
        var id   = $('#deleteTargetId').val();
        var $btn = $('#btnConfirmDel');
        $btn.prop('disabled', true).text('Deleting...');

        $.ajax({
            url: apiBase, type: 'POST',
            data: { action: 'delete', id: id },
            dataType: 'json',
            success: function (res) {
                closeDeleteModal();
                if (res.success) {
                    showAlert('success', '&#10003; ' + res.message);
                    loadUsers();
                } else {
                    showAlert('error', res.message);
                }
                $btn.prop('disabled', false).text('Yes, Delete');
            },
            error: function (xhr) {
                closeDeleteModal();
                var msg = 'Failed to delete user.';
                try { msg = JSON.parse(xhr.responseText).message || msg; } catch(e) {}
                showAlert('error', msg);
                $btn.prop('disabled', false).text('Yes, Delete');
            }
        });
    }

    // ── Close modal on overlay click ──────────────────────────
    $('.modal-overlay').on('click', function (e) {
        if ($(e.target).hasClass('modal-overlay')) {
            closeEditModal(); closeDeleteModal();
        }
    });

    // ── Helpers ───────────────────────────────────────────────
    function getInitials(name) {
        if (!name) return '?';
        var parts = name.trim().split(' ');
        return parts.length >= 2
            ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
            : name[0].toUpperCase();
    }

    function esc(str) {
        return String(str)
            .replace(/&/g,'&amp;').replace(/</g,'&lt;')
            .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function showAlert(type, msg) {
        $('#alertBox')
            .removeClass('alert-success alert-error')
            .addClass(type === 'success' ? 'alert-success' : 'alert-error')
            .html(msg).stop(true).fadeIn(200);
        if (type === 'success') setTimeout(function(){ $('#alertBox').fadeOut(400); }, 3500);
    }

    // ── Init ──────────────────────────────────────────────────
    $(document).ready(function () { loadUsers(); });
</script>

</body>
</html>
