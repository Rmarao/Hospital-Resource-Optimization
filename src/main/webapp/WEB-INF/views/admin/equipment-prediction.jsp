<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.hospital.model.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Equipment Failure Prediction</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<%
    String activePage = "equipment";

    EquipmentLog latestXRay = (EquipmentLog) request.getAttribute("latestXRay");
    EquipmentLog latestCT = (EquipmentLog) request.getAttribute("latestCT");
    EquipmentLog latestMRI = (EquipmentLog) request.getAttribute("latestMRI");
    List<EquipmentLog> xrayHistory = (List<EquipmentLog>) request.getAttribute("xrayHistory");
    List<EquipmentLog> ctHistory = (List<EquipmentLog>) request.getAttribute("ctHistory");
    List<EquipmentLog> mriHistory = (List<EquipmentLog>) request.getAttribute("mriHistory");
    int highRiskCount = (int) request.getAttribute("highRiskCount");

    String simulated = request.getParameter("simulated") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("simulated"));

    String xrayRisk = latestXRay != null ? latestXRay.getPredictedRisk() : "NO DATA";
    String ctRisk = latestCT != null ? latestCT.getPredictedRisk() : "NO DATA";
    String mriRisk = latestMRI != null ? latestMRI.getPredictedRisk() : "NO DATA";
