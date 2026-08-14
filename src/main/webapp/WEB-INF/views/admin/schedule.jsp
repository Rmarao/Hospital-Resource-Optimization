<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.model.*" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Schedule</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<%
    String activePage = "schedule";

    String activeTab = request.getParameter("tab") != null
                       ? request.getParameter("tab") : "bed";
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));
	String errorMsg = request.getParameter("error");

    List<Patient> patients = (List<Patient>) request.getAttribute("patients");
    List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");
    List<Bed> availableBeds = (List<Bed>) request.getAttribute("availableBeds");
    List<Icu> availableIcus = (List<Icu>) request.getAttribute("availableIcus");
    List<Ot> availableOts = (List<Ot>) request.getAttribute("availableOts");
    List<BedAdmission> bedAdmissions = (List<BedAdmission>) request.getAttribute("bedAdmissions");
    List<IcuAdmission> icuAdmissions = (List<IcuAdmission>) request.getAttribute("icuAdmissions");
    List<OtSchedule> otSchedules = (List<OtSchedule>) request.getAttribute("otSchedules");

    java.util.Map<Long, String> patientNameMap = new java.util.HashMap<>();
    java.util.Map<Long, String> doctorNameMap = new java.util.HashMap<>();

    if (patients != null)
        for (Patient p : patients) patientNameMap.put(p.getId(), p.getName());
    if (doctors != null)
        for (Doctor d : doctors) doctorNameMap.put(d.getId(), d.getName());
