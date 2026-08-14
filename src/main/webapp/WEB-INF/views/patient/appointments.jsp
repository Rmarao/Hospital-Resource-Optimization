<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.model.AppointmentRequest" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Patient - Appointments</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="patient">

<%
    String activePage = "appointments";

    List<AppointmentRequest> requests = (List<AppointmentRequest>) request.getAttribute("requests");
    boolean hasAssignedDoctor = Boolean.TRUE.equals(request.getAttribute("hasAssignedDoctor"));
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));
    String errorMsg = request.getParameter("error");
    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>

<%@ include file="/WEB-INF/views/fragments/patient-navbar.jspf" %>

<div class="page-main">
    <h1 style="font-size:22px; margin-bottom:16px;"><i class="icon icon-calendar"></i> Appointment Requests</h1>

    <% if (successMsg != null) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> <%= successMsg %></div>
    <% } %>
    <% if ("nodoctor".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> You don't have an assigned doctor yet — an admin needs to assign one first.</div>
    <% } else if ("pastdate".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> Preferred date can't be in the past.</div>
    <% } %>

    <div class="card">
        <div class="card-header"><h3>Request a Follow-up</h3></div>
        <% if (!hasAssignedDoctor) { %>
            <div class="empty-state"><i class="icon icon-user"></i><p>You need an assigned doctor before you can request an appointment.</p></div>
        <% } else { %>
            <form action="/patient/appointments/request" method="post" style="padding:0 20px 20px;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-group" style="margin-bottom:12px;">
                    <label>Reason</label>
                    <textarea name="reason" placeholder="e.g. Follow-up on medication side effects" required></textarea>
                </div>
                <div class="form-group" style="margin-bottom:16px;">
                    <label>Preferred Date</label>
                    <input type="date" name="preferredDate" required />
                </div>
                <button type="submit" class="btn btn-primary">Submit Request</button>
            </form>
        <% } %>
    </div>

    <div class="card">
        <div class="card-header">
            <h3>Your Requests</h3>
            <span class="count-badge"><%= requests != null ? requests.size() : 0 %> total</span>
        </div>
        <% if (requests == null || requests.isEmpty()) { %>
            <div class="empty-state"><i class="icon icon-calendar"></i><p>No appointment requests yet.</p></div>
        <% } else { %>
            <table>
                <tr><th>Reason</th><th>Preferred Date</th><th>Status</th><th>Doctor's Note</th><th>Submitted</th></tr>
                <% for (AppointmentRequest r : requests) { %>
                <tr>
                    <td><%= Esc.h(r.getReason()) %></td>
                    <td><%= r.getPreferredDate() %></td>
                    <td>
                        <% if ("PENDING".equals(r.getStatus())) { %>
                            <span class="badge orange">Pending</span>
                        <% } else if ("APPROVED".equals(r.getStatus())) { %>
                            <span class="badge green">Approved</span>
                        <% } else { %>
                            <span class="badge red">Rejected</span>
                        <% } %>
                    </td>
                    <td><%= r.getDoctorNote() != null ? Esc.h(r.getDoctorNote()) : "&mdash;" %></td>
                    <td><%= r.getCreatedAt().format(fmt) %></td>
                </tr>
                <% } %>
            </table>
        <% } %>
    </div>
</div>

</body>
</html>
