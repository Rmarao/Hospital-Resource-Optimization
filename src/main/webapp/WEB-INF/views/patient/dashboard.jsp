<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.hospital.model.*" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Patient Dashboard</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="patient">

<%
    String activePage = "dashboard";

    Patient patient = (Patient) request.getAttribute("patient");
    String name = Esc.h((patient != null) ? patient.getName() : "Patient");
    String email = Esc.h((patient != null) ? patient.getEmail() : "N/A");
    String phone = Esc.h((patient != null && patient.getPhone() != null) ? patient.getPhone() : "N/A");
    String gender = Esc.h((patient != null && patient.getGender() != null) ? patient.getGender() : "N/A");
    String bloodGroup = Esc.h((patient != null && patient.getBloodGroup() != null) ? patient.getBloodGroup() : "N/A");
    String address = Esc.h((patient != null && patient.getAddress() != null) ? patient.getAddress() : "N/A");
    String emergencyContact = Esc.h((patient != null && patient.getEmergencyContact() != null) ? patient.getEmergencyContact() : "N/A");
    String medicalHistory = (patient != null && patient.getMedicalHistory() != null) ? Esc.h(patient.getMedicalHistory()) : "None recorded";
    int age = (patient != null) ? patient.getAge() : 0;

    Doctor assignedDoctor = (Doctor) request.getAttribute("assignedDoctor");
    BedAdmission bedAdmission = (BedAdmission) request.getAttribute("bedAdmission");
    Bed assignedBed = (Bed) request.getAttribute("assignedBed");
    IcuAdmission icuAdmission = (IcuAdmission) request.getAttribute("icuAdmission");
    Icu assignedIcu = (Icu) request.getAttribute("assignedIcu");
    List<OtSchedule> upcomingOtSchedules = (List<OtSchedule>) request.getAttribute("upcomingOtSchedules");
    OtSchedule nextOt = (upcomingOtSchedules != null && !upcomingOtSchedules.isEmpty()) ? upcomingOtSchedules.get(0) : null;

    List<PatientNote> notes = (List<PatientNote>) request.getAttribute("notes");
    Map<Long, String> noteDoctorNameMap = (Map<Long, String>) request.getAttribute("noteDoctorNameMap");
    java.time.format.DateTimeFormatter noteFmt = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy");

    // Upcoming-care reminders, derived from existing OT / note / bed data — no extra queries.
    java.time.LocalDate today = java.time.LocalDate.now();
    java.time.LocalDate nextFollowUp = null;
    if (notes != null) {
        for (PatientNote n : notes) {
            if (n.getFollowUpDate() != null && !n.getFollowUpDate().isBefore(today)) {
                if (nextFollowUp == null || n.getFollowUpDate().isBefore(nextFollowUp)) {
                    nextFollowUp = n.getFollowUpDate();
                }
            }
        }
    }
    boolean showDischargeReminder = bedAdmission != null
        && bedAdmission.getDischargeDate() != null
        && !bedAdmission.getDischargeDate().isBefore(today);
    boolean hasReminders = nextOt != null || nextFollowUp != null || showDischargeReminder;
%>

<%@ include file="/WEB-INF/views/fragments/patient-navbar.jspf" %>

