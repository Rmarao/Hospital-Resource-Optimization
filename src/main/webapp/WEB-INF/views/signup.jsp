<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Patient Sign Up</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="auth" class="auth-plain-bg">

<div class="auth-nav">
    <div class="brand"><i class="icon icon-cross"></i> Hospital<span>System</span></div>
    <div class="auth-nav-right">Already have an account? <a href="/">Login here</a></div>
</div>

<div class="auth-content top">
    <div class="auth-card wide">

        <div class="auth-banner">
            <h1>Patient Registration</h1>
            <p>Create your account to access the hospital patient portal.</p>
        </div>

        <div class="auth-card-body">

            <% if ("emailexists".equals(request.getParameter("error"))) { %>
                <div class="alert error"><i class="icon icon-alert-circle"></i> This email is already registered. Please use a different email or login.</div>
            <% } else if ("toomanyattempts".equals(request.getParameter("error"))) { %>
                <div class="alert error"><i class="icon icon-alert-circle"></i> Too many signup attempts from this location. Please try again in 15 minutes.</div>
            <% } else if ("validation".equals(request.getParameter("error"))) { %>
                <div class="alert error"><i class="icon icon-alert-circle"></i> Please check the highlighted fields and try again.</div>
            <% } else if ("conflict".equals(request.getParameter("error"))) { %>
                <div class="alert error"><i class="icon icon-alert-circle"></i> That email was just registered by someone else. Please use a different email or login.</div>
            <% } %>

            <form action="/signup" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                <div class="section-heading">Personal Information</div>
                <div class="form-grid cols-2">
                    <div class="form-group">
                        <label>Full Name *</label>
                        <input type="text" name="name" placeholder="Enter your full name" required />
                    </div>
                    <div class="form-group">
                        <label>Email Address *</label>
                        <input type="email" name="email" placeholder="Enter your email" required />
                    </div>
                    <div class="form-group">
                        <label>Password *</label>
                        <input type="password" name="password" placeholder="Create a password" required />
                    </div>
                    <div class="form-group">
                        <label>Phone Number *</label>
                        <input type="tel" name="phone" placeholder="Enter phone number" required />
                    </div>
                    <div class="form-group">
                        <label>Date of Birth *</label>
                        <input type="date" name="dateOfBirth" required />
                    </div>
                    <div class="form-group">
                        <label>Gender *</label>
                        <select name="gender" required>
                            <option value="" disabled selected>Select gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>

                <div class="section-heading">Medical Information</div>
                <div class="form-grid cols-2">
                    <div class="form-group">
                        <label>Blood Group *</label>
                        <select name="bloodGroup" required>
                            <option value="" disabled selected>Select blood group</option>
                            <option value="A+">A+</option>
                            <option value="A-">A-</option>
                            <option value="B+">B+</option>
                            <option value="B-">B-</option>
                            <option value="O+">O+</option>
                            <option value="O-">O-</option>
                            <option value="AB+">AB+</option>
                            <option value="AB-">AB-</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Emergency Contact *</label>
                        <input type="tel" name="emergencyContact" placeholder="Emergency contact number" required />
                    </div>
                    <div class="form-group full">
                        <label>Medical History</label>
                        <textarea name="medicalHistory" placeholder="Any existing conditions, allergies or past surgeries (optional)"></textarea>
                    </div>
                </div>

                <div class="section-heading">Address</div>
                <div class="form-group">
                    <label>Full Address *</label>
                    <textarea name="address" placeholder="Enter your full address" required></textarea>
                </div>

                <div class="auth-submit">
                    <button type="submit" class="btn btn-primary btn-block">Create Account</button>
                    <span class="auth-footer-link">Already registered? <a href="/">Login here</a></span>
                </div>

            </form>
        </div>
    </div>
</div>

<script src="/assets/js/app.js" defer></script>
</body>
</html>
