<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | OceanView Resort</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #0a4f6e 0%, #0d7a9a 40%, #1aa3c8 70%, #3bbfdf 100%);
            position: relative;
            overflow: hidden;
        }

        /* Animated wave overlay */
        body::before {
            content: '';
            position: absolute;
            bottom: -60px;
            left: -50%;
            width: 200%;
            height: 300px;
            background: rgba(255, 255, 255, 0.06);
            border-radius: 50%;
            animation: wave 8s infinite linear;
        }

        body::after {
            content: '';
            position: absolute;
            bottom: -80px;
            left: -50%;
            width: 200%;
            height: 280px;
            background: rgba(255, 255, 255, 0.04);
            border-radius: 50%;
            animation: wave 12s infinite linear reverse;
        }

        @keyframes wave {
            0%   { transform: translateX(0) rotate(0deg); }
            100% { transform: translateX(50%) rotate(360deg); }
        }

        /* Floating bubbles */
        .bubble {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.08);
            animation: float 10s infinite ease-in-out;
        }

        .bubble:nth-child(1) { width: 80px;  height: 80px;  top: 10%; left: 8%;  animation-delay: 0s;   animation-duration: 9s;  }
        .bubble:nth-child(2) { width: 50px;  height: 50px;  top: 60%; left: 5%;  animation-delay: 2s;   animation-duration: 12s; }
        .bubble:nth-child(3) { width: 120px; height: 120px; top: 20%; right: 6%; animation-delay: 1s;   animation-duration: 11s; }
        .bubble:nth-child(4) { width: 40px;  height: 40px;  top: 75%; right: 8%; animation-delay: 3s;   animation-duration: 8s;  }
        .bubble:nth-child(5) { width: 65px;  height: 65px;  top: 45%; left: 15%; animation-delay: 4s;   animation-duration: 14s; }

        @keyframes float {
            0%, 100% { transform: translateY(0px) scale(1); opacity: 0.6; }
            50%       { transform: translateY(-20px) scale(1.05); opacity: 1; }
        }

        /* Logo / Brand area */
        .brand-wrapper {
            position: absolute;
            top: 30px;
            left: 50%;
            transform: translateX(-50%);
            text-align: center;
            color: white;
        }

        .brand-wrapper .brand-icon {
            font-size: 36px;
            letter-spacing: 2px;
        }

        .brand-wrapper .brand-name {
            font-size: 14px;
            letter-spacing: 4px;
            text-transform: uppercase;
            opacity: 0.85;
            margin-top: 4px;
        }

        /* Card */
        .login-card {
            position: relative;
            z-index: 10;
            background: rgba(255, 255, 255, 0.97);
            border-radius: 20px;
            padding: 50px 44px 44px;
            width: 100%;
            max-width: 430px;
            box-shadow: 0 30px 80px rgba(0, 50, 80, 0.35), 0 8px 20px rgba(0, 0, 0, 0.15);
        }

        /* Header inside card */
        .card-header {
            text-align: center;
            margin-bottom: 32px;
        }

        .card-header .resort-logo {
            width: 68px;
            height: 68px;
            background: linear-gradient(135deg, #0a4f6e, #1aa3c8);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            box-shadow: 0 6px 18px rgba(13, 122, 154, 0.45);
        }

        .card-header .resort-logo svg {
            width: 36px;
            height: 36px;
            fill: white;
        }

        .card-header h1 {
            font-size: 26px;
            font-weight: 700;
            color: #0a4f6e;
            margin-bottom: 6px;
            letter-spacing: 0.5px;
        }

        .card-header p {
            font-size: 14px;
            color: #7a95a8;
        }

        /* Form */
        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #3a5a6e;
            margin-bottom: 8px;
            letter-spacing: 0.4px;
            text-transform: uppercase;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #8aacbc;
            pointer-events: none;
        }

        .input-wrapper input {
            width: 100%;
            padding: 13px 16px 13px 44px;
            border: 2px solid #dce8ee;
            border-radius: 10px;
            font-size: 15px;
            color: #1e3a4a;
            background: #f6fafc;
            transition: border-color 0.25s, box-shadow 0.25s, background 0.25s;
            outline: none;
        }

        .input-wrapper input::placeholder {
            color: #b0c8d4;
        }

        .input-wrapper input:focus {
            border-color: #1aa3c8;
            background: #ffffff;
            box-shadow: 0 0 0 4px rgba(26, 163, 200, 0.12);
        }

        /* Password toggle */
        .toggle-password {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #8aacbc;
            padding: 4px;
            transition: color 0.2s;
        }

        .toggle-password:hover {
            color: #1aa3c8;
        }

        /* Options row */
        .options-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 28px;
            margin-top: -4px;
        }

        .remember-me {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            font-size: 13.5px;
            color: #4a6a7a;
            user-select: none;
        }

        .remember-me input[type="checkbox"] {
            width: 16px;
            height: 16px;
            accent-color: #1aa3c8;
            cursor: pointer;
        }

        .forgot-link {
            font-size: 13.5px;
            color: #1aa3c8;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.2s;
        }

        .forgot-link:hover {
            color: #0a4f6e;
            text-decoration: underline;
        }

        /* Login button */
        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #0a4f6e 0%, #1aa3c8 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 700;
            letter-spacing: 0.8px;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s, opacity 0.2s;
            box-shadow: 0 6px 20px rgba(13, 122, 154, 0.4);
            text-transform: uppercase;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 28px rgba(13, 122, 154, 0.52);
        }

        .btn-login:active {
            transform: translateY(0);
            box-shadow: 0 4px 14px rgba(13, 122, 154, 0.35);
        }

        /* Register link */
        .register-row {
            text-align: center;
            font-size: 14px;
            color: #7a95a8;
        }

        .register-row a {
            color: #1aa3c8;
            font-weight: 700;
            text-decoration: none;
            transition: color 0.2s;
        }

        .register-row a:hover {
            color: #0a4f6e;
            text-decoration: underline;
        }

        /* Alert box */
        .alert {
            display: none;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 20px;
            text-align: center;
        }

        .alert-error {
            background: #fde8e8;
            color: #c0392b;
            border: 1px solid #f5c6c6;
        }

        .alert-success {
            background: #e8f8f0;
            color: #1e8449;
            border: 1px solid #b8e8ce;
        }

        /* Button loading state */
        .btn-login:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            transform: none;
        }

        /* Responsive */
        @media (max-width: 480px) {
            .login-card {
                margin: 16px;
                padding: 36px 26px 32px;
            }

            .brand-wrapper {
                top: 16px;
            }

        }
    </style>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>

    <!-- Floating bubbles -->
    <div class="bubble"></div>
    <div class="bubble"></div>
    <div class="bubble"></div>
    <div class="bubble"></div>
    <div class="bubble"></div>

    <!-- Top brand  -->
    <div class="brand-wrapper">
        <div class="brand-icon">&#9875;</div>
        <div class="brand-name">OceanView Resort</div>
    </div>

    <!-- Login Card -->
    <div class="login-card">

        <!-- Card Header -->
        <div class="card-header">
            <div class="resort-logo">
                <!-- Wave / anchor icon -->
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 2C9.243 2 7 4.243 7 7v2H5c-1.103 0-2 .897-2 2v9c0 1.103.897 2 2 2h14c1.103 0 2-.897 2-2v-9c0-1.103-.897-2-2-2h-2V7c0-2.757-2.243-5-5-5zm0 2c1.654 0 3 1.346 3 3v2H9V7c0-1.654 1.346-3 3-3zm1 12.732V19h-2v-2.268A2 2 0 0 1 10 15c0-1.103.897-2 2-2s2 .897 2 2a2 2 0 0 1-1 1.732z"/>
                </svg>
            </div>
            <h1>Welcome Back</h1>
            <p>Sign in to your resort account</p>
        </div>

        <!-- Alert Message -->
        <div id="alertBox" class="alert"></div>

        <!-- Login Form -->
        <form id="loginForm">

            <!-- Username field -->
            <div class="form-group">
                <label for="username">Username</label>
                <div class="input-wrapper">
                    <span class="input-icon">
                        <!-- user icon -->
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                            <circle cx="12" cy="7" r="4"/>
                        </svg>
                    </span>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        placeholder="Enter your username"
                        autocomplete="username"
                        required
                    />
                </div>
            </div>

            <!-- Password field -->
            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrapper">
                    <span class="input-icon">
                        <!-- lock icon -->
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                    </span>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        placeholder="Enter your password"
                        autocomplete="current-password"
                    />
                    <!-- Show/hide password toggle -->
                    <button type="button" class="toggle-password" onclick="togglePassword()" title="Show / hide password">
                        <svg id="eye-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Remember me + Forgot password -->
            <div class="options-row">
                <label class="remember-me">
                    <input type="checkbox" name="remember" />
                    Remember me
                </label>
                <a href="#" class="forgot-link">Forgot password?</a>
            </div>

            <!-- Submit -->
            <button type="submit" id="btnLogin" class="btn-login">Sign In</button>

        </form>

        <!-- Register -->
        <div class="register-row">
            Don't have an account? <a href="#">Create one</a>
        </div>

    </div>

    <script>
        // ── Show / hide password ───────────────────────────────
        function togglePassword() {
            var input = document.getElementById('password');
            var icon  = document.getElementById('eye-icon');
            if (input.type === 'password') {
                input.type = 'text';
                icon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/>';
            } else {
                input.type = 'password';
                icon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
            }
        }

        // ── Login AJAX ─────────────────────────────────────────
        $(document).ready(function () {

            $('#loginForm').on('submit', function (e) {
                e.preventDefault();

                var username = $.trim($('#username').val());
                var password = $.trim($('#password').val());

                // Client-side validation
                if (!username || !password) {
                    showAlert('error', 'Please enter both username and password.');
                    return;
                }

                var $btn = $('#btnLogin');
                $btn.prop('disabled', true).text('Signing in...');
                hideAlert();

                $.ajax({
                    url: '<%= request.getContextPath() %>/api/login',
                    type: 'POST',
                    data: { username: username, password: password },
                    dataType: 'json',
                    success: function (response) {
                        if (response.success) {
                            showAlert('success', 'Login successful! Redirecting...');
                            setTimeout(function () {
                                window.location.href = response.redirectUrl;
                            }, 800);
                        } else {
                            showAlert('error', response.message || 'Login failed.');
                            $btn.prop('disabled', false).text('Sign In');
                        }
                    },
                    error: function (xhr) {
                        var msg = 'An error occurred. Please try again.';
                        try {
                            var err = JSON.parse(xhr.responseText);
                            if (err.message) msg = err.message;
                        } catch (ex) {}
                        showAlert('error', msg);
                        $btn.prop('disabled', false).text('Sign In');
                    }
                });
            });

            function showAlert(type, message) {
                $('#alertBox')
                    .removeClass('alert-error alert-success')
                    .addClass(type === 'error' ? 'alert-error' : 'alert-success')
                    .text(message)
                    .stop(true, true)
                    .fadeIn(200);
            }

            function hideAlert() {
                $('#alertBox').fadeOut(150);
            }
        });
    </script>

</body>
</html>
