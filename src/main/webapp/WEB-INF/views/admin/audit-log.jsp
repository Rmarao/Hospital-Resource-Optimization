<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.model.AuditLog" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Audit Log</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<%
    String activePage = "audit-log";

    List<AuditLog> logs = (List<AuditLog>) request.getAttribute("logs");
    java.time.format.DateTimeFormatter logFmt = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm:ss");
%>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-clipboard"></i> Audit Log</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <!-- Stats -->
    <div class="stats-row cols-3">
        <div class="stat-card"><div class="value"><%= logs != null ? logs.size() : 0 %></div><div class="label">Recent Events</div></div>
        <div class="stat-card"><div class="value">100</div><div class="label">Log Window</div></div>
        <div class="stat-card"><div class="value">Newest First</div><div class="label">Sort Order</div></div>
    </div>

    <!-- Log Table -->
    <div class="card">
        <div class="card-header">
            <h3>Recent Activity</h3>
            <span class="count-badge"><%= logs != null ? logs.size() : 0 %> events</span>
        </div>

        <% if (logs == null || logs.isEmpty()) { %>
            <div class="empty-state"><i class="icon icon-clipboard"></i><p>No activity recorded yet.</p></div>
        <% } else { %>
            <table>
                <tr>
                    <th>Time</th><th>Actor</th><th>Action</th><th>Entity</th><th>Details</th>
                </tr>
                <% for (AuditLog log : logs) { %>
                <tr>
                    <td><%= log.getCreatedAt() != null ? log.getCreatedAt().format(logFmt) : "N/A" %></td>
                    <td>
                        <span class="badge blue"><%= Esc.h(log.getActorRole() != null ? log.getActorRole() : "SYSTEM") %></span>
                        <% if (log.getActorId() != null) { %> #<%= log.getActorId() %><% } %>
                    </td>
                    <td><span class="badge purple"><%= Esc.h(log.getAction()) %></span></td>
                    <td><%= Esc.h(log.getEntityType()) %><% if (log.getEntityId() != null) { %> #<%= Esc.h(log.getEntityId()) %><% } %></td>
                    <td><%= Esc.h(log.getDetails()) %></td>
                </tr>
                <% } %>
            </table>
        <% } %>
    </div>

</div>

</body>
</html>