<!-- Main -->
<div class="page-main">
    <div class="page-header">
        <h1>Welcome, <%= name %></h1>
        <p>Here's your health overview and hospital status.</p>
    </div>

    <!-- Upcoming Care Reminders -->
    <% if (hasReminders) { %>
    <div class="card" style="margin-bottom:var(--space-7); border-left:4px solid var(--accent);">
        <div class="card-header"><h3><i class="icon icon-alert-triangle"></i> Upcoming Care Reminders</h3></div>
        <div style="padding:0 20px 16px;">
            <% if (nextOt != null) { %>
                <div class="alert-item info"><i class="icon icon-scissors"></i>
                    Procedure &ldquo;<%= Esc.h(nextOt.getProcedureName()) %>&rdquo; on <%= nextOt.getScheduleDate().format(noteFmt) %> at <%= nextOt.getStartTime() %>
                </div>
            <% } %>
            <% if (nextFollowUp != null) { %>
                <div class="alert-item info"><i class="icon icon-calendar"></i>
                    Follow-up appointment due on <%= nextFollowUp.format(noteFmt) %>
                </div>
            <% } %>
            <% if (showDischargeReminder) { %>
                <div class="alert-item info"><i class="icon icon-bed"></i>
                    Expected discharge on <%= bedAdmission.getDischargeDate().format(noteFmt) %>
                </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <!-- Profile -->
    <div class="profile-card">
        <div class="avatar lg"><i class="icon icon-user"></i></div>
        <div class="profile-details">
            <h2><%= name %></h2>
            <div class="profile-tags">
                <span class="tag"><%= gender %></span>
                <span class="tag">Age: <%= age %></span>
                <span class="tag">Blood: <%= bloodGroup %></span>
                <% if (assignedDoctor != null) { %>
                    <span class="tag">Dr. <%= Esc.h(assignedDoctor.getName()) %></span>
                <% } %>
            </div>
            <div class="profile-meta">
                <div class="meta-item"><i class="icon icon-mail"></i> <strong><%= email %></strong></div>
                <div class="meta-item"><i class="icon icon-phone"></i> <strong><%= phone %></strong></div>
                <div class="meta-item"><i class="icon icon-alert-circle"></i> Emergency: <strong><%= emergencyContact %></strong></div>
            </div>
        </div>
    </div>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-user"></i></div>
            <div class="value"><%= assignedDoctor != null ? "Dr. " + Esc.h(assignedDoctor.getName()) : "Not Assigned" %></div>
            <div class="label">Assigned Doctor</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-bed"></i></div>
            <div class="value"><%= assignedBed != null ? assignedBed.getBedNumber() : "Not Assigned" %></div>
            <div class="label">Assigned Bed</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-activity"></i></div>
            <div class="value"><%= assignedIcu != null ? "ICU #" + assignedIcu.getId() : "Not Required" %></div>
            <div class="label">ICU Status</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-scissors"></i></div>
            <div class="value"><%= nextOt != null ? nextOt.getScheduleDate().toString() : "None" %></div>
            <div class="label">Next Procedure</div>
        </div>
    </div>

    <!-- Content Grid -->
    <div class="content-grid">

        <!-- Personal Details -->
        <div class="card">
            <div class="card-header"><h3><i class="icon icon-user"></i> Personal Details</h3></div>
            <div class="info-row"><span class="info-label">Full Name</span><span class="info-value"><%= name %></span></div>
            <div class="info-row"><span class="info-label">Age</span><span class="info-value"><%= age %> years</span></div>
            <div class="info-row"><span class="info-label">Gender</span><span class="info-value"><%= gender %></span></div>
            <div class="info-row"><span class="info-label">Blood Group</span><span class="info-value"><%= bloodGroup %></span></div>
            <div class="info-row"><span class="info-label">Phone</span><span class="info-value"><%= phone %></span></div>
            <div class="info-row"><span class="info-label">Address</span><span class="info-value"><%= address %></span></div>
            <div class="info-row"><span class="info-label">Emergency Contact</span><span class="info-value"><%= emergencyContact %></span></div>
        </div>

        <!-- Allocated Resources -->
        <div class="card">
            <div class="card-header"><h3><i class="icon icon-bed"></i> Allocated Resources</h3></div>
            <div class="info-row">
                <span class="info-label">Assigned Doctor</span>
                <% if (assignedDoctor != null) { %><span class="badge green">Dr. <%= Esc.h(assignedDoctor.getName()) %></span>
                <% } else { %><span class="badge grey">Not Assigned</span><% } %>
            </div>
            <div class="info-row">
                <span class="info-label">Department</span>
                <span class="info-value"><%= Esc.h(assignedDoctor != null ? assignedDoctor.getDepartment() : "N/A") %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Bed</span>
                <% if (assignedBed != null) { %><span class="badge green"><%= assignedBed.getBedNumber() %> &mdash; <%= assignedBed.getWard() %></span>
                <% } else { %><span class="badge grey">Not Assigned</span><% } %>
            </div>
            <div class="info-row">
                <span class="info-label">ICU</span>
                <% if (assignedIcu != null) { %><span class="badge red">ICU #<%= assignedIcu.getId() %></span>
                <% } else { %><span class="badge grey">Not Required</span><% } %>
            </div>
            <div class="info-row">
                <span class="info-label">Admitted Date</span>
                <span class="info-value"><%= bedAdmission != null ? bedAdmission.getAdmittedDate() : "N/A" %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Expected Discharge</span>
                <span class="info-value"><%= bedAdmission != null ? bedAdmission.getDischargeDate() : "N/A" %></span>
            </div>
        </div>

        <!-- Medical History -->
        <div class="card">
            <div class="card-header"><h3><i class="icon icon-file-text"></i> Medical History</h3></div>
            <% if ("None recorded".equals(medicalHistory)) { %>
                <div class="empty-state"><i class="icon icon-file-text"></i><p>No medical history recorded.</p></div>
            <% } else { %>
                <p style="font-size:14px; color:var(--text-soft); line-height:1.7;"><%= medicalHistory %></p>
                <!-- medicalHistory is pre-escaped at assignment above -->
            <% } %>
        </div>

        <!-- Prescriptions & Notes -->
        <div class="card">
            <div class="card-header">
                <h3><i class="icon icon-clipboard"></i> Prescriptions &amp; Notes</h3>
                <span class="count-badge"><%= notes != null ? notes.size() : 0 %> total</span>
            </div>
            <% if (notes == null || notes.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-clipboard"></i><p>No clinical notes yet.</p></div>
            <% } else { %>
                <% for (PatientNote n : notes) { %>
                <div class="note-item">
                    <div class="note-date">
                        <i class="icon icon-calendar"></i> <%= n.getCreatedAt().format(noteFmt) %>
                        &middot; Dr. <%= Esc.h(noteDoctorNameMap != null ? noteDoctorNameMap.getOrDefault(n.getDoctorId(), "Unknown") : "Unknown") %>
                    </div>
                    <div class="note-diagnosis"><%= Esc.h(n.getDiagnosis()) %></div>
                    <% if (n.getPrescription() != null && !n.getPrescription().isEmpty()) { %>
                    <div class="note-field"><strong>Prescription</strong><%= Esc.h(n.getPrescription()) %></div>
                    <% } %>
                    <% if (n.getAdvice() != null && !n.getAdvice().isEmpty()) { %>
                    <div class="note-field"><strong>Advice</strong><%= Esc.h(n.getAdvice()) %></div>
                    <% } %>
                    <% if (n.getFollowUpDate() != null) { %>
                    <div class="note-field"><strong>Follow-up</strong><%= n.getFollowUpDate() %></div>
                    <% } %>
                </div>
                <% } %>
            <% } %>
        </div>

        <!-- Upcoming Procedures -->
        <div class="card">
            <div class="card-header"><h3><i class="icon icon-scissors"></i> Upcoming Procedures</h3></div>
            <% if (upcomingOtSchedules == null || upcomingOtSchedules.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-calendar"></i><p>No upcoming procedures.</p></div>
            <% } else { %>
                <% for (OtSchedule os : upcomingOtSchedules) { %>
                <div class="info-row">
                    <div>
                        <div style="font-weight:600; font-size:14px"><%= Esc.h(os.getProcedureName()) %></div>
                        <div style="font-size:12px; color:var(--text-mute)">OT-<%= os.getOtId() %> &middot; <%= os.getScheduleDate() %> &middot; <%= os.getStartTime() %>&ndash;<%= os.getEndTime() %></div>
                    </div>
                    <span class="badge orange">Scheduled</span>
                </div>
                <% } %>
            <% } %>
        </div>

        <!-- Treatment Journey -->
        <div class="card span-all">
            <div class="card-header"><h3><i class="icon icon-activity"></i> Treatment Journey</h3></div>
            <% if (bedAdmission == null && icuAdmission == null && (upcomingOtSchedules == null || upcomingOtSchedules.isEmpty())) { %>
                <div class="empty-state"><i class="icon icon-map-pin"></i><p>Your treatment journey will appear here once admitted.</p></div>
            <% } else { %>
                <div class="timeline">
                    <% if (bedAdmission != null) { %>
                        <div class="timeline-item">
                            <div class="time"><%= bedAdmission.getAdmittedDate() %></div>
                            <div class="event"><i class="icon icon-check-circle"></i> Admitted to Hospital</div>
                            <div class="desc"><%= assignedBed != null ? "Bed " + assignedBed.getBedNumber() + " — " + assignedBed.getWard() : "Bed assigned" %><% if (assignedDoctor != null) { %> &middot; Dr. <%= Esc.h(assignedDoctor.getName()) %><% } %></div>
                        </div>
                    <% } %>
                    <% if (icuAdmission != null) { %>
                        <div class="timeline-item">
                            <div class="time"><%= icuAdmission.getAdmittedDate() %></div>
                            <div class="event"><i class="icon icon-activity"></i> Admitted to ICU</div>
                            <div class="desc">ICU #<%= icuAdmission.getIcuId() %></div>
                        </div>
                    <% } %>
                    <% if (upcomingOtSchedules != null) { for (OtSchedule os : upcomingOtSchedules) { %>
                        <div class="timeline-item">
                            <div class="time"><%= os.getScheduleDate() %> &middot; <%= os.getStartTime() %></div>
                            <div class="event"><i class="icon icon-scissors"></i> <%= Esc.h(os.getProcedureName()) %></div>
                            <div class="desc">OT-<%= os.getOtId() %> &middot; Scheduled</div>
                        </div>
                    <% }} %>
                    <% if (bedAdmission != null) { %>
                        <div class="timeline-item">
                            <div class="time"><%= bedAdmission.getDischargeDate() %></div>
                            <div class="event"><i class="icon icon-calendar"></i> Expected Discharge</div>
                            <div class="desc">Planned discharge date</div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

    </div>
</div>
</body>
</html>