%>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-calendar"></i> Schedule &amp; Resource Assignment</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <% if (successMsg != null) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> <%= successMsg %></div>
    <% } %>

    <% if ("otconflict".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> OT Conflict! This OT is already booked during that time slot. Please choose a different time or OT.</div>
    <% } else if ("doctorconflict".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> Doctor Conflict! This doctor already has a procedure scheduled during that time.</div>
    <% } else if ("invalidtime".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> Invalid time! End time must be after start time.</div>
    <% } else if ("pastdate".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> Cannot schedule OT in the past!</div>
    <% } else if ("bedoccupied".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> This bed is already occupied! Please select a different bed.</div>
    <% } else if ("invaliddates".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> Discharge date must be after admission date!</div>
    <% } else if ("bedbooked".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> This bed is already booked during those dates! Please choose different dates or a different bed.</div>
    <% } else if ("icubooked".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-circle"></i> This ICU unit is already booked during those dates! Please choose different dates or a different ICU unit.</div>
    <% } else if ("noanalysis".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-triangle"></i> Patient has not been analysed yet. Go to Patients page and click Analyse first.</div>
    <% } else if ("noavailableresources".equals(errorMsg)) { %>
        <div class="alert error"><i class="icon icon-alert-triangle"></i> No available resources found or no doctor assigned. Please check resource availability.</div>
    <% } %>

    <!-- Tabs -->
    <div class="tabs">
        <a href="?tab=bed" class="tab-btn <%= "bed".equals(activeTab) ? "active" : "" %>"><i class="icon icon-bed"></i> Bed Admission</a>
        <a href="?tab=icu" class="tab-btn <%= "icu".equals(activeTab) ? "active" : "" %>"><i class="icon icon-activity"></i> ICU Admission</a>
        <a href="?tab=ot"  class="tab-btn <%= "ot".equals(activeTab)  ? "active" : "" %>"><i class="icon icon-scissors"></i> OT Schedule</a>
    </div>

	<!-- Auto Allocate Section -->
	<% if ("bed".equals(activeTab)) { %>
	<div class="add-form on-surface" style="border-left:4px solid var(--info);">
	    <h4 style="color:var(--info-strong); border-bottom:none; padding-bottom:0;"><i class="icon icon-sparkles"></i> AI Auto Allocation</h4>
	    <p style="font-size:13px; color:var(--text-mute); margin-bottom:12px;">
	        Select a patient to auto-allocate resources based on their AI analysis and severity score.
	    </p>
	    <form action="/admin/schedule/auto-allocate" method="post">
	        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
	        <div class="form-grid">
	            <div class="form-group">
	                <label>Patient</label>
	                <select name="patientId" required>
	                    <option value="" disabled selected>Select Patient</option>
	                    <% if (patients != null) for (Patient p : patients) { %>
	                        <option value="<%= p.getId() %>"><%= Esc.h(p.getName()) %></option>
	                    <% } %>
	                </select>
	            </div>
	        </div>
	        <button type="submit" class="btn btn-info"><i class="icon icon-sparkles"></i> Auto Allocate Resources</button>
	    </form>
	</div>
	<% } %>

    <!-- BED TAB -->
    <% if ("bed".equals(activeTab)) { %>

        <div class="add-form">
            <h4><i class="icon icon-plus"></i> Assign Bed to Patient</h4>
            <form action="/admin/schedule/assign-bed" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-grid">
                    <div class="form-group">
                        <label>Patient</label>
                        <select name="patientId" required>
                            <option value="" disabled selected>Select Patient</option>
                            <% if (patients != null) for (Patient p : patients) { %>
                                <option value="<%= p.getId() %>"><%= Esc.h(p.getName()) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Doctor</label>
                        <select name="doctorId" required>
                            <option value="" disabled selected>Select Doctor</option>
                            <% if (doctors != null) for (Doctor d : doctors) { %>
                                <option value="<%= d.getId() %>">Dr. <%= Esc.h(d.getName()) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Available Bed</label>
                        <select name="bedId" required>
                            <option value="" disabled selected>Select Bed</option>
                            <% if (availableBeds != null) for (Bed b : availableBeds) { %>
                                <option value="<%= b.getId() %>">
                                    <%= b.getBedNumber() %> &mdash; <%= b.getWard() %> (Floor <%= b.getFloor() %>)
                                </option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Admitted Date</label>
                        <input type="date" name="admittedDate" required />
                    </div>
                    <div class="form-group">
                        <label>Expected Discharge</label>
                        <input type="date" name="dischargeDate" required />
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Assign Bed</button>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>Active Bed Admissions</h3></div>
            <% if (bedAdmissions == null || bedAdmissions.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-bed"></i><p>No active bed admissions.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Patient</th><th>Doctor</th><th>Bed ID</th><th>Admitted</th><th>Discharge</th><th>Status</th><th>Action</th></tr>
                    <% for (BedAdmission ba : bedAdmissions) { %>
                    <tr>
                        <td><%= Esc.h(patientNameMap.getOrDefault(ba.getPatientId(), "Unknown")) %></td>
                        <td>Dr. <%= Esc.h(doctorNameMap.getOrDefault(ba.getDoctorId(), "Unknown")) %></td>
                        <td>Bed #<%= ba.getBedId() %></td>
                        <td><%= ba.getAdmittedDate() %></td>
                        <td><%= ba.getDischargeDate() %></td>
                        <td><span class="badge green">Active</span></td>
                        <td>
                            <form action="/admin/schedule/release-bed" method="post"
                                  class="inline-form"
                                  onsubmit="return confirm('Discharge this patient?')">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="admissionId" value="<%= ba.getId() %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Discharge</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

    <% } %>

    <!-- ICU TAB -->
    <% if ("icu".equals(activeTab)) { %>

        <div class="add-form">
            <h4><i class="icon icon-plus"></i> Admit Patient to ICU</h4>
            <form action="/admin/schedule/assign-icu" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-grid">
                    <div class="form-group">
                        <label>Patient</label>
                        <select name="patientId" required>
                            <option value="" disabled selected>Select Patient</option>
                            <% if (patients != null) for (Patient p : patients) { %>
                                <option value="<%= p.getId() %>"><%= Esc.h(p.getName()) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Doctor</label>
                        <select name="doctorId" required>
                            <option value="" disabled selected>Select Doctor</option>
                            <% if (doctors != null) for (Doctor d : doctors) { %>
                                <option value="<%= d.getId() %>">Dr. <%= Esc.h(d.getName()) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Available ICU Unit</label>
                        <select name="icuId" required>
                            <option value="" disabled selected>Select ICU</option>
                            <% if (availableIcus != null) for (Icu i : availableIcus) { %>
                                <option value="<%= i.getId() %>">
                                    ICU #<%= i.getId() %>
                                    <%= i.getVentilator() ? "— Ventilator" : "" %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Admitted Date</label>
                        <input type="date" name="admittedDate" required />
                    </div>
                    <div class="form-group">
                        <label>Expected Release</label>
                        <input type="date" name="dischargeDate" required />
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Admit to ICU</button>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>Active ICU Admissions</h3></div>
            <% if (icuAdmissions == null || icuAdmissions.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-activity"></i><p>No active ICU admissions.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Patient</th><th>Doctor</th><th>ICU Unit</th><th>Admitted</th><th>Expected Release</th><th>Status</th><th>Action</th></tr>
                    <% for (IcuAdmission ia : icuAdmissions) { %>
                    <tr>
                        <td><%= Esc.h(patientNameMap.getOrDefault(ia.getPatientId(), "Unknown")) %></td>
                        <td>Dr. <%= Esc.h(doctorNameMap.getOrDefault(ia.getDoctorId(), "Unknown")) %></td>
                        <td>ICU #<%= ia.getIcuId() %></td>
                        <td><%= ia.getAdmittedDate() %></td>
                        <td><%= ia.getDischargeDate() %></td>
                        <td><span class="badge red">Active</span></td>
                        <td>
                            <form action="/admin/schedule/release-icu" method="post"
                                  class="inline-form"
                                  onsubmit="return confirm('Discharge from ICU?')">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="admissionId" value="<%= ia.getId() %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Discharge</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

    <% } %>

    <!-- OT TAB -->
    <% if ("ot".equals(activeTab)) { %>

        <div class="add-form">
            <h4><i class="icon icon-plus"></i> Schedule Operation Theatre</h4>
            <form action="/admin/schedule/assign-ot" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-grid">
                    <div class="form-group">
                        <label>Patient</label>
                        <select name="patientId" required>
                            <option value="" disabled selected>Select Patient</option>
                            <% if (patients != null) for (Patient p : patients) { %>
                                <option value="<%= p.getId() %>"><%= Esc.h(p.getName()) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Doctor</label>
                        <select name="doctorId" required>
                            <option value="" disabled selected>Select Doctor</option>
                            <% if (doctors != null) for (Doctor d : doctors) { %>
                                <option value="<%= d.getId() %>">Dr. <%= Esc.h(d.getName()) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Operation Theatre</label>
                        <select name="otId" required>
                            <option value="" disabled selected>Select OT</option>
                            <% if (availableOts != null) for (Ot o : availableOts) { %>
                                <option value="<%= o.getId() %>">OT-<%= o.getId() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Procedure Name</label>
                        <input type="text" name="procedureName" placeholder="e.g. Appendectomy" required />
                    </div>
                    <div class="form-group">
                        <label>Date</label>
                        <input type="date" name="scheduleDate" required />
                    </div>
                    <div class="form-group">
                        <label>Start Time</label>
                        <input type="time" name="startTime" required />
                    </div>
                    <div class="form-group">
                        <label>End Time</label>
                        <input type="time" name="endTime" required />
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Schedule OT</button>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>Scheduled Procedures</h3></div>
            <% if (otSchedules == null || otSchedules.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-scissors"></i><p>No OT procedures scheduled.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Patient</th><th>Doctor</th><th>OT</th><th>Procedure</th><th>Date</th><th>Time</th><th>Status</th><th>Action</th></tr>
                    <% for (OtSchedule os : otSchedules) { %>
                    <tr>
                        <td><%= Esc.h(patientNameMap.getOrDefault(os.getPatientId(), "Unknown")) %></td>
                        <td>Dr. <%= Esc.h(doctorNameMap.getOrDefault(os.getDoctorId(), "Unknown")) %></td>
                        <td>OT-<%= os.getOtId() %></td>
                        <td><%= Esc.h(os.getProcedureName()) %></td>
                        <td><%= os.getScheduleDate() %></td>
                        <td><%= os.getStartTime() %> &ndash; <%= os.getEndTime() %></td>
                        <td><span class="badge orange">Scheduled</span></td>
                        <td>
                            <form action="/admin/schedule/update-ot" method="post" class="inline-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="scheduleId" value="<%= os.getId() %>" />
                                <select name="status" style="width:auto; display:inline-block;">
                                    <option value="COMPLETED">Completed</option>
                                    <option value="CANCELLED">Cancelled</option>
                                </select>
                                <button type="submit" class="btn btn-success btn-sm">Update</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

    <% } %>

</div>

</body>
</html>
