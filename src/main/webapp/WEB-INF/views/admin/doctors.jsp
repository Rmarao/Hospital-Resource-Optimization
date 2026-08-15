<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.model.Doctor" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Doctors</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<%
    String activePage = "doctors";

    List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");
    long totalDoctors = (long) request.getAttribute("totalDoctors");
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));
    String errorMsg = request.getParameter("error");
    String q = (String) request.getAttribute("q");
%>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-user"></i> Doctor Management</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <% if (successMsg != null) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> <%= successMsg %></div>
    <% } %>
    <% if ("emailexists".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> This email is already registered for another doctor.</div>
    <% } else if ("conflict".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> That email was just registered by someone else. Please try a different email.</div>
    <% } %>

    <!-- Stats -->
    <div class="stats-row cols-3">
        <div class="stat-card"><div class="value"><%= totalDoctors %></div><div class="label">Total Doctors</div></div>
        <div class="stat-card"><div class="value"><%= totalDoctors %></div><div class="label">Active Doctors</div></div>
        <div class="stat-card"><div class="value">0</div><div class="label">Assigned Patients</div></div>
    </div>

    <!-- Add Doctor Form -->
    <div class="add-form on-surface">
        <h4><i class="icon icon-plus"></i> Register New Doctor</h4>
        <form action="/admin/doctors/add" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

            <div class="form-grid">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="name" placeholder="John Smith (no 'Dr.' prefix — added automatically)" required />
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" placeholder="doctor@hospital.com" required />
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="Set a password" required />
                </div>
                <div class="form-group">
                    <label>Phone</label>
                    <input type="tel" name="phone" placeholder="Phone number" required />
                </div>
                <div class="form-group">
                    <label>Department</label>
                    <select name="department" required>
                        <option value="" disabled selected>Select department</option>
                        <option value="General Medicine">General Medicine</option>
                        <option value="Orthopedics">Orthopedics</option>
                        <option value="Cardiology">Cardiology</option>
                        <option value="Neurology">Neurology</option>
                        <option value="Oncology">Oncology</option>
                        <option value="Pediatrics">Pediatrics</option>
                        <option value="Gynecology">Gynecology</option>
                        <option value="Emergency">Emergency</option>
                        <option value="Radiology">Radiology</option>
                        <option value="Anesthesiology">Anesthesiology</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Specialization</label>
                    <input type="text" name="specialization" placeholder="e.g. Cardiac Surgeon" required />
                </div>
                <div class="form-group">
                    <label>Qualification</label>
                    <input type="text" name="qualification" placeholder="e.g. MBBS, MD" required />
                </div>
                <div class="form-group">
                    <label>Practice Start Date</label>
                    <input type="date" name="practiceStartDate" required />
                </div>
            </div>

            <button type="submit" class="btn btn-primary">Register Doctor</button>
        </form>
    </div>

    <!-- Doctors Table -->
    <div class="card">
        <div class="card-header">
            <h3>All Doctors</h3>
            <span class="count-badge"><%= doctors != null ? doctors.size() : 0 %> of <%= totalDoctors %> doctors</span>
        </div>

        <form action="/admin/doctors" method="get" class="search-row" style="padding:0 20px 16px;">
            <input type="text" name="q" placeholder="Search by name, email, department, specialization..." value="<%= Esc.h(q) %>" />
            <button type="submit" class="search-btn"><i class="icon icon-search"></i> Search</button>
            <% if (q != null && !q.isBlank()) { %>
                <a href="/admin/doctors" class="btn btn-sm">Clear</a>
            <% } %>
            <a href="/admin/doctors/export.csv<%= (q != null && !q.isBlank()) ? "?q=" + java.net.URLEncoder.encode(q, java.nio.charset.StandardCharsets.UTF_8) : "" %>" class="btn btn-sm"><i class="icon icon-file-text"></i> Export CSV</a>
        </form>

        <% if (doctors == null || doctors.isEmpty()) { %>
            <div class="empty-state"><i class="icon icon-user"></i><p><%= (q != null && !q.isBlank()) ? "No doctors match your search." : "No doctors registered yet. Add your first doctor above!" %></p></div>
        <% } else { %>
            <table>
                <tr>
                    <th>Doctor</th><th>Department</th><th>Specialization</th>
                    <th>Qualification</th><th>Experience</th><th>Phone</th><th>Actions</th>
                </tr>
                <% for (Doctor doctor : doctors) { %>
                <tr>
                    <td>
                        <span class="avatar"><i class="icon icon-user"></i></span>
                        <strong>Dr. <%= Esc.h(doctor.getName()) %></strong>
                        <br/>
                        <small style="color:var(--text-mute); margin-left:48px"><%= Esc.h(doctor.getEmail()) %></small>
                    </td>
                    <td><span class="badge blue"><%= Esc.h(doctor.getDepartment()) %></span></td>
                    <td><%= Esc.h(doctor.getSpecialization()) %></td>
                    <td><span class="badge purple"><%= Esc.h(doctor.getQualification()) %></span></td>
                    <td><span class="badge green"><%= doctor.getYearsOfExperience() %> yrs</span></td>
                    <td><%= Esc.h(doctor.getPhone()) %></td>
                    <td>
                        <form action="/admin/doctors/delete" method="post" class="inline-form"
                              data-confirm="Remove this doctor?">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            <input type="hidden" name="id" value="<%= doctor.getId() %>" />
                            <button type="submit" class="btn btn-danger btn-sm">Remove</button>
                        </form>
                    </td>
                </tr>
                <% } %>
            </table>
        <% } %>
    </div>

</div>

</body>
</html>
