<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.hospital.model.*" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Patient - Visit Summary</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="patient">

<%
    String activePage = "summary";

    Patient patient = (Patient) request.getAttribute("patient");
    Doctor assignedDoctor = (Doctor) request.getAttribute("assignedDoctor");
    List<BedAdmission> bedAdmissions = (List<BedAdmission>) request.getAttribute("bedAdmissions");
    List<IcuAdmission> icuAdmissions = (List<IcuAdmission>) request.getAttribute("icuAdmissions");
    List<OtSchedule> otSchedules = (List<OtSchedule>) request.getAttribute("otSchedules");
    List<PatientNote> notes = (List<PatientNote>) request.getAttribute("notes");
    Map<Long, String> doctorNameMap = (Map<Long, String>) request.getAttribute("doctorNameMap");
    Map<Integer, Bed> bedMap = (Map<Integer, Bed>) request.getAttribute("bedMap");
    Map<Integer, Icu> icuMap = (Map<Integer, Icu>) request.getAttribute("icuMap");

    java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy");
    java.time.format.DateTimeFormatter tsFmt = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm");
%>

<%@ include file="/WEB-INF/views/fragments/patient-navbar.jspf" %>

<div class="page-main">
    <div class="page-header no-print" style="display:flex; justify-content:space-between; align-items:center;">
        <div>
            <h1><i class="icon icon-file-text"></i> Visit Summary</h1>
            <p>A printable record of your visits, admissions, and treatment.</p>
        </div>
        <button onclick="window.print()" class="btn btn-primary"><i class="icon icon-file-text"></i> Print / Save as PDF</button>
    </div>

    <div class="summary-doc card" style="padding:32px;">
        <div class="summary-header">
            <div>
                <div style="font-size:20px; font-weight:700;">Hospital System</div>
                <div style="font-size:12px; color:var(--text-mute);">Patient Visit Summary</div>
            </div>
            <div style="text-align:right; font-size:12px; color:var(--text-mute);">
                Generated <%= java.time.LocalDate.now().format(fmt) %>
            </div>
        </div>

        <div class="summary-section">
            <h3>Patient Information</h3>
            <div class="summary-grid">
                <div><span class="label">Name:</span> <%= Esc.h(patient.getName()) %></div>
                <div><span class="label">Age / Gender:</span> <%= patient.getAge() %> / <%= Esc.h(patient.getGender()) %></div>
                <div><span class="label">Blood Group:</span> <%= Esc.h(patient.getBloodGroup()) %></div>
                <div><span class="label">Phone:</span> <%= Esc.h(patient.getPhone()) %></div>
                <div><span class="label">Address:</span> <%= Esc.h(patient.getAddress()) %></div>
                <div><span class="label">Emergency Contact:</span> <%= Esc.h(patient.getEmergencyContact()) %></div>
            </div>
        </div>

        <div class="summary-section">
            <h3>Attending Doctor</h3>
            <% if (assignedDoctor != null) { %>
                <div class="summary-grid">
                    <div><span class="label">Doctor:</span> Dr. <%= Esc.h(assignedDoctor.getName()) %></div>
                    <div><span class="label">Department:</span> <%= Esc.h(assignedDoctor.getDepartment()) %></div>
                </div>
            <% } else { %>
                <p style="font-size:13px; color:var(--text-mute);">No doctor currently assigned.</p>
            <% } %>
        </div>

        <% if (patient.getMedicalHistory() != null && !patient.getMedicalHistory().isEmpty()) { %>
        <div class="summary-section">
            <h3>Medical History</h3>
            <p style="font-size:13px; line-height:1.6;"><%= Esc.h(patient.getMedicalHistory()) %></p>
        </div>
        <% } %>

        <% if (bedAdmissions != null && !bedAdmissions.isEmpty()) { %>
        <div class="summary-section">
            <h3>Bed Admissions</h3>
            <table>
                <tr><th>Bed</th><th>Doctor</th><th>Admitted</th><th>Discharge</th><th>Status</th></tr>
                <% for (BedAdmission b : bedAdmissions) {
                    Bed bed = bedMap != null ? bedMap.get(b.getBedId()) : null;
                %>
                <tr>
                    <td><%= bed != null ? Esc.h(bed.getBedNumber()) : "Bed #" + b.getBedId() %></td>
                    <td>Dr. <%= Esc.h(doctorNameMap != null ? doctorNameMap.getOrDefault(b.getDoctorId(), "Unknown") : "Unknown") %></td>
                    <td><%= b.getAdmittedDate().format(fmt) %></td>
                    <td><%= b.getDischargeDate().format(fmt) %></td>
                    <td><%= Esc.h(b.getStatus()) %></td>
                </tr>
                <% } %>
            </table>
        </div>
        <% } %>

        <% if (icuAdmissions != null && !icuAdmissions.isEmpty()) { %>
        <div class="summary-section">
            <h3>ICU Admissions</h3>
            <table>
                <tr><th>ICU</th><th>Doctor</th><th>Admitted</th><th>Discharge</th><th>Status</th></tr>
                <% for (IcuAdmission i : icuAdmissions) { %>
                <tr>
                    <td>ICU #<%= i.getIcuId() %></td>
                    <td>Dr. <%= Esc.h(doctorNameMap != null ? doctorNameMap.getOrDefault(i.getDoctorId(), "Unknown") : "Unknown") %></td>
                    <td><%= i.getAdmittedDate().format(fmt) %></td>
                    <td><%= i.getDischargeDate().format(fmt) %></td>
                    <td><%= Esc.h(i.getStatus()) %></td>
                </tr>
                <% } %>
            </table>
        </div>
        <% } %>

        <% if (otSchedules != null && !otSchedules.isEmpty()) { %>
        <div class="summary-section">
            <h3>Procedures</h3>
            <table>
                <tr><th>Procedure</th><th>Doctor</th><th>Date</th><th>Time</th><th>Status</th></tr>
                <% for (OtSchedule os : otSchedules) { %>
                <tr>
                    <td><%= Esc.h(os.getProcedureName()) %></td>
                    <td>Dr. <%= Esc.h(doctorNameMap != null ? doctorNameMap.getOrDefault(os.getDoctorId(), "Unknown") : "Unknown") %></td>
                    <td><%= os.getScheduleDate().format(fmt) %></td>
                    <td><%= os.getStartTime() %> &ndash; <%= os.getEndTime() %></td>
                    <td><%= Esc.h(os.getStatus()) %></td>
                </tr>
                <% } %>
            </table>
        </div>
        <% } %>

        <% if (notes != null && !notes.isEmpty()) { %>
        <div class="summary-section">
            <h3>Clinical Notes &amp; Prescriptions</h3>
            <% for (PatientNote n : notes) { %>
            <div style="margin-bottom:14px; padding-bottom:14px; border-bottom:1px solid var(--border);">
                <div style="font-size:12px; color:var(--text-mute); margin-bottom:4px;">
                    <%= n.getCreatedAt().format(tsFmt) %> &middot; Dr. <%= Esc.h(doctorNameMap != null ? doctorNameMap.getOrDefault(n.getDoctorId(), "Unknown") : "Unknown") %>
                </div>
                <div style="font-size:14px; font-weight:600;"><%= Esc.h(n.getDiagnosis()) %></div>
                <% if (n.getPrescription() != null && !n.getPrescription().isEmpty()) { %>
                <div style="font-size:13px;"><strong>Prescription:</strong> <%= Esc.h(n.getPrescription()) %></div>
                <% } %>
                <% if (n.getAdvice() != null && !n.getAdvice().isEmpty()) { %>
                <div style="font-size:13px;"><strong>Advice:</strong> <%= Esc.h(n.getAdvice()) %></div>
                <% } %>
            </div>
            <% } %>
        </div>
        <% } %>

        <% if ((bedAdmissions == null || bedAdmissions.isEmpty())
                && (icuAdmissions == null || icuAdmissions.isEmpty())
                && (otSchedules == null || otSchedules.isEmpty())
                && (notes == null || notes.isEmpty())) { %>
        <div class="empty-state"><i class="icon icon-file-text"></i><p>No visit history recorded yet.</p></div>
        <% } %>
    </div>
</div>

</body>
</html>
