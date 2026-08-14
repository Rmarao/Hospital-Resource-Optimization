<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.hospital.model.*" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Patients</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<%
    String activePage = "patients";

    List<Patient> patients = (List<Patient>) request.getAttribute("patients");
    List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");
    List<DoctorPatient> assignments = (List<DoctorPatient>) request.getAttribute("assignments");
    Map<Long, PatientRecommendation> recommendationMap =
        (Map<Long, PatientRecommendation>) request.getAttribute("recommendationMap");
    long totalPatients = request.getAttribute("totalPatients") != null
        ? ((Number) request.getAttribute("totalPatients")).longValue() : 0L;
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));
    String errorMsg = request.getParameter("error");
    String q = (String) request.getAttribute("q");

    Map<Long, String> doctorNameMap = new HashMap<>();
    Map<Long, String> doctorDeptMap = new HashMap<>();
    Map<Long, Integer> doctorExpMap = new HashMap<>();
    if (doctors != null) {
        for (Doctor d : doctors) {
            doctorNameMap.put(d.getId(), d.getName());
            doctorDeptMap.put(d.getId(), d.getDepartment());
            doctorExpMap.put(d.getId(), d.getYearsOfExperience());
        }
    }

    Map<Long, Long> patientDoctorMap = new HashMap<>();
    if (assignments != null) {
        for (DoctorPatient dp : assignments) {
            if ("ACTIVE".equals(dp.getStatus())) {
                patientDoctorMap.put(dp.getPatientId(), dp.getDoctorId());
            }
        }
    }

    long analyzedCount = recommendationMap != null ? recommendationMap.size() : 0;
    long highRiskCount = recommendationMap != null ?
        recommendationMap.values().stream()
            .filter(r -> "HIGH".equals(r.getSeverityLevel())
                      || "CRITICAL".equals(r.getSeverityLevel()))
            .count() : 0;
