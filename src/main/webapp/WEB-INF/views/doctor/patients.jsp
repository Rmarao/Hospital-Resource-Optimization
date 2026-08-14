<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.hospital.model.*" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Doctor - My Patients</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="doctor">

<%
    String activePage = "patients";

    List<Patient> patients = (List<Patient>) request.getAttribute("patients");
    Map<Long, BedAdmission> patientBedMap = (Map<Long, BedAdmission>) request.getAttribute("patientBedMap");
    Map<Long, IcuAdmission> patientIcuMap = (Map<Long, IcuAdmission>) request.getAttribute("patientIcuMap");
    Map<Long, List<OtSchedule>> patientOtMap = (Map<Long, List<OtSchedule>>) request.getAttribute("patientOtMap");
    Map<Integer, Bed> bedMap = (Map<Integer, Bed>) request.getAttribute("bedMap");
    Map<Integer, Icu> icuMap = (Map<Integer, Icu>) request.getAttribute("icuMap");
    Map<Long, List<PatientNote>> patientNotesMap = (Map<Long, List<PatientNote>>) request.getAttribute("patientNotesMap");
    List<Ot> availableOts = (List<Ot>) request.getAttribute("availableOts");
    int totalPatients = (int) request.getAttribute("totalPatients");

    int inBed = patientBedMap != null ? patientBedMap.size() : 0;
    int inIcu = patientIcuMap != null ? patientIcuMap.size() : 0;

    String errorMsg = request.getParameter("error");
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));

    java.time.format.DateTimeFormatter noteFmt = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>

<%@ include file="/WEB-INF/views/fragments/doctor-navbar.jspf" %>

