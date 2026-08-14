<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.hospital.model.AppointmentRequest" %>
<%@ page import="com.hospital.model.Patient" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Doctor - Appointment Requests</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="doctor">

<%
    String activePage = "appointments";

    List<AppointmentRequest> requests = (List<AppointmentRequest>) request.getAttribute("requests");
    Map<Long, Patient> patientMap = (Map<Long, Patient>) request.getAttribute("patientMap");
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));
    String errorMsg = request.getParameter("error");
    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>

<%@ include file="/WEB-INF/views/fragments/doctor-navbar.jspf" %>

<div class="page-main">
    <h1 style="font-size:22px; margin-bottom:16px;"><i class="icon icon-calendar"></i> Appointment Requests</h1>

    <% if (successMsg != null) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> <%= successMsg %></div>
    <% } %>
    <% if ("notauthorized".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> You can only respond to requests addressed to you.</div>
    <% } else if ("notfound".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> That request no longer exists.</div>
    <% } %>

    <div class="card">
        <div class="card-header">
            <h3>Patient Requests</h3>
            <span class="count-badge"><%= requests != null ? requests.size() : 0 %> total</span>
        </div>
        <% if (requests == null || requests.isEmpty()) { %>
            <div class="empty-state"><i class="icon icon-calendar"></i><p>No appointment requests yet.</p></div>
        <% } else { %>
            <table>
                <tr><th>Patient</th><th>Reason</th><th>Preferred Date</th><th>Status</th><th>Action</th></tr>
                <% for (AppointmentRequest r : requests) {
                    Patient p = patientMap != null ? patientMap.get(r.getPatientId()) : null;
                %>
                <tr>
                    <td><%= p != null ? Esc.h(p.getName()) : "Unknown" %></td>
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
                    <td>
                        <% if ("PENDING".equals(r.getStatus())) { %>
                            <form action="/doctor/appointments/respond" method="post" class="inline-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="requestId" value="<%= r.getId() %>" />
                                <input type="hidden" name="decision" value="APPROVED" />
                                <button type="submit" class="btn btn-primary btn-sm">Approve</button>
                            </form>
                            <form action="/doctor/appointments/respond" method="post" class="inline-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="requestId" value="<%= r.getId() %>" />
                                <input type="hidden" name="decision" value="REJECTED" />
                                <button type="submit" class="btn btn-danger btn-sm">Reject</button>
                            </form>
                        <% } else { %>
                            &mdash;
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </table>
        <% } %>
    </div>
</div>

</body>
</html>
