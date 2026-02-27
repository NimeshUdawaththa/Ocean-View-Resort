<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Admin OR Manager
    if (session.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/views/login.jsp");
        return;
    }
    String sessionRole = (String) session.getAttribute("role");
    if (!"admin".equals(sessionRole) && !"manager".equals(sessionRole)) {
        response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp");
        return;
    }
    boolean isAdmin   = "admin".equals(sessionRole);
    String  userName  = (String) session.getAttribute("fullName");
    String  pageTitle = isAdmin ? "Add Staff Account" : "Add Reception Staff";
    String  pageDesc  = isAdmin
            ? "Create a new Manager or Reception staff account."
            : "Create a new front-desk reception account.";
    String  dashboardUrl = isAdmin
            ? request.getContextPath() + "/views/dashboard.jsp"
            : request.getContextPath() + "/views/manager-dashboard.jsp";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title> <%= pageTitle %> | OceanView Resort</title>
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

        .nav-brand {
            display: flex;
            align-items: center;
            gap: 12px;
            color: white;
            font-size: 20px;
            font-weight: 700;
        }
        .nav-brand span { font-size: 26px; }

        .nav-right {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .nav-user { color: rgba(255,255,255,.9); font-size: 14px; text-align: right; }
        .nav-user strong { display: block; font-size: 15px; color: white; }

        .btn-nav {
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
        .btn-nav:hover { background: rgba(255,255,255,.28); }

        /* ── Main ── */
        main {
            max-width: 660px;
            margin: 44px auto;
            padding: 0 20px;
        }

        .page-header { margin-bottom: 28px; }
        .page-header h1 {
            font-size: 24px;
            font-weight: 700;
            color: #0a4f6e;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .page-header p { margin-top: 6px; color: #7a95a8; font-size: 14px; }

        /* ── Role Tab Switcher ── */
        .role-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 26px;
        }

        .role-tab {
            flex: 1;
            padding: 14px 10px;
            border-radius: 12px;
            border: 2px solid #dce8ee;
            background: white;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            font-weight: 600;
            font-size: 14.5px;
            color: #3a5a6e;
            transition: all .2s;
        }

        .role-tab .tab-icon {
            width: 38px; height: 38px;
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px;
            background: #f0f6fa;
            transition: background .2s;
        }

        .role-tab:hover { border-color: #1aa3c8; }

        .role-tab.active-manager {
            border-color: #1aa3c8;
            background: linear-gradient(135deg, #e6f7fd, #f0faff);
            color: #0a4f6e;
        }
        .role-tab.active-manager .tab-icon { background: linear-gradient(135deg, #0a4f6e, #1aa3c8); color: white; }

        .role-tab.active-reception {
            border-color: #34a853;
            background: linear-gradient(135deg, #e8f8ee, #f0fff4);
            color: #1b6b33;
        }
        .role-tab.active-reception .tab-icon { background: linear-gradient(135deg, #1e8449, #34a853); color: white; }

        /* ── Card ── */
        .form-card {
            background: white;
            border-radius: 16px;
            padding: 36px 36px 32px;
            box-shadow: 0 6px 24px rgba(0,50,80,.1);
        }

        .role-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: .5px;
            text-transform: uppercase;
            margin-bottom: 24px;
        }
        .role-badge.manager  { background: #e6f7fd; color: #0a4f6e; border: 1px solid #b3e5f6; }
        .role-badge.reception { background: #e8f8ee; color: #1b6b33; border: 1px solid #a8dfc1; }

        /* Form fields */
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .form-group { margin-bottom: 18px; }

        .form-group label {
            display: block;
            font-size: 12.5px;
            font-weight: 700;
            color: #3a5a6e;
            margin-bottom: 7px;
            text-transform: uppercase;
            letter-spacing: .4px;
        }
        .form-group .required { color: #e04b3a; }

        .input-wrapper { position: relative; }

        .input-icon {
            position: absolute;
            left: 13px; top: 50%;
            transform: translateY(-50%);
            color: #8aacbc;
            pointer-events: none;
        }

        .form-group input {
            width: 100%;
            padding: 12px 14px 12px 42px;
            border: 2px solid #dce8ee;
            border-radius: 10px;
            font-size: 14.5px;
            color: #1e3a4a;
            background: #f6fafc;
            outline: none;
            transition: border-color .25s, box-shadow .25s, background .25s;
        }
        .form-group input::placeholder { color: #b0c8d4; }
        .form-group input:focus {
            border-color: #1aa3c8;
            background: #fff;
            box-shadow: 0 0 0 4px rgba(26,163,200,.12);
        }
        .form-group input.is-invalid { border-color: #e04b3a; box-shadow: 0 0 0 3px rgba(224,75,58,.1); }

        .field-error { display: none; font-size: 12.5px; color: #e04b3a; margin-top: 5px; }

        .toggle-pw {
            position: absolute; right: 12px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none; cursor: pointer;
            color: #8aacbc; padding: 4px; transition: color .2s;
        }
        .toggle-pw:hover { color: #1aa3c8; }

        hr.divider { border: none; border-top: 1px solid #e8f0f4; margin: 24px 0; }

        .btn-row { display: flex; gap: 12px; justify-content: flex-end; }

        .btn-cancel {
            padding: 12px 24px;
            border: 2px solid #dce8ee;
            border-radius: 10px;
            background: white;
            color: #3a5a6e;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            transition: border-color .2s, background .2s;
        }
        .btn-cancel:hover { border-color: #1aa3c8; background: #f0fafd; }

        .btn-submit {
            padding: 12px 28px;
            background: linear-gradient(135deg, #0a4f6e, #1aa3c8);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            letter-spacing: .4px;
            box-shadow: 0 5px 16px rgba(13,122,154,.35);
            transition: transform .2s, box-shadow .2s;
        }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 8px 22px rgba(13,122,154,.45); }
        .btn-submit:disabled { opacity: .7; cursor: not-allowed; transform: none; }

        /* Alert */
        .alert {
            display: none;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 20px;
        }
        .alert-success { background: #e8f8f0; color: #1e8449; border: 1px solid #b8e8ce; }
        .alert-error   { background: #fde8e8; color: #c0392b; border: 1px solid #f5c6c6; }

        @media (max-width: 540px) {
            .form-row { grid-template-columns: 1fr; }
            .form-card { padding: 24px 20px; }
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
                <strong><%= userName != null ? userName : sessionRole %></strong>
                <%= isAdmin ? "Admin" : "Manager" %>
            </div>
            <a href="<%= dashboardUrl %>" class="btn-nav">&#8592; Dashboard</a>
            <a href="<%= request.getContextPath() %>/api/logout" class="btn-nav">Logout</a>
        </div>
    </nav>

    <main>
        <div class="page-header">
            <h1>&#128101; <%= pageTitle %></h1>
            <p><%= pageDesc %></p>
        </div>

        <% if (isAdmin) { %>
        <!-- Role Tabs -->
        <div class="role-tabs">
            <div class="role-tab active-manager" id="tabManager" onclick="selectRole('manager')">
                <div class="tab-icon">&#127775;</div>
                Manager
            </div>
            <div class="role-tab" id="tabReception" onclick="selectRole('reception')">
                <div class="tab-icon">&#128100;</div>
                Reception
            </div>
        </div>
        <% } %>

        <!-- Alert -->
        <div id="alertBox" class="alert"></div>

        <div class="form-card">

            <div id="roleBadge" class="role-badge <%= isAdmin ? "manager" : "reception" %>">
                <%= isAdmin ? "&#127775; Manager Account" : "&#128100; Reception Account" %>
            </div>

            <form id="addUserForm" novalidate>
                <input type="hidden" id="selectedRole" name="role" value="<%= isAdmin ? "manager" : "reception" %>" />

                <div class="form-row">
                    <!-- Full Name -->
                    <div class="form-group">
                        <label>Full Name <span class="required">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
                                </svg>
                            </span>
                            <input type="text" id="fullName" name="fullName" placeholder="e.g. John Silva" />
                        </div>
                        <div class="field-error" id="err-fullName">Full name is required.</div>
                    </div>

                    <!-- Email -->
                    <div class="form-group">
                        <label>Email Address</label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                                    <polyline points="22,6 12,13 2,6"/>
                                </svg>
                            </span>
                            <input type="email" id="email" name="email" placeholder="e.g. john@resort.com" />
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <!-- Username -->
                    <div class="form-group">
                        <label>Username <span class="required">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
                                </svg>
                            </span>
                            <input type="text" id="username" name="username" placeholder="e.g. john.silva" autocomplete="off" />
                        </div>
                        <div class="field-error" id="err-username">Username is required.</div>
                    </div>

                    <!-- Password -->
                    <div class="form-group">
                        <label>Password <span class="required">*</span></label>
                        <div class="input-wrapper">
                            <span class="input-icon">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                                </svg>
                            </span>
                            <input type="password" id="password" name="password" placeholder="Min. 6 characters" autocomplete="new-password" />
                            <button type="button" class="toggle-pw" onclick="togglePw()">
                                <svg id="pw-eye" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
                                </svg>
                            </button>
                        </div>
                        <div class="field-error" id="err-password">Password must be at least 6 characters.</div>
                    </div>
                </div>

                <hr class="divider">

                <div class="btn-row">
                    <a href="<%= dashboardUrl %>" class="btn-cancel">Cancel</a>
                    <button type="submit" id="btnSubmit" class="btn-submit">Create Account</button>
                </div>
            </form>
        </div>
    </main>

    <script>
        var IS_ADMIN = <%= isAdmin %>;

        // ── Role tab switcher (admin only) ────────────────────
        function selectRole(role) {
            if (!IS_ADMIN) return;
            $('#selectedRole').val(role);
            $('#tabManager').removeClass('active-manager');
            $('#tabReception').removeClass('active-reception');

            if (role === 'manager') {
                $('#tabManager').addClass('active-manager');
                $('#roleBadge').attr('class', 'role-badge manager').html('&#127775; Manager Account');
            } else {
                $('#tabReception').addClass('active-reception');
                $('#roleBadge').attr('class', 'role-badge reception').html('&#128100; Reception Account');
            }
            hideAlert();
        }

        // ── Password toggle ───────────────────────────────────
        function togglePw() {
            var input = document.getElementById('password');
            var icon  = document.getElementById('pw-eye');
            if (input.type === 'password') {
                input.type = 'text';
                icon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/>';
            } else {
                input.type = 'password';
                icon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
            }
        }

        // ── AJAX submit ───────────────────────────────────────
        $(document).ready(function () {
            $('#addUserForm').on('submit', function (e) {
                e.preventDefault();

                $('.is-invalid').removeClass('is-invalid');
                $('.field-error').hide();
                hideAlert();

                var fullName = $.trim($('#fullName').val());
                var username = $.trim($('#username').val());
                var password = $.trim($('#password').val());
                var email    = $.trim($('#email').val());
                var role     = $('#selectedRole').val();

                var valid = true;
                if (!fullName) { $('#fullName').addClass('is-invalid'); $('#err-fullName').show(); valid = false; }
                if (!username) { $('#username').addClass('is-invalid'); $('#err-username').show(); valid = false; }
                if (password.length < 6) { $('#password').addClass('is-invalid'); $('#err-password').show(); valid = false; }
                if (!valid) return;

                var $btn = $('#btnSubmit');
                $btn.prop('disabled', true).text('Creating...');

                $.ajax({
                    url: '<%= request.getContextPath() %>/api/users/add-user',
                    type: 'POST',
                    data: { username: username, password: password, email: email, fullName: fullName, role: role },
                    dataType: 'json',
                    success: function (res) {
                        if (res.success) {
                            showAlert('success', '&#10003; ' + res.message);
                            $('#addUserForm')[0].reset();
                            if (IS_ADMIN) selectRole('manager');
                        } else {
                            showAlert('error', res.message);
                        }
                        $btn.prop('disabled', false).text('Create Account');
                    },
                    error: function (xhr) {
                        var msg = 'An error occurred. Please try again.';
                        try { msg = JSON.parse(xhr.responseText).message || msg; } catch (ex) {}
                        showAlert('error', msg);
                        $btn.prop('disabled', false).text('Create Account');
                    }
                });
            });

            function showAlert(type, msg) {
                $('#alertBox')
                    .removeClass('alert-success alert-error')
                    .addClass(type === 'success' ? 'alert-success' : 'alert-error')
                    .html(msg).stop(true).fadeIn(200);
            }

            function hideAlert() { $('#alertBox').stop(true).fadeOut(150); }
        });
    </script>

</body>
</html>