<!-- Main -->
<div class="page-main">

    <div class="page-header">
        <h1><i class="icon icon-users"></i> My Patients</h1>
        <p>View and monitor all your assigned patients and their current status.</p>
    </div>

    <% if (successMsg != null) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> <%= successMsg %></div>
    <% } %>
    <% if ("notassigned".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> This patient is not assigned to you.</div>
    <% } else if ("notauthorized".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> You can only discharge patients under your own care.</div>
    <% } else if ("notfound".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> That admission record no longer exists.</div>
    <% } else if ("invalidtime".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> End time must be after start time.</div>
    <% } else if ("pastdate".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> Cannot schedule an OT procedure in the past.</div>
    <% } else if ("otconflict".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> That OT is already booked for an overlapping time.</div>
    <% } else if ("doctorconflict".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> You already have another procedure scheduled at that time.</div>
    <% } else if ("otnotfound".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> That operation theatre no longer exists.</div>
    <% } %>

    <!-- Stats -->
    <div class="stats-row cols-3">
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-users"></i></div>
            <div class="value"><%= totalPatients %></div>
            <div class="label">Total Assigned Patients</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-bed"></i></div>
            <div class="value"><%= inBed %></div>
            <div class="label">Currently in Beds</div>
        </div>
        <div class="stat-card">
            <div class="icon-wrap"><i class="icon icon-activity"></i></div>
            <div class="value"><%= inIcu %></div>
            <div class="label">Currently in ICU</div>
        </div>
    </div>

    <!-- Patient Cards -->
    <% if (patients == null || patients.isEmpty()) { %>
        <div class="empty-state">
            <i class="icon icon-users"></i>
            <h2>No patients assigned yet</h2>
            <p>Patients will appear here once the admin assigns them to you.</p>
        </div>
    <% } else { %>
        <div class="grid-auto">
            <% for (Patient p : patients) {
                BedAdmission bed = patientBedMap != null ? patientBedMap.get(p.getId()) : null;
                IcuAdmission icu = patientIcuMap != null ? patientIcuMap.get(p.getId()) : null;
                List<OtSchedule> ots = patientOtMap != null ? patientOtMap.get(p.getId()) : null;
                Bed bedDetails = (bed != null && bedMap != null) ? bedMap.get(bed.getBedId()) : null;
                Icu icuDetails = (icu != null && icuMap != null) ? icuMap.get(icu.getIcuId()) : null;
            %>
            <div class="patient-card">

                <!-- Card Header -->
                <div class="patient-card-header">
                    <div class="avatar"><i class="icon icon-user"></i></div>
                    <div class="patient-info">
                        <div class="patient-name"><%= Esc.h(p.getName()) %></div>
                        <div class="patient-meta">
                            <%= p.getAge() %> yrs &middot; <%= Esc.h(p.getGender()) %> &middot;
                            <strong><%= Esc.h(p.getBloodGroup()) %></strong> &middot;
                            <%= Esc.h(p.getPhone()) %>
                        </div>
                    </div>
                    <% if (icu != null) { %>
                        <span class="badge red">ICU</span>
                    <% } else if (bed != null) { %>
                        <span class="badge orange">Admitted</span>
                    <% } else { %>
                        <span class="badge grey">Outpatient</span>
                    <% } %>
                </div>

                <div class="patient-card-body" style="display:block;">

                    <!-- Personal Info -->
                    <div class="info-grid">
                        <div class="info-item">
                            <span class="info-label">Email</span>
                            <span class="info-value"><%= Esc.h(p.getEmail()) %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Emergency Contact</span>
                            <span class="info-value"><%= Esc.h(p.getEmergencyContact() != null ? p.getEmergencyContact() : "N/A") %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Address</span>
                            <span class="info-value"><%= Esc.h(p.getAddress() != null ? p.getAddress() : "N/A") %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Date of Birth</span>
                            <span class="info-value"><%= p.getDateOfBirth() != null ? p.getDateOfBirth().toString() : "N/A" %></span>
                        </div>
                    </div>

                    <% if (p.getMedicalHistory() != null && !p.getMedicalHistory().isEmpty()) { %>
                        <div class="section-divider"></div>
                        <div class="section-title"><i class="icon icon-file-text"></i> Medical History</div>
                        <div class="medical-history-preview"><%= Esc.h(p.getMedicalHistory()) %></div>
                    <% } %>

                    <div class="section-divider"></div>

                    <div class="section-title"><i class="icon icon-bed"></i> Current Allocation</div>

                    <div class="resource-row">
                        <span class="resource-label"><i class="icon icon-bed"></i> Bed</span>
                        <% if (bedDetails != null) { %>
                            <span class="resource-value"><%= bedDetails.getBedNumber() %> &mdash; <%= bedDetails.getWard() %>, Floor <%= bedDetails.getFloor() %></span>
                            <form action="/doctor/patients/discharge-bed" method="post" class="inline-form"
                                  onsubmit="return confirm('Discharge this patient from their bed?')">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="admissionId" value="<%= bed.getId() %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Discharge</button>
                            </form>
                        <% } else { %>
                            <span class="badge grey">Not Assigned</span>
                        <% } %>
                    </div>

                    <div class="resource-row">
                        <span class="resource-label"><i class="icon icon-activity"></i> ICU</span>
                        <% if (icuDetails != null) { %>
                            <span class="resource-value">ICU #<%= icuDetails.getId() %> <%= icuDetails.getVentilator() ? "&middot; Ventilator" : "" %></span>
                            <form action="/doctor/patients/discharge-icu" method="post" class="inline-form"
                                  onsubmit="return confirm('Discharge this patient from ICU?')">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="admissionId" value="<%= icu.getId() %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Discharge</button>
                            </form>
                        <% } else { %>
                            <span class="badge grey">Not in ICU</span>
                        <% } %>
                    </div>

                    <% if (bed != null) { %>
                    <div class="resource-row">
                        <span class="resource-label"><i class="icon icon-calendar"></i> Admitted</span>
                        <span class="resource-value"><%= bed.getAdmittedDate() %></span>
                    </div>
                    <div class="resource-row">
                        <span class="resource-label"><i class="icon icon-calendar"></i> Expected Discharge</span>
                        <span class="resource-value"><%= bed.getDischargeDate() %></span>
                    </div>
                    <% } %>

                    <% if (ots != null && !ots.isEmpty()) { %>
                        <div class="section-divider"></div>
                        <div class="section-title"><i class="icon icon-scissors"></i> Upcoming Procedures</div>
                        <% for (OtSchedule os : ots) { %>
                        <div class="ot-item">
                            <div class="ot-procedure"><%= Esc.h(os.getProcedureName()) %></div>
                            <div class="ot-details">OT-<%= os.getOtId() %> &middot; <%= os.getScheduleDate() %> &middot; <%= os.getStartTime() %> &ndash; <%= os.getEndTime() %></div>
                        </div>
                        <% } %>
                    <% } %>

                    <div class="section-divider"></div>
                    <details class="note-form-toggle">
                        <summary class="btn btn-info btn-sm" style="display:inline-flex; cursor:pointer;">
                            <i class="icon icon-scissors"></i> Book OT Procedure
                        </summary>
                        <form action="/doctor/patients/book-ot" method="post" style="margin-top:12px;">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            <input type="hidden" name="patientId" value="<%= p.getId() %>" />
                            <div class="form-group" style="margin-bottom:10px;">
                                <label>Operation Theatre</label>
                                <select name="otId" required>
                                    <option value="" disabled selected>Select available OT</option>
                                    <% if (availableOts != null) for (Ot ot : availableOts) { %>
                                        <option value="<%= ot.getId() %>">OT-<%= ot.getId() %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="form-group" style="margin-bottom:10px;">
                                <label>Procedure Name</label>
                                <input type="text" name="procedureName" placeholder="e.g. Appendectomy" required />
                            </div>
                            <div class="form-group" style="margin-bottom:10px;">
                                <label>Date</label>
                                <input type="date" name="scheduleDate" required />
                            </div>
                            <div class="form-group" style="margin-bottom:10px;">
                                <label>Start Time</label>
                                <input type="time" name="startTime" required />
                            </div>
                            <div class="form-group" style="margin-bottom:10px;">
                                <label>End Time</label>
                                <input type="time" name="endTime" required />
                            </div>
                            <button type="submit" class="btn btn-primary btn-sm">Schedule Procedure</button>
                        </form>
                    </details>

                    <div class="section-divider"></div>
                    <div class="section-title"><i class="icon icon-clipboard"></i> Clinical Notes &amp; Prescriptions</div>

                    <%
                        List<PatientNote> notes = patientNotesMap != null ? patientNotesMap.get(p.getId()) : null;
                    %>
                    <% if (notes == null || notes.isEmpty()) { %>
                        <div class="no-data" style="padding:12px 0;">No notes recorded yet.</div>
                    <% } else { %>
                        <% for (PatientNote n : notes) { %>
                        <div class="note-item">
                            <div class="note-date"><i class="icon icon-calendar"></i> <%= n.getCreatedAt().format(noteFmt) %></div>
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

                    <details class="note-form-toggle">
                        <summary class="btn btn-primary btn-sm" style="display:inline-flex; cursor:pointer;">
                            <i class="icon icon-plus"></i> Add Note
                        </summary>
                        <form action="/doctor/patients/add-note" method="post" style="margin-top:12px;">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            <input type="hidden" name="patientId" value="<%= p.getId() %>" />
                            <div class="form-group" style="margin-bottom:10px;">
                                <label>Diagnosis</label>
                                <input type="text" name="diagnosis" placeholder="e.g. Acute bronchitis" required />
                            </div>
                            <div class="form-group" style="margin-bottom:10px;">
                                <label>Prescription</label>
                                <textarea name="prescription" placeholder="Medication, dosage, duration" required></textarea>
                            </div>
                            <div class="form-group" style="margin-bottom:10px;">
                                <label>Advice</label>
                                <textarea name="advice" placeholder="Rest, diet, lifestyle notes (optional)"></textarea>
                            </div>
                            <div class="form-group" style="margin-bottom:10px;">
                                <label>Follow-up Date</label>
                                <input type="date" name="followUpDate" />
                            </div>
                            <button type="submit" class="btn btn-primary btn-sm">Save Note</button>
                        </form>
                    </details>

                </div>
            </div>
            <% } %>
        </div>
    <% } %>
</div>

</body>
</html>
