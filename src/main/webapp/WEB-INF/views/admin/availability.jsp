<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.hospital.model.Doctor" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Doctor Availability</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<%
    String activePage = "availability";

    List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");
    Map<Long, Map<String, Boolean>> grid = (Map<Long, Map<String, Boolean>>) request.getAttribute("grid");
    List<String> days = (List<String>) request.getAttribute("days");
%>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-calendar"></i> Doctor Availability Calendar</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <div class="card">
        <div class="card-header">
            <h3>Weekly Schedule</h3>
            <span class="count-badge"><%= doctors != null ? doctors.size() : 0 %> doctors</span>
        </div>

        <% if (doctors == null || doctors.isEmpty()) { %>
            <div class="empty-state"><i class="icon icon-user"></i><p>No doctors registered yet.</p></div>
        <% } else { %>
            <div style="overflow-x:auto;">
            <table>
                <tr>
                    <th>Doctor</th>
                    <% for (String day : days) { %>
                        <th><%= day.substring(0,3) %></th>
                    <% } %>
                </tr>
                <% for (Doctor d : doctors) {
                    Map<String, Boolean> row = grid.get(d.getId());
                %>
                <tr>
                    <td><strong>Dr. <%= Esc.h(d.getName()) %></strong></td>
                    <% for (String day : days) {
                        boolean isAvailable = row != null && Boolean.TRUE.equals(row.get(day));
                    %>
                        <td>
                            <% if (isAvailable) { %>
                                <span class="badge green">On</span>
                            <% } else { %>
                                <span class="badge grey">Off</span>
                            <% } %>
                        </td>
                    <% } %>
                </tr>
                <% } %>
            </table>
            </div>
        <% } %>
    </div>

</div>

</body>
</html>
