<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Labs</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<% String activePage = "labs"; %>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-flask"></i> Lab Management</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <div class="note">
        <i class="icon icon-info"></i> This page will be connected to lab data in a future update.
        Below is a preview of the lab management interface.
    </div>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat-card"><div class="value">4</div><div class="label">Total Labs</div></div>
        <div class="stat-card"><div class="value">3</div><div class="label">Available</div></div>
        <div class="stat-card"><div class="value">2</div><div class="label">Tests Today</div></div>
        <div class="stat-card"><div class="value">1</div><div class="label">Pending Results</div></div>
    </div>

    <div class="content-grid">

        <!-- Lab Units -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-flask"></i> Lab Units</h3>
                <span class="count-badge">4 labs</span>
            </div>
            <table>
                <tr><th>Lab</th><th>Type</th><th>Status</th><th>Capacity</th></tr>
                <tr>
                    <td><strong>Lab 1</strong></td>
                    <td><span class="badge blue">Pathology</span></td>
                    <td><span class="badge green">Available</span></td>
                    <td>10 tests/day</td>
                </tr>
                <tr>
                    <td><strong>Lab 2</strong></td>
                    <td><span class="badge blue">Radiology</span></td>
                    <td><span class="badge green">Available</span></td>
                    <td>8 tests/day</td>
                </tr>
                <tr>
                    <td><strong>Lab 3</strong></td>
                    <td><span class="badge blue">Microbiology</span></td>
                    <td><span class="badge orange">In Use</span></td>
                    <td>12 tests/day</td>
                </tr>
                <tr>
                    <td><strong>Lab 4</strong></td>
                    <td><span class="badge blue">Biochemistry</span></td>
                    <td><span class="badge green">Available</span></td>
                    <td>15 tests/day</td>
                </tr>
            </table>
        </div>

        <!-- Today's Schedule -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-calendar"></i> Today's Lab Schedule</h3>
                <span class="count-badge">2 scheduled</span>
            </div>
            <div class="schedule-card">
                <div class="schedule-info">
                    <div class="title">Blood Culture Test</div>
                    <div class="sub">Lab 1 &middot; Pathology &middot; 10:00 AM &middot; John Doe</div>
                </div>
                <span class="badge orange">Scheduled</span>
            </div>
            <div class="schedule-card">
                <div class="schedule-info">
                    <div class="title">X-Ray Chest</div>
                    <div class="sub">Lab 2 &middot; Radiology &middot; 02:00 PM &middot; Mary Jane</div>
                </div>
                <span class="badge green">Completed</span>
            </div>
        </div>

        <!-- Pending Results -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-alert-circle"></i> Pending Results</h3>
                <span class="count-badge">1 pending</span>
            </div>
            <div class="schedule-card">
                <div class="schedule-info">
                    <div class="title">CBC Test &mdash; Robert Singh</div>
                    <div class="sub">Lab 3 &middot; Microbiology &middot; Collected yesterday</div>
                </div>
                <span class="badge orange">Pending</span>
            </div>
        </div>

        <!-- Lab Types -->
        <div class="card">
            <div class="card-header"><h3><i class="icon icon-flask"></i> Common Tests Offered</h3></div>
            <table>
                <tr><th>Test Name</th><th>Lab</th><th>Avg Duration</th></tr>
                <tr><td>Complete Blood Count (CBC)</td><td>Pathology</td><td>2 hrs</td></tr>
                <tr><td>Blood Culture</td><td>Microbiology</td><td>24-48 hrs</td></tr>
                <tr><td>X-Ray</td><td>Radiology</td><td>30 min</td></tr>
                <tr><td>MRI Scan</td><td>Radiology</td><td>1-2 hrs</td></tr>
                <tr><td>Liver Function Test</td><td>Biochemistry</td><td>4 hrs</td></tr>
                <tr><td>Urine Analysis</td><td>Pathology</td><td>1 hr</td></tr>
            </table>
        </div>

    </div>
</div>

</body>
</html>
