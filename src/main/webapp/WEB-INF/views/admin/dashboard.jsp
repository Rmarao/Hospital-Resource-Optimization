<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.hospital.model.*" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<%
    String activePage = "dashboard";

    Admin admin = (Admin) request.getAttribute("admin");
    String name = Esc.h((admin != null) ? admin.getName() : "Admin");

    long totalBeds = request.getAttribute("totalBeds") != null
            ? ((Number) request.getAttribute("totalBeds")).longValue() : 0L;
    long availableBeds = request.getAttribute("availableBeds") != null
            ? ((Number) request.getAttribute("availableBeds")).longValue() : 0L;
    long occupiedBeds = request.getAttribute("occupiedBeds") != null
            ? ((Number) request.getAttribute("occupiedBeds")).longValue() : 0L;
    long totalIcu = request.getAttribute("totalIcu") != null
            ? ((Number) request.getAttribute("totalIcu")).longValue() : 0L;
    long availableIcu = request.getAttribute("availableIcu") != null
            ? ((Number) request.getAttribute("availableIcu")).longValue() : 0L;
    long occupiedIcu = request.getAttribute("occupiedIcu") != null
            ? ((Number) request.getAttribute("occupiedIcu")).longValue() : 0L;
    long totalOt = request.getAttribute("totalOt") != null
            ? ((Number) request.getAttribute("totalOt")).longValue() : 0L;
    long availableOt = request.getAttribute("availableOt") != null
            ? ((Number) request.getAttribute("availableOt")).longValue() : 0L;
    long totalOxygen = request.getAttribute("totalOxygen") != null
            ? ((Number) request.getAttribute("totalOxygen")).longValue() : 0L;
    long availableOxygen = request.getAttribute("availableOxygen") != null
            ? ((Number) request.getAttribute("availableOxygen")).longValue() : 0L;
    long totalDoctors = request.getAttribute("totalDoctors") != null
            ? ((Number) request.getAttribute("totalDoctors")).longValue() : 0L;
    long totalPatients = request.getAttribute("totalPatients") != null
            ? ((Number) request.getAttribute("totalPatients")).longValue() : 0L;

    List<Doctor> recentDoctors = (List<Doctor>) request.getAttribute("recentDoctors");
    List<Patient> recentPatients = (List<Patient>) request.getAttribute("recentPatients");
    List<OtSchedule> todayOtSchedules = (List<OtSchedule>) request.getAttribute("todayOtSchedules");
    List<BedAdmission> activeBedAdmissions = (List<BedAdmission>) request.getAttribute("activeBedAdmissions");
    List<BloodBank> bloodBanks = (List<BloodBank>) request.getAttribute("bloodBanks");
    Map<Long, String> patientNameMap = (Map<Long, String>) request.getAttribute("patientNameMap");
    Map<Long, String> doctorNameMap = (Map<Long, String>) request.getAttribute("doctorNameMap");
    Map<String, Integer> riskDistribution = (Map<String, Integer>) request.getAttribute("riskDistribution");

    int bedPct = totalBeds > 0 ? (int)((occupiedBeds * 100) / totalBeds) : 0;
    int icuPct = totalIcu > 0 ? (int)((occupiedIcu * 100) / totalIcu) : 0;
    int otPct = totalOt > 0 ? (int)(((totalOt - availableOt) * 100) / totalOt) : 0;
    int oxygenPct = totalOxygen > 0 ? (int)(((totalOxygen - availableOxygen) * 100) / totalOxygen) : 0;
    String bedTone = bedPct > 80 ? "red" : bedPct > 60 ? "orange" : "green";
    String icuTone = icuPct > 80 ? "red" : icuPct > 60 ? "orange" : "green";
    String otTone  = otPct  > 80 ? "red" : otPct  > 60 ? "orange" : "green";
    String oxygenTone = oxygenPct > 80 ? "red" : oxygenPct > 60 ? "orange" : "green";

    int totalRiskPatients = 0;
    if (riskDistribution != null) {
        for (int v : riskDistribution.values()) totalRiskPatients += v;
    }

    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("EEEE, MMMM dd yyyy");
    String today = java.time.LocalDate.now().format(fmt);
%>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-grid"></i> Dashboard Overview</h2>
    <div style="display:flex; align-items:center; gap:16px;">
        <span class="date"><i class="icon icon-calendar"></i> <%= today %></span>
        <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
    </div>
</div>