%>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-cpu"></i> Machine Failure Prediction</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <% if (simulated != null) { %>
        <div class="alert success">
            <i class="icon icon-check-circle"></i> Simulated sensor reading for
            <strong><%= simulated.equals("ALL") ? "all equipment" : simulated %></strong>
            — prediction updated!
        </div>
    <% } %>

    <div class="alert info">
        <i class="icon icon-sparkles"></i> Predictions powered by a CART decision tree (Tribuo) trained on the AI4I 2020
        Predictive Maintenance Dataset, mapped to hospital equipment parameters.
    </div>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="value" style="color:<%= xrayRisk.equals("HIGH") ? "var(--danger)" : xrayRisk.equals("MEDIUM") ? "var(--warning)" : "var(--success)" %>">
                <%= xrayRisk %>
            </div>
            <div class="label">X-Ray Status</div>
        </div>
        <div class="stat-card">
            <div class="value" style="color:<%= ctRisk.equals("HIGH") ? "var(--danger)" : ctRisk.equals("MEDIUM") ? "var(--warning)" : "var(--success)" %>">
                <%= ctRisk %>
            </div>
            <div class="label">CT Scan Status</div>
        </div>
        <div class="stat-card">
            <div class="value" style="color:<%= mriRisk.equals("HIGH") ? "var(--danger)" : mriRisk.equals("MEDIUM") ? "var(--warning)" : "var(--success)" %>">
                <%= mriRisk %>
            </div>
            <div class="label">MRI Status</div>
        </div>
        <div class="stat-card">
            <div class="value" style="color:<%= highRiskCount > 0 ? "var(--danger)" : "var(--success)" %>">
                <%= highRiskCount %>
            </div>
            <div class="label">High Risk Alerts</div>
        </div>
    </div>

    <!-- Simulate All -->
    <form action="/admin/equipment-prediction/simulate-all" method="post" style="margin-bottom:28px;">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        <button type="submit" class="btn btn-primary"><i class="icon icon-refresh"></i> Simulate All Equipment Readings</button>
    </form>

    <!-- Equipment Cards -->
    <div class="grid-3">

        <!-- X-Ray -->
        <div class="equipment-card">
            <div class="equipment-card-header xray">
                <div class="icon-wrap"><i class="icon icon-cpu"></i></div>
                <div>
                    <div class="equipment-name">X-Ray Machine</div>
                    <div class="equipment-sub">
                        Last reading:
                        <%= latestXRay != null ? latestXRay.getLogTime().toString().substring(0,16) : "Never" %>
                    </div>
                </div>
            </div>
            <div class="equipment-card-body">
                <% if (latestXRay != null) { %>
                    <div class="risk-meter">
                        <div class="risk-label">
                            <span>Failure Risk</span>
                            <span class="risk-value <%= latestXRay.getPredictedRisk() %>">
                                <%= latestXRay.getPredictedRisk() %>
                                (<%= latestXRay.getRiskProbability().intValue() %>%)
                            </span>
                        </div>
                        <div class="risk-bar">
                            <div class="risk-fill <%= latestXRay.getPredictedRisk() %>"
                                 style="width:<%= latestXRay.getRiskProbability().intValue() %>%"></div>
                        </div>
                    </div>
                    <div class="sensor-grid">
                        <div class="sensor-item"><div class="sensor-label">Room Temp</div><div class="sensor-value"><%= String.format("%.1f", latestXRay.getRoomTemperature()) %>&deg;C</div></div>
                        <div class="sensor-item"><div class="sensor-label">Internal Temp</div><div class="sensor-value"><%= String.format("%.1f", latestXRay.getInternalTemperature()) %>&deg;C</div></div>
                        <div class="sensor-item"><div class="sensor-label">Operating Hours</div><div class="sensor-value"><%= String.format("%.0f", latestXRay.getOperatingHours()) %>h</div></div>
                        <div class="sensor-item"><div class="sensor-label">Error Count</div><div class="sensor-value"><%= latestXRay.getErrorCount() %></div></div>
                        <div class="sensor-item"><div class="sensor-label">Power Fluctuation</div><div class="sensor-value"><%= String.format("%.2f", latestXRay.getPowerFluctuation()) %></div></div>
                        <div class="sensor-item"><div class="sensor-label">Days Since Service</div><div class="sensor-value"><%= latestXRay.getDaysSinceMaintenance() %></div></div>
                    </div>
                <% } else { %>
                    <div class="no-data">No readings yet. Run simulation.</div>
                <% } %>
                <form action="/admin/equipment-prediction/simulate" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    <input type="hidden" name="equipmentType" value="X_RAY" />
                    <button type="submit" class="btn btn-info btn-block"><i class="icon icon-refresh"></i> Simulate X-Ray Reading</button>
                </form>
            </div>
        </div>

        <!-- CT Scan -->
        <div class="equipment-card">
            <div class="equipment-card-header ct">
                <div class="icon-wrap"><i class="icon icon-cpu"></i></div>
                <div>
                    <div class="equipment-name">CT Scan Machine</div>
                    <div class="equipment-sub">
                        Last reading:
                        <%= latestCT != null ? latestCT.getLogTime().toString().substring(0,16) : "Never" %>
                    </div>
                </div>
            </div>
            <div class="equipment-card-body">
                <% if (latestCT != null) { %>
                    <div class="risk-meter">
                        <div class="risk-label">
                            <span>Failure Risk</span>
                            <span class="risk-value <%= latestCT.getPredictedRisk() %>">
                                <%= latestCT.getPredictedRisk() %>
                                (<%= latestCT.getRiskProbability().intValue() %>%)
                            </span>
                        </div>
                        <div class="risk-bar">
                            <div class="risk-fill <%= latestCT.getPredictedRisk() %>"
                                 style="width:<%= latestCT.getRiskProbability().intValue() %>%"></div>
                        </div>
                    </div>
                    <div class="sensor-grid">
                        <div class="sensor-item"><div class="sensor-label">Room Temp</div><div class="sensor-value"><%= String.format("%.1f", latestCT.getRoomTemperature()) %>&deg;C</div></div>
                        <div class="sensor-item"><div class="sensor-label">Internal Temp</div><div class="sensor-value"><%= String.format("%.1f", latestCT.getInternalTemperature()) %>&deg;C</div></div>
                        <div class="sensor-item"><div class="sensor-label">Operating Hours</div><div class="sensor-value"><%= String.format("%.0f", latestCT.getOperatingHours()) %>h</div></div>
                        <div class="sensor-item"><div class="sensor-label">Error Count</div><div class="sensor-value"><%= latestCT.getErrorCount() %></div></div>
                        <div class="sensor-item"><div class="sensor-label">Power Fluctuation</div><div class="sensor-value"><%= String.format("%.2f", latestCT.getPowerFluctuation()) %></div></div>
                        <div class="sensor-item"><div class="sensor-label">Days Since Service</div><div class="sensor-value"><%= latestCT.getDaysSinceMaintenance() %></div></div>
                    </div>
                <% } else { %>
                    <div class="no-data">No readings yet. Run simulation.</div>
                <% } %>
                <form action="/admin/equipment-prediction/simulate" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    <input type="hidden" name="equipmentType" value="CT_SCAN" />
                    <button type="submit" class="btn btn-ai btn-block"><i class="icon icon-refresh"></i> Simulate CT Scan Reading</button>
                </form>
            </div>
        </div>

        <!-- MRI -->
        <div class="equipment-card">
            <div class="equipment-card-header mri">
                <div class="icon-wrap"><i class="icon icon-cpu"></i></div>
                <div>
                    <div class="equipment-name">MRI Machine</div>
                    <div class="equipment-sub">
                        Last reading:
                        <%= latestMRI != null ? latestMRI.getLogTime().toString().substring(0,16) : "Never" %>
                    </div>
                </div>
            </div>
            <div class="equipment-card-body">
                <% if (latestMRI != null) { %>
                    <div class="risk-meter">
                        <div class="risk-label">
                            <span>Failure Risk</span>
                            <span class="risk-value <%= latestMRI.getPredictedRisk() %>">
                                <%= latestMRI.getPredictedRisk() %>
                                (<%= latestMRI.getRiskProbability().intValue() %>%)
                            </span>
                        </div>
                        <div class="risk-bar">
                            <div class="risk-fill <%= latestMRI.getPredictedRisk() %>"
                                 style="width:<%= latestMRI.getRiskProbability().intValue() %>%"></div>
                        </div>
                    </div>
                    <div class="sensor-grid">
                        <div class="sensor-item"><div class="sensor-label">Room Temp</div><div class="sensor-value"><%= String.format("%.1f", latestMRI.getRoomTemperature()) %>&deg;C</div></div>
                        <div class="sensor-item"><div class="sensor-label">Internal Temp</div><div class="sensor-value"><%= String.format("%.1f", latestMRI.getInternalTemperature()) %>&deg;C</div></div>
                        <div class="sensor-item"><div class="sensor-label">Operating Hours</div><div class="sensor-value"><%= String.format("%.0f", latestMRI.getOperatingHours()) %>h</div></div>
                        <div class="sensor-item"><div class="sensor-label">Error Count</div><div class="sensor-value"><%= latestMRI.getErrorCount() %></div></div>
                        <div class="sensor-item"><div class="sensor-label">Power Fluctuation</div><div class="sensor-value"><%= String.format("%.2f", latestMRI.getPowerFluctuation()) %></div></div>
                        <div class="sensor-item"><div class="sensor-label">Days Since Service</div><div class="sensor-value"><%= latestMRI.getDaysSinceMaintenance() %></div></div>
                    </div>
                <% } else { %>
                    <div class="no-data">No readings yet. Run simulation.</div>
                <% } %>
                <form action="/admin/equipment-prediction/simulate" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    <input type="hidden" name="equipmentType" value="MRI" />
                    <button type="submit" class="btn btn-success btn-block"><i class="icon icon-refresh"></i> Simulate MRI Reading</button>
                </form>
            </div>
        </div>

    </div>

    <!-- History Tables -->
    <div style="margin-top:32px;">
        <h2 style="font-size:18px; margin-bottom:20px; display:flex; align-items:center; gap:8px;">
            <i class="icon icon-file-text"></i> Recent Reading History
        </h2>
        <div class="grid-3">

            <div class="card" style="margin-bottom:0;">
                <div class="card-header"><h3><i class="icon icon-cpu"></i> X-Ray History</h3></div>
                <% if (xrayHistory == null || xrayHistory.isEmpty()) { %>
                    <div class="no-data">No history yet.</div>
                <% } else { %>
                    <table>
                        <tr><th>Time</th><th>Temp</th><th>Hours</th><th>Risk</th></tr>
                        <% for (EquipmentLog log : xrayHistory) { %>
                        <tr>
                            <td><%= log.getLogTime().toString().substring(11,16) %></td>
                            <td><%= String.format("%.0f", log.getRoomTemperature()) %>&deg;C</td>
                            <td><%= String.format("%.0f", log.getOperatingHours()) %>h</td>
                            <td><span class="badge <%= log.getPredictedRisk() %>"><%= log.getPredictedRisk() %></span></td>
                        </tr>
                        <% } %>
                    </table>
                <% } %>
            </div>

            <div class="card" style="margin-bottom:0;">
                <div class="card-header"><h3><i class="icon icon-cpu"></i> CT Scan History</h3></div>
                <% if (ctHistory == null || ctHistory.isEmpty()) { %>
                    <div class="no-data">No history yet.</div>
                <% } else { %>
                    <table>
                        <tr><th>Time</th><th>Temp</th><th>Hours</th><th>Risk</th></tr>
                        <% for (EquipmentLog log : ctHistory) { %>
                        <tr>
                            <td><%= log.getLogTime().toString().substring(11,16) %></td>
                            <td><%= String.format("%.0f", log.getRoomTemperature()) %>&deg;C</td>
                            <td><%= String.format("%.0f", log.getOperatingHours()) %>h</td>
                            <td><span class="badge <%= log.getPredictedRisk() %>"><%= log.getPredictedRisk() %></span></td>
                        </tr>
                        <% } %>
                    </table>
                <% } %>
            </div>

            <div class="card" style="margin-bottom:0;">
                <div class="card-header"><h3><i class="icon icon-cpu"></i> MRI History</h3></div>
                <% if (mriHistory == null || mriHistory.isEmpty()) { %>
                    <div class="no-data">No history yet.</div>
                <% } else { %>
                    <table>
                        <tr><th>Time</th><th>Temp</th><th>Hours</th><th>Risk</th></tr>
                        <% for (EquipmentLog log : mriHistory) { %>
                        <tr>
                            <td><%= log.getLogTime().toString().substring(11,16) %></td>
                            <td><%= String.format("%.0f", log.getRoomTemperature()) %>&deg;C</td>
                            <td><%= String.format("%.0f", log.getOperatingHours()) %>h</td>
                            <td><span class="badge <%= log.getPredictedRisk() %>"><%= log.getPredictedRisk() %></span></td>
                        </tr>
                        <% } %>
                    </table>
                <% } %>
            </div>

        </div>
    </div>

</div>

</body>
</html>
