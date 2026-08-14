<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.hospital.model.Doctor" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Doctor - Profile</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="doctor">

<%
    String activePage = "profile";

    Doctor doctor = (Doctor) request.getAttribute("doctor");
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));
    String errorMsg = request.getParameter("error");
%>

<%@ include file="/WEB-INF/views/fragments/doctor-navbar.jspf" %>

<div class="page-main">
    <h1 style="font-size:22px; margin-bottom:16px;"><i class="icon icon-user"></i> My Profile</h1>

    <% if (successMsg != null) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> <%= successMsg %></div>
    <% } %>
    <% if ("notfound".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> Could not find your profile.</div>
    <% } else if ("wrongpassword".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> Current password is incorrect.</div>
    <% } %>

    <div class="content-grid">
        <div class="card">
            <div class="card-header"><h3>Profile Details</h3></div>
            <form action="/doctor/profile/update" method="post" style="padding:0 20px 20px;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Full Name</label>
                    <input type="text" name="name" value="<%= Esc.h(doctor.getName()) %>" required />
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Email</label>
                    <input type="email" value="<%= Esc.h(doctor.getEmail()) %>" disabled />
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Phone</label>
                    <input type="tel" name="phone" value="<%= Esc.h(doctor.getPhone()) %>" required />
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Department</label>
                    <select name="department" required>
                        <% String[] depts = {"General Medicine","Orthopedics","Cardiology","Neurology","Oncology",
                            "Pediatrics","Gynecology","Emergency","Radiology","Anesthesiology"};
                           for (String dept : depts) { %>
                            <option value="<%= dept %>" <%= dept.equals(doctor.getDepartment()) ? "selected" : "" %>><%= dept %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Specialization</label>
                    <input type="text" name="specialization" value="<%= Esc.h(doctor.getSpecialization()) %>" required />
                </div>
                <div class="form-group" style="margin-bottom:16px;">
                    <label>Qualification</label>
                    <input type="text" name="qualification" value="<%= Esc.h(doctor.getQualification()) %>" required />
                </div>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>Change Password</h3></div>
            <form action="/doctor/profile/password" method="post" style="padding:0 20px 20px;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Current Password</label>
                    <input type="password" name="currentPassword" required />
                </div>
                <div class="form-group" style="margin-bottom:16px;">
                    <label>New Password</label>
                    <input type="password" name="newPassword" minlength="8" required />
                </div>
                <button type="submit" class="btn btn-primary">Change Password</button>
            </form>
        </div>
    </div>
</div>

</body>
</html>