<!-- Main -->
<div class="main">
    <div class="page-header" style="margin-bottom:28px;">
        <h1 style="font-size:24px;">Welcome back, <%= name %></h1>
        <p>Here's what's happening in the hospital today.</p>
    </div>

    <!-- Stats Row 1 -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-bed"></i></div>
            <div class="value"><%= totalBeds %></div>
            <div class="label">Total Beds</div>
            <div class="sub"><%= availableBeds %> Available &middot; <%= occupiedBeds %> Occupied</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-activity"></i></div>
            <div class="value"><%= totalIcu %></div>
            <div class="label">ICU Units</div>
            <div class="sub"><%= availableIcu %> Available &middot; <%= occupiedIcu %> Occupied</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-scissors"></i></div>
            <div class="value"><%= totalOt %></div>
            <div class="label">Operation Theatres</div>
            <div class="sub"><%= availableOt %> Available</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-wind"></i></div>
            <div class="value"><%= totalOxygen %></div>
            <div class="label">Oxygen Tanks</div>
            <div class="sub">Total tanks</div>
        </div>
    </div>

    <!-- Stats Row 2 -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-user"></i></div>
            <div class="value"><%= totalDoctors %></div>
            <div class="label">Doctors</div>
            <div class="sub">Active staff</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-users"></i></div>
            <div class="value"><%= totalPatients %></div>
            <div class="label">Patients</div>
            <div class="sub">Registered patients</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-bed"></i></div>
            <div class="value"><%= activeBedAdmissions != null ? activeBedAdmissions.size() : 0 %></div>
            <div class="label">Active Admissions</div>
            <div class="sub">Currently admitted</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-calendar"></i></div>
            <div class="value"><%= todayOtSchedules != null ? todayOtSchedules.size() : 0 %></div>
            <div class="label">OT Today</div>
            <div class="sub">Procedures scheduled</div>
        </div>
    </div>

    <!-- Content Grid -->
    <div class="content-grid">

        <!-- Resource Utilization -->
        <div class="card">
            <div class="card-header"><h3><i class="icon icon-grid"></i> Resource Utilization</h3></div>
            <div class="resource-row">
                <span>General Beds</span>
                <span class="badge <%= bedTone %>"><%= bedPct %>%</span>
            </div>
            <div class="progress-bar"><div class="progress-fill <%= bedTone %>" style="width:<%= bedPct %>%"></div></div>

            <div class="resource-row" style="margin-top:12px">
                <span>ICU Units</span>
                <span class="badge <%= icuTone %>"><%= icuPct %>%</span>
            </div>
            <div class="progress-bar"><div class="progress-fill <%= icuTone %>" style="width:<%= icuPct %>%"></div></div>

            <div class="resource-row" style="margin-top:12px">
                <span>Operation Theatres</span>
                <span class="badge <%= otTone %>"><%= otPct %>%</span>
            </div>
            <div class="progress-bar"><div class="progress-fill <%= otTone %>" style="width:<%= otPct %>%"></div></div>

            <div class="resource-row" style="margin-top:12px">
                <span>Oxygen Tanks</span>
                <span class="badge <%= oxygenTone %>"><%= oxygenPct %>%</span>
            </div>
            <div class="progress-bar"><div class="progress-fill <%= oxygenTone %>" style="width:<%= oxygenPct %>%"></div></div>
        </div>

        <!-- Patient Risk Distribution -->
        <div class="card">
            <div class="card-header"><h3><i class="icon icon-activity"></i> Patient Risk Distribution</h3></div>
            <% if (totalRiskPatients == 0) { %>
                <div class="empty-state"><i class="icon icon-activity"></i><p>No patients analysed yet.</p></div>
            <% } else {
                String[] levels = {"LOW", "MEDIUM", "HIGH", "CRITICAL"};
                String[] tones = {"green", "orange", "red", "purple"};
                for (int li = 0; li < levels.length; li++) {
                    int count = riskDistribution.getOrDefault(levels[li], 0);
                    int pct = totalRiskPatients > 0 ? (count * 100) / totalRiskPatients : 0;
            %>
                <div class="resource-row" style="margin-top:<%= li == 0 ? 0 : 12 %>px">
                    <span><%= levels[li] %></span>
                    <span class="badge <%= levels[li] %>"><%= count %> patient<%= count == 1 ? "" : "s" %></span>
                </div>
                <div class="progress-bar"><div class="progress-fill <%= tones[li] %>" style="width:<%= pct %>%"></div></div>
            <% } } %>
        </div>

        <!-- AI Recommendations -->
        <div class="card">
            <div class="card-header"><h3><i class="icon icon-sparkles"></i> AI Recommendations</h3></div>
            <% if (bedPct > 80) { %><div class="alert-item danger"><i class="icon icon-alert-circle"></i> Bed utilization critical (<%= bedPct %>%)</div>
            <% } else if (bedPct > 60) { %><div class="alert-item warning"><i class="icon icon-alert-triangle"></i> Bed utilization high (<%= bedPct %>%)</div>
            <% } else { %><div class="alert-item success"><i class="icon icon-check-circle"></i> Bed utilization optimal (<%= bedPct %>%)</div><% } %>

            <% if (icuPct > 80) { %><div class="alert-item danger"><i class="icon icon-alert-circle"></i> ICU utilization critical (<%= icuPct %>%)</div>
            <% } else if (icuPct > 60) { %><div class="alert-item warning"><i class="icon icon-alert-triangle"></i> ICU utilization high (<%= icuPct %>%)</div>
            <% } else { %><div class="alert-item success"><i class="icon icon-check-circle"></i> ICU utilization optimal (<%= icuPct %>%)</div><% } %>

            <% if (totalOt == 0) { %><div class="alert-item info"><i class="icon icon-info"></i> No OTs configured</div>
            <% } else if (availableOt == 0) { %><div class="alert-item danger"><i class="icon icon-alert-circle"></i> All OTs occupied</div>
            <% } else { %><div class="alert-item success"><i class="icon icon-check-circle"></i> <%= availableOt %> OT(s) available</div><% } %>

            <% if (bloodBanks != null) { for (BloodBank b : bloodBanks) {
                if (b.isExpired()) { %><div class="alert-item danger"><i class="icon icon-alert-circle"></i> <%= Esc.h(b.getComponent()) %> (<%= Esc.h(b.getBloodGroup()) %>) EXPIRED</div>
                <% } else if (b.getDaysUntilExpiry() <= 3) { %><div class="alert-item warning"><i class="icon icon-alert-triangle"></i> <%= Esc.h(b.getComponent()) %> (<%= Esc.h(b.getBloodGroup()) %>) expires in <%= b.getDaysUntilExpiry() %> day(s)</div>
            <% }}} %>
        </div>

        <!-- Today's OT -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-calendar"></i> Today's OT Schedule</h3>
                <span class="count-badge"><%= todayOtSchedules != null ? todayOtSchedules.size() : 0 %> scheduled</span>
            </div>
            <% if (todayOtSchedules == null || todayOtSchedules.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-calendar"></i><p>No OT procedures today.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Patient</th><th>Doctor</th><th>OT</th><th>Time</th><th>Status</th></tr>
                    <% for (OtSchedule os : todayOtSchedules) { %>
                    <tr>
                        <td><%= Esc.h(patientNameMap != null ? patientNameMap.getOrDefault(os.getPatientId(), "Unknown") : "Unknown") %></td>
                        <td>Dr. <%= Esc.h(doctorNameMap != null ? doctorNameMap.getOrDefault(os.getDoctorId(), "Unknown") : "Unknown") %></td>
                        <td>OT-<%= os.getOtId() %></td>
                        <td><%= os.getStartTime() %>&ndash;<%= os.getEndTime() %></td>
                        <td><span class="badge orange"><%= os.getStatus() %></span></td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

        <!-- Active Admissions -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-bed"></i> Active Admissions</h3>
                <span class="count-badge"><%= activeBedAdmissions != null ? activeBedAdmissions.size() : 0 %> admitted</span>
            </div>
            <% if (activeBedAdmissions == null || activeBedAdmissions.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-bed"></i><p>No active admissions.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Patient</th><th>Doctor</th><th>Bed</th><th>Discharge</th></tr>
                    <% for (BedAdmission ba : activeBedAdmissions) { %>
                    <tr>
                        <td><%= Esc.h(patientNameMap != null ? patientNameMap.getOrDefault(ba.getPatientId(), "Unknown") : "Unknown") %></td>
                        <td>Dr. <%= Esc.h(doctorNameMap != null ? doctorNameMap.getOrDefault(ba.getDoctorId(), "Unknown") : "Unknown") %></td>
                        <td>Bed #<%= ba.getBedId() %></td>
                        <td><%= ba.getDischargeDate() %></td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

        <!-- Recent Doctors -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-user"></i> Recent Doctors</h3>
                <span class="count-badge"><%= totalDoctors %> total</span>
            </div>
            <% if (recentDoctors == null || recentDoctors.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-user"></i><p>No doctors yet.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Name</th><th>Department</th><th>Experience</th></tr>
                    <% for (Doctor d : recentDoctors) { %>
                    <tr>
                        <td><strong>Dr. <%= Esc.h(d.getName()) %></strong></td>
                        <td><span class="badge blue"><%= Esc.h(d.getDepartment()) %></span></td>
                        <td><%= d.getYearsOfExperience() %> yrs</td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

        <!-- Recent Patients -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-users"></i> Recent Patients</h3>
                <span class="count-badge"><%= totalPatients %> total</span>
            </div>
            <% if (recentPatients == null || recentPatients.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-users"></i><p>No patients yet.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Name</th><th>Blood Group</th><th>Age</th></tr>
                    <% for (Patient p : recentPatients) { %>
                    <tr>
                        <td><strong><%= Esc.h(p.getName()) %></strong></td>
                        <td><span class="badge red"><%= Esc.h(p.getBloodGroup()) %></span></td>
                        <td><%= p.getAge() %> yrs</td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

    </div>
</div>
</body>
</html>
