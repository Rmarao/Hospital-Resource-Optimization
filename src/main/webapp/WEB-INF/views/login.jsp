<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Hospital Login</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="auth" class="auth-shell">

<div class="auth-topbar">
    <div class="brand"><i class="icon icon-cross"></i> Hospital<span>System</span></div>
</div>

<div class="auth-content">
    <div class="auth-wrapper">

        <div class="auth-intro">
            <h1>Intelligent <span>Hospital</span><br/>Resource System</h1>
            <p>A smart, unified platform for managing hospital resources, scheduling, and patient care efficiently.</p>
        </div>

        <div class="auth-card">
            <div class="auth-card-header">
                <h2>Welcome Back</h2>
                <p>Login to access your portal</p>
            </div>

            <div class="auth-card-body">

                <% if ("locked".equals(request.getParameter("error"))) { %>
                    <div class="alert error"><i class="icon icon-alert-circle"></i> Too many failed attempts. Please try again in 15 minutes.</div>
                <% } else if ("true".equals(request.getParameter("error"))) { %>
                    <div class="alert error"><i class="icon icon-alert-circle"></i> Invalid email or password.</div>
                <% } %>

                <% if ("true".equals(request.getParameter("success"))) { %>
                    <div class="alert success"><i class="icon icon-check-circle"></i> Account created! You can now login.</div>
                <% } %>

                <form action="/login" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" placeholder="Enter your email" required />
                    </div>
                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="password" placeholder="Enter your password" required />
                    </div>
                    <button type="submit" class="btn btn-primary btn-block">Login</button>
                </form>
            </div>

            <div class="auth-divider"></div>

            <div class="auth-footer">
                <span class="auth-footer-link">New patient? <a href="/signup">Create an account</a></span>
            </div>
        </div>

    </div>
</div>

<script src="/assets/js/app.js" defer></script>
</body>
</html>
