<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.hospital.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Patient - Fitness</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="patient">

<%
    String activePage = "fitness";

    boolean isConnected = (request.getAttribute("isConnected") != null) ? (boolean) request.getAttribute("isConnected") : false;
    String authUrl = (String) request.getAttribute("authUrl");

    int steps = (request.getAttribute("steps") != null) ? (int) request.getAttribute("steps") : 0;
    int calories = (request.getAttribute("calories") != null) ? (int) request.getAttribute("calories") : 0;
    int heartRate = (request.getAttribute("heartRate") != null) ? (int) request.getAttribute("heartRate") : 0;

    int stepsPct = Math.min((steps * 100) / 10000, 100);
    int calPct = Math.min((calories * 100) / 500, 100);
%>

<%@ include file="/WEB-INF/views/fragments/patient-navbar.jspf" %>

<div class="page-main">
    <div class="page-header">
        <h1><i class="icon icon-heart"></i> Fitness &amp; Health Tracker</h1>
        <p>Sync your Google Fit account to share data with your medical team.</p>
    </div>

    <% if ("true".equals(request.getParameter("connected"))) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> Google Fit connected successfully!</div>
    <% } %>

    <% if (!isConnected) { %>
        <div class="connect-section">
            <div class="icon-wrap"><i class="icon icon-link"></i></div>
            <h2>Connect Google Fit</h2>
            <p>Link your Google account to automatically sync your daily activity.</p>
            <% if (authUrl != null) { %>
                <a href="<%= authUrl %>" class="connect-btn"><i class="icon icon-link"></i> Connect Google Fit</a>
            <% } else { %>
                <p style="color:var(--danger);"><i class="icon icon-alert-triangle"></i> Authentication Service Unavailable.</p>
            <% } %>
        </div>
    <% } else { %>

        <div class="connected-banner">
            <div class="icon-wrap"><i class="icon icon-check-circle"></i></div>
            <div class="info">
                <div class="title">Google Fit Connected</div>
                <div class="sub">Your activity data is currently syncing.</div>
            </div>
            <% if (authUrl != null) { %>
                <a href="<%= authUrl %>" class="reconnect-btn"><i class="icon icon-refresh"></i> Reconnect</a>
            <% } %>
        </div>

        <div class="stats-row cols-3">
            <div class="stat-card">
                <div class="icon-wrap" style="margin:0 auto 8px;"><i class="icon icon-activity"></i></div>
                <div class="value"><%= String.format("%,d", steps) %></div>
                <div class="unit" style="font-size:12px; color:var(--text-mute);">steps today</div>
                <div class="label">Daily Steps</div>
            </div>
            <div class="stat-card">
                <div class="icon-wrap" style="margin:0 auto 8px;"><i class="icon icon-flame"></i></div>
                <div class="value"><%= calories %></div>
                <div class="unit" style="font-size:12px; color:var(--text-mute);">kcal burned</div>
                <div class="label">Calories</div>
            </div>
            <div class="stat-card">
                <div class="icon-wrap" style="margin:0 auto 8px;"><i class="icon icon-heart"></i></div>
                <div class="value"><%= heartRate %></div>
                <div class="unit" style="font-size:12px; color:var(--text-mute);">bpm (current)</div>
                <div class="label">Heart Rate</div>
            </div>
        </div>

        <div class="content-grid">
            <div class="card">
                <div class="card-header"><h3><i class="icon icon-zap"></i> Daily Goals</h3></div>
                <div class="goal-item">
                    <div class="goal-header">
                        <span><i class="icon icon-activity"></i> Steps</span>
                        <span><%= String.format("%,d", steps) %> / 10,000</span>
                    </div>
                    <div class="progress-bar"><div class="progress-fill" style="width:<%= stepsPct %>%"></div></div>
                </div>
                <div class="goal-item">
                    <div class="goal-header">
                        <span><i class="icon icon-flame"></i> Calories</span>
                        <span><%= calories %> / 500 kcal</span>
                    </div>
                    <div class="progress-bar"><div class="progress-fill" style="width:<%= calPct %>%; background:var(--warning);"></div></div>
                </div>
            </div>
        </div>
    <% } %>
</div>
</body>
</html>
