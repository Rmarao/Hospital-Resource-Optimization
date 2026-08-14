<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.hospital.model.Patient" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Patient - Profile</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="patient">

<%
    String activePage = "profile";

    Patient patient = (Patient) request.getAttribute("patient");
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));
    String errorMsg = request.getParameter("error");
%>

<%@ include file="/WEB-INF/views/fragments/patient-navbar.jspf" %>

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
            <form action="/patient/profile/update" method="post" style="padding:0 20px 20px;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Full Name</label>
                    <input type="text" name="name" value="<%= Esc.h(patient.getName()) %>" required />
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Email</label>
                    <input type="email" value="<%= Esc.h(patient.getEmail()) %>" disabled />
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Phone</label>
                    <input type="tel" name="phone" value="<%= Esc.h(patient.getPhone()) %>" required />
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Gender</label>
                    <select name="gender">
                        <option value="" <%= patient.getGender() == null ? "selected" : "" %>>Not specified</option>
                        <option value="Male" <%= "Male".equals(patient.getGender()) ? "selected" : "" %>>Male</option>
                        <option value="Female" <%= "Female".equals(patient.getGender()) ? "selected" : "" %>>Female</option>
                        <option value="Other" <%= "Other".equals(patient.getGender()) ? "selected" : "" %>>Other</option>
                    </select>
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Blood Group</label>
                    <select name="bloodGroup">
                        <option value="" <%= patient.getBloodGroup() == null ? "selected" : "" %>>Not specified</option>
                        <% for (String bg : new String[]{"A+","A-","B+","B-","O+","O-","AB+","AB-"}) { %>
                            <option value="<%= bg %>" <%= bg.equals(patient.getBloodGroup()) ? "selected" : "" %>><%= bg %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Address</label>
                    <input type="text" name="address" value="<%= Esc.h(patient.getAddress()) %>" />
                </div>
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Emergency Contact</label>
                    <input type="tel" name="emergencyContact" value="<%= Esc.h(patient.getEmergencyContact()) %>" />
                </div>
                <div class="form-group" style="margin-bottom:16px;">
                    <label>Medical History</label>
                    <textarea name="medicalHistory"><%= Esc.h(patient.getMedicalHistory()) %></textarea>
                </div>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>Change Password</h3></div>
            <form action="/patient/profile/password" method="post" style="padding:0 20px 20px;">
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