%>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-users"></i> Patient Management</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <% if (successMsg != null) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> <%= successMsg %></div>
    <% } %>
    <% if ("noanalysis".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> Please analyse the patient first before auto-assigning.</div>
    <% } else if ("nodoctoravailable".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> No suitable doctor found. Please assign manually.</div>
    <% } else if ("alreadyassigned".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> This doctor is already assigned to this patient.</div>
    <% } else if ("patientnotfound".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> That patient no longer exists.</div>
    <% } %>

    <!-- Stats -->
    <div class="stats-row cols-3">
        <div class="stat-card"><div class="value"><%= totalPatients %></div><div class="label">Total Patients</div></div>
        <div class="stat-card"><div class="value"><%= analyzedCount %></div><div class="label">Analysed by AI</div></div>
        <div class="stat-card">
            <div class="value" style="color:<%= highRiskCount > 0 ? "var(--danger)" : "var(--success)" %>">
                <%= highRiskCount %>
            </div>
            <div class="label">High / Critical Risk</div>
        </div>
    </div>

    <!-- Search / Export -->
    <form action="/admin/patients" method="get" class="search-row" style="margin-bottom:16px;">
        <input type="text" name="q" placeholder="Search by name, email, phone, gender, blood group..." value="<%= Esc.h(q) %>" />
        <button type="submit" class="search-btn"><i class="icon icon-search"></i> Search</button>
        <% if (q != null && !q.isBlank()) { %>
            <a href="/admin/patients" class="btn btn-sm">Clear</a>
        <% } %>
        <a href="/admin/patients/export.csv<%= (q != null && !q.isBlank()) ? "?q=" + java.net.URLEncoder.encode(q, java.nio.charset.StandardCharsets.UTF_8) : "" %>" class="btn btn-sm"><i class="icon icon-file-text"></i> Export CSV</a>
    </form>

    <!-- Patient Cards -->
    <% if (patients == null || patients.isEmpty()) { %>
        <div class="empty-state"><i class="icon icon-users"></i><p><%= (q != null && !q.isBlank()) ? "No patients match your search." : "No patients registered yet." %></p></div>
    <% } else { %>
        <div class="patients-list">
        <% for (Patient patient : patients) {
            Long assignedDoctorId = patientDoctorMap.get(patient.getId());
            PatientRecommendation rec = recommendationMap != null
                ? recommendationMap.get(patient.getId()) : null;
        %>
        <div class="patient-card">

            <!-- Card Header -->
            <div class="patient-card-header">
                <div class="avatar"><i class="icon icon-user"></i></div>
                <div class="patient-info">
                    <div class="patient-name"><%= Esc.h(patient.getName()) %></div>
                    <div class="patient-meta">
                        <%= patient.getAge() %> yrs &middot;
                        <%= Esc.h(patient.getGender() != null ? patient.getGender() : "N/A") %> &middot;
                        Blood: <strong><%= Esc.h(patient.getBloodGroup() != null ? patient.getBloodGroup() : "N/A") %></strong> &middot;
                        <%= Esc.h(patient.getPhone()) %>
                    </div>
                </div>
                <% if (rec != null) { %>
                    <span class="severity-badge <%= Esc.h(rec.getSeverityLevel()) %>">
                        <%= Esc.h(rec.getSeverityLevel()) %> (<%= rec.getSeverityScore() %>/10)
                    </span>
                    <span class="urgency-tag <%= Esc.h(rec.getUrgency()) %>">
                        <%= Esc.h(rec.getUrgency()) %>
                    </span>
                <% } %>
            </div>

            <!-- Card Body -->
            <div class="patient-card-body">

                <!-- LLM Analysis -->
                <div class="analysis-box">
                    <h4><i class="icon icon-sparkles"></i> AI Analysis</h4>
                    <% if (rec != null) { %>
                        <div class="analysis-detail">
                            <strong>Department:</strong>
                            <%= Esc.h(rec.getDepartment().replace("_", " ")) %>
                        </div>
                        <div class="analysis-detail">
                            <strong>Specialization:</strong>
                            <%= Esc.h(rec.getDoctorSpecialization()) %>
                        </div>
                        <div class="analysis-detail">
                            <strong>Resources Needed:</strong>
                        </div>
                        <div class="resource-chips">
                            <% if (rec.getRecommendedResources() != null) {
                                for (String r : rec.getRecommendedResources().split(",")) { %>
                                <span class="resource-chip"><%= Esc.h(r.trim()) %></span>
                            <% }} %>
                        </div>
                        <div class="reasoning-text">
                            <%= Esc.h(rec.getReasoning()) %>
                        </div>
                    <% } else { %>
                        <div class="no-data"><i class="icon icon-search"></i><p>Not analysed yet</p></div>
                    <% } %>
                </div>

                <!-- Doctor Assignment -->
                <div class="assign-box">
                    <h4><i class="icon icon-user"></i> Doctor Assignment</h4>
                    <% if (assignedDoctorId != null) { %>
                        <div class="assigned-doctor">
                            <span class="avatar"><i class="icon icon-user"></i></span>
                            <div>
                                <div class="doc-name">
                                    Dr. <%= Esc.h(doctorNameMap.getOrDefault(assignedDoctorId, "Unknown")) %>
                                </div>
                                <div class="doc-dept">
                                    <%= Esc.h(doctorDeptMap.getOrDefault(assignedDoctorId, "N/A")) %> &middot;
                                    <%= doctorExpMap.getOrDefault(assignedDoctorId, 0) %> yrs exp
                                </div>
                            </div>
                        </div>
                        <form action="/admin/patients/remove-doctor" method="post">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            <input type="hidden" name="patientId" value="<%= patient.getId() %>" />
                            <button type="submit" class="btn btn-danger btn-sm"
                                    onclick="return confirm('Remove doctor assignment?')">
                                Remove Doctor
                            </button>
                        </form>
                    <% } else { %>
                        <p style="font-size:12px; color:var(--text-mute); margin-bottom:10px;">
                            No doctor assigned yet.
                        </p>
                    <% } %>

                    <form action="/admin/patients/assign-doctor" method="post" style="margin-top:10px;">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        <input type="hidden" name="patientId" value="<%= patient.getId() %>" />
                        <select name="doctorId" required style="margin-bottom:8px;">
                            <option value="" disabled selected>Manual: Select Doctor</option>
                            <% if (doctors != null) for (Doctor doc : doctors) { %>
                                <option value="<%= doc.getId() %>">
                                    Dr. <%= Esc.h(doc.getName()) %> &mdash;
                                    <%= Esc.h(doc.getDepartment()) %>
                                    (<%= doc.getYearsOfExperience() %> yrs)
                                </option>
                            <% } %>
                        </select>
                        <button type="submit" class="btn btn-primary btn-sm btn-block">
                            Assign Manually
                        </button>
                    </form>
                </div>

                <!-- Actions -->
                <div class="action-box">
                    <h4><i class="icon icon-zap"></i> Actions</h4>

                    <form action="/admin/patients/analyse" method="post">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        <input type="hidden" name="patientId" value="<%= patient.getId() %>" />
                        <button type="submit" class="btn btn-ai btn-block">
                            <i class="icon icon-search"></i> <%= rec != null ? "Re-Analyse" : "Analyse" %> with AI
                        </button>
                    </form>

                    <% if (rec != null) { %>
                    <form action="/admin/patients/auto-assign-doctor" method="post">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        <input type="hidden" name="patientId" value="<%= patient.getId() %>" />
                        <button type="submit" class="btn btn-info btn-block">
                            <i class="icon icon-sparkles"></i> Auto Assign Best Doctor
                        </button>
                    </form>
                    <% } %>

                    <% if (patient.getMedicalHistory() != null
                            && !patient.getMedicalHistory().isEmpty()) { %>
                        <div class="medical-history-preview">
                            <strong>Medical History:</strong><br/>
                            <%= Esc.h(patient.getMedicalHistory().length() > 100
                                ? patient.getMedicalHistory().substring(0, 100) + "..."
                                : patient.getMedicalHistory()) %>
                        </div>
                    <% } %>
                </div>

            </div>
        </div>
        <% } %>
        </div>
    <% } %>
</div>

</body>
</html>
