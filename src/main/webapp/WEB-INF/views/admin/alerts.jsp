<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.model.*" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Alerts</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<%
    String activePage = "alerts";

    List<BloodBank> expiredBlood = (List<BloodBank>) request.getAttribute("expiredBlood");
    List<BloodBank> expiringSoonBlood = (List<BloodBank>) request.getAttribute("expiringSoonBlood");
    List<BloodBank> lowStockBlood = (List<BloodBank>) request.getAttribute("lowStockBlood");
    List<OxygenTank> lowOxygenTanks = (List<OxygenTank>) request.getAttribute("lowOxygenTanks");
    List<EquipmentLog> highRiskEquipment = (List<EquipmentLog>) request.getAttribute("highRiskEquipment");
    int totalAlerts = (int) request.getAttribute("totalAlerts");
%>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-alert-triangle"></i> Alerts &amp; Notifications</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <!-- Stats -->
    <div class="stats-row cols-3">
        <div class="stat-card"><div class="value"><%= totalAlerts %></div><div class="label">Active Alerts</div></div>
        <div class="stat-card"><div class="value"><%= expiredBlood.size() + expiringSoonBlood.size() + lowStockBlood.size() %></div><div class="label">Blood Bank Issues</div></div>
        <div class="stat-card"><div class="value"><%= lowOxygenTanks.size() + highRiskEquipment.size() %></div><div class="label">Equipment Issues</div></div>
    </div>

    <% if (totalAlerts == 0) { %>
        <div class="card">
            <div class="empty-state"><i class="icon icon-check-circle"></i><p>All clear — no active alerts right now.</p></div>
        </div>
    <% } %>

    <!-- Blood Bank Alerts -->
    <% if (!expiredBlood.isEmpty() || !expiringSoonBlood.isEmpty() || !lowStockBlood.isEmpty()) { %>
    <div class="card">
        <div class="card-header">
            <h3><i class="icon icon-droplet"></i> Blood Bank</h3>
        </div>

        <% for (BloodBank b : expiredBlood) { %>
        <div class="alert-item danger">
            <i class="icon icon-alert-circle"></i>
            <%= Esc.h(b.getComponent()) %> (<%= Esc.h(b.getBloodGroup()) %>) &mdash; EXPIRED on <%= b.getExpiryDate() %>
        </div>
        <% } %>

        <% for (BloodBank b : expiringSoonBlood) { %>
        <div class="alert-item warning">
            <i class="icon icon-alert-triangle"></i>
            <%= Esc.h(b.getComponent()) %> (<%= Esc.h(b.getBloodGroup()) %>) &mdash; expires in <%= b.getDaysUntilExpiry() %> day(s)
        </div>
        <% } %>

        <% for (BloodBank b : lowStockBlood) { %>
        <div class="alert-item warning">
            <i class="icon icon-alert-triangle"></i>
            <%= Esc.h(b.getComponent()) %> (<%= Esc.h(b.getBloodGroup()) %>) &mdash; low stock: only <%= b.getQuantityUnits() %> unit(s) left
        </div>
        <% } %>
    </div>
    <% } %>

    <!-- Oxygen Alerts -->
    <% if (!lowOxygenTanks.isEmpty()) { %>
    <div class="card">
        <div class="card-header">
            <h3><i class="icon icon-wind"></i> Oxygen Supply</h3>
        </div>
        <% for (OxygenTank t : lowOxygenTanks) {
            float pct = t.getCapacity() > 0 ? (t.getCurrentLevel() / t.getCapacity() * 100f) : 0f; %>
        <div class="alert-item danger">
            <i class="icon icon-alert-circle"></i>
            Tank #<%= t.getTankNo() %> &mdash; <%= String.format("%.0f", pct) %>% remaining (<%= t.getCurrentLevel() %> / <%= t.getCapacity() %>)
        </div>
        <% } %>
    </div>
    <% } %>

    <!-- Equipment Alerts -->
    <% if (!highRiskEquipment.isEmpty()) { %>
    <div class="card">
        <div class="card-header">
            <h3><i class="icon icon-cpu"></i> High-Risk Equipment</h3>
        </div>
        <% for (EquipmentLog log : highRiskEquipment) { %>
        <div class="alert-item danger">
            <i class="icon icon-alert-circle"></i>
            <%= Esc.h(log.getEquipmentType()) %> #<%= log.getEquipmentId() %> &mdash; HIGH failure risk
            (<%= log.getRiskProbability() != null ? String.format("%.0f", log.getRiskProbability()) : "?" %>% probability)
        </div>
        <% } %>
    </div>
    <% } %>

</div>

</body>
</html>
