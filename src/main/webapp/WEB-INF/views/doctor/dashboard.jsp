<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.hospital.model.*" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Doctor Dashboard</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="doctor">

<%
    String activePage = "dashboard";

    Doctor doctor = (Doctor) request.getAttribute("doctor");
    String name = Esc.h((doctor != null) ? doctor.getName() : "Doctor");
    String dept = Esc.h((doctor != null && doctor.getDepartment() != null) ? doctor.getDepartment() : "N/A");
    String spec = Esc.h((doctor != null && doctor.getSpecialization() != null) ? doctor.getSpecialization() : "N/A");
    String qual = Esc.h((doctor != null && doctor.getQualification() != null) ? doctor.getQualification() : "N/A");
    int exp = (doctor != null) ? doctor.getYearsOfExperience() : 0;
    String email = Esc.h((doctor != null) ? doctor.getEmail() : "N/A");
    String phone = Esc.h((doctor != null && doctor.getPhone() != null) ? doctor.getPhone() : "N/A");

    List<DoctorPatient> activeAssignments = (List<DoctorPatient>) request.getAttribute("activeAssignments");
    Map<Long, Patient> patientMap = (Map<Long, Patient>) request.getAttribute("patientMap");
    List<OtSchedule> todayOtSchedules = (List<OtSchedule>) request.getAttribute("todayOtSchedules");
    List<BedAdmission> bedAdmissions = (List<BedAdmission>) request.getAttribute("bedAdmissions");

    int totalPatients = (int) request.getAttribute("totalPatients");
    int todayAppointments = (int) request.getAttribute("todayAppointments");
    int activeBeds = (int) request.getAttribute("activeBeds");
%>

<%@ include file="/WEB-INF/views/fragments/doctor-navbar.jspf" %>

<!-- Main -->
<div class="page-main">
    <div class="page-header">
        <h1>Good Day, Dr. <%= name %></h1>
        <p>Here's your overview for today.</p>
    </div>

    <!-- Profile -->
    <div class="profile-card">
        <div class="avatar lg"><i class="icon icon-user"></i></div>
        <div class="profile-details">
            <h2>Dr. <%= name %></h2>
            <div class="profile-tags">
                <span class="tag"><%= spec %></span>
                <span class="tag"><%= dept %></span>
                <span class="tag"><%= qual %></span>
            </div>
            <div class="profile-meta">
                <div class="meta-item"><i class="icon icon-mail"></i> <strong><%= email %></strong></div>
                <div class="meta-item"><i class="icon icon-phone"></i> <strong><%= phone %></strong></div>
                <div class="meta-item"><i class="icon icon-award"></i> <strong><%= exp %> yrs experience</strong></div>
            </div>
        </div>
    </div>

    <!-- Stats -->
    <div class="stats-row cols-3">
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-users"></i></div>
            <div class="value"><%= totalPatients %></div>
            <div class="label">Assigned Patients</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-scissors"></i></div>
            <div class="value"><%= todayAppointments %></div>
            <div class="label">OT Procedures Today</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-bed"></i></div>
            <div class="value"><%= activeBeds %></div>
            <div class="label">Patients in Beds</div>
        </div>
    </div>

    <!-- Content Grid -->
    <div class="content-grid">

        <!-- My Patients -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-users"></i> My Patients</h3>
                <span class="count-badge"><%= totalPatients %> patients</span>
            </div>
            <% if (activeAssignments == null || activeAssignments.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-users"></i><p>No patients assigned yet.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Name</th><th>Age</th><th>Blood Group</th><th>Phone</th></tr>
                    <% for (DoctorPatient dp : activeAssignments) {
                        Patient p = patientMap != null ? patientMap.get(dp.getPatientId()) : null;
                        if (p != null) { %>
                    <tr>
                        <td><strong><%= Esc.h(p.getName()) %></strong></td>
                        <td><%= p.getAge() %> yrs</td>
                        <td><span class="badge red"><%= Esc.h(p.getBloodGroup()) %></span></td>
                        <td><%= Esc.h(p.getPhone()) %></td>
                    </tr>
                    <% }} %>
                </table>
            <% } %>
        </div>

        <!-- Today's OT -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-scissors"></i> Today's Procedures</h3>
                <span class="count-badge"><%= todayAppointments %> scheduled</span>
            </div>
            <% if (todayOtSchedules == null || todayOtSchedules.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-calendar"></i><p>No procedures today.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Procedure</th><th>OT</th><th>Time</th><th>Status</th></tr>
                    <% for (OtSchedule os : todayOtSchedules) { %>
                    <tr>
                        <td><%= Esc.h(os.getProcedureName()) %></td>
                        <td>OT-<%= os.getOtId() %></td>
                        <td><%= os.getStartTime() %>&ndash;<%= os.getEndTime() %></td>
                        <td><span class="badge orange"><%= os.getStatus() %></span></td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

        <!-- Patients in Beds -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-bed"></i> Patients in Beds</h3>
                <span class="count-badge"><%= activeBeds %> active</span>
            </div>
            <% if (bedAdmissions == null || bedAdmissions.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-bed"></i><p>No patients in beds.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Patient</th><th>Bed</th><th>Admitted</th><th>Discharge</th></tr>
                    <% for (BedAdmission ba : bedAdmissions) {
                        Patient p = patientMap != null ? patientMap.get(ba.getPatientId()) : null; %>
                    <tr>
                        <td><%= Esc.h(p != null ? p.getName() : "Unknown") %></td>
                        <td>Bed #<%= ba.getBedId() %></td>
                        <td><%= ba.getAdmittedDate() %></td>
                        <td><%= ba.getDischargeDate() %></td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

    </div>
</div>
</body>
</html>
