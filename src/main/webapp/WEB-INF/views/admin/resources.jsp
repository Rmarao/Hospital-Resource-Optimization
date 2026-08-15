<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hospital.model.*" %>
<%@ page import="com.hospital.util.Esc" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Resources</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="admin">

<%
    String activePage = "resources";

    String activeTab = request.getParameter("tab") != null
                       ? request.getParameter("tab") : "beds";
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));

    List<Bed> beds = (List<Bed>) request.getAttribute("beds");
    List<Icu> icus = (List<Icu>) request.getAttribute("icus");
    List<Ot> ots = (List<Ot>) request.getAttribute("ots");
    List<OxygenTank> oxygenTanks = (List<OxygenTank>) request.getAttribute("oxygenTanks");
    List<BloodBank> bloodBanks = (List<BloodBank>) request.getAttribute("bloodBanks");

    long totalBeds = (long) request.getAttribute("totalBeds");
    long availableBeds = (long) request.getAttribute("availableBeds");
    long occupiedBeds = (long) request.getAttribute("occupiedBeds");

    long totalIcu = (long) request.getAttribute("totalIcu");
    long availableIcu = (long) request.getAttribute("availableIcu");
    long occupiedIcu = (long) request.getAttribute("occupiedIcu");

    long totalOt = (long) request.getAttribute("totalOt");
    long availableOt = (long) request.getAttribute("availableOt");

    long totalOxygen = (long) request.getAttribute("totalOxygen");
    long availableOxygen = (long) request.getAttribute("availableOxygen");
%>

<%@ include file="/WEB-INF/views/fragments/admin-sidebar.jspf" %>

<!-- Navbar -->
<div class="navbar">
    <h2><i class="icon icon-bed"></i> Resource Management</h2>
    <%@ include file="/WEB-INF/views/fragments/admin-notif-bell.jspf" %>
</div>

<!-- Main -->
<div class="main">

    <% if (successMsg != null) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> <%= successMsg %></div>
    <% } %>

    <!-- Tabs -->
    <div class="tabs">
        <a href="?tab=beds"   class="tab-btn <%= "beds".equals(activeTab)   ? "active" : "" %>"><i class="icon icon-bed"></i> Beds</a>
        <a href="?tab=icu"    class="tab-btn <%= "icu".equals(activeTab)    ? "active" : "" %>"><i class="icon icon-activity"></i> ICU</a>
        <a href="?tab=ot"     class="tab-btn <%= "ot".equals(activeTab)     ? "active" : "" %>"><i class="icon icon-scissors"></i> OT</a>
        <a href="?tab=oxygen" class="tab-btn <%= "oxygen".equals(activeTab) ? "active" : "" %>"><i class="icon icon-wind"></i> Oxygen</a>
        <a href="?tab=blood"  class="tab-btn <%= "blood".equals(activeTab)  ? "active" : "" %>"><i class="icon icon-droplet"></i> Blood Bank</a>
    </div>

    <!-- BEDS TAB -->
    <% if ("beds".equals(activeTab)) { %>

        <div class="stats-row cols-3">
            <div class="stat-card"><div class="value"><%= totalBeds %></div><div class="label">Total Beds</div></div>
            <div class="stat-card"><div class="value"><%= availableBeds %></div><div class="label">Available</div></div>
            <div class="stat-card"><div class="value"><%= occupiedBeds %></div><div class="label">Occupied</div></div>
        </div>

        <div class="add-form">
            <h4><i class="icon icon-plus"></i> Add New Bed</h4>
            <form action="/admin/resources/beds/add" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-row">
                    <div class="form-group">
                        <label>Bed Number</label>
                        <input type="text" name="bedNumber" placeholder="e.g. B101" required />
                    </div>
                    <div class="form-group">
                        <label>Ward</label>
                        <input type="text" name="ward" placeholder="e.g. General" required />
                    </div>
                    <div class="form-group">
                        <label>Floor</label>
                        <input type="number" name="floor" placeholder="e.g. 1" required />
                    </div>
                    <button type="submit" class="btn btn-primary">Add Bed</button>
                </div>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>All Beds</h3></div>
            <% if (beds == null || beds.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-bed"></i><p>No beds added yet.</p></div>
            <% } else { %>
                <table>
                    <tr><th>ID</th><th>Bed Number</th><th>Ward</th><th>Floor</th><th>Status</th><th>Actions</th></tr>
                    <% for (Bed bed : beds) { %>
                    <tr>
                        <td>#<%= bed.getId() %></td>
                        <td><strong><%= bed.getBedNumber() %></strong></td>
                        <td><%= bed.getWard() %></td>
                        <td>Floor <%= bed.getFloor() %></td>
                        <td>
                            <% if ("AVAILABLE".equals(bed.getStatus())) { %>
                                <span class="badge green">Available</span>
                            <% } else if ("OCCUPIED".equals(bed.getStatus())) { %>
                                <span class="badge red">Occupied</span>
                            <% } else { %>
                                <span class="badge orange">Maintenance</span>
                            <% } %>
                        </td>
                        <td>
                            <form action="/admin/resources/beds/status" method="post" class="inline-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= bed.getId() %>" />
                                <select name="status" style="width:auto; display:inline-block;">
                                    <option value="AVAILABLE">Available</option>
                                    <option value="OCCUPIED">Occupied</option>
                                    <option value="MAINTENANCE">Maintenance</option>
                                </select>
                                <button type="submit" class="btn btn-success btn-sm">Update</button>
                            </form>
                            <form action="/admin/resources/beds/delete" method="post" class="inline-form"
                                  data-confirm="Delete this bed?">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= bed.getId() %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
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

        <div class="stats-row cols-3">
            <div class="stat-card"><div class="value"><%= totalIcu %></div><div class="label">Total ICU Units</div></div>
            <div class="stat-card"><div class="value"><%= availableIcu %></div><div class="label">Available</div></div>
            <div class="stat-card"><div class="value"><%= occupiedIcu %></div><div class="label">Occupied</div></div>
        </div>

        <div class="add-form">
            <h4><i class="icon icon-plus"></i> Add New ICU Unit</h4>
            <form action="/admin/resources/icu/add" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-row">
                    <div class="form-group">
                        <label>Ventilator Support</label>
                        <select name="ventilator">
                            <option value="true">Yes</option>
                            <option value="false">No</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary">Add ICU Unit</button>
                </div>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>All ICU Units</h3></div>
            <% if (icus == null || icus.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-activity"></i><p>No ICU units added yet.</p></div>
            <% } else { %>
                <table>
                    <tr><th>ID</th><th>Ventilator</th><th>Status</th><th>Actions</th></tr>
                    <% for (Icu icu : icus) { %>
                    <tr>
                        <td>#<%= icu.getId() %></td>
                        <td>
                            <% if (icu.getVentilator()) { %>
                                <span class="badge blue">Yes</span>
                            <% } else { %>
                                <span class="badge grey">No</span>
                            <% } %>
                        </td>
                        <td>
                            <% if ("AVAILABLE".equals(icu.getStatus())) { %>
                                <span class="badge green">Available</span>
                            <% } else if ("OCCUPIED".equals(icu.getStatus())) { %>
                                <span class="badge red">Occupied</span>
                            <% } else { %>
                                <span class="badge orange">Maintenance</span>
                            <% } %>
                        </td>
                        <td>
                            <form action="/admin/resources/icu/status" method="post" class="inline-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= icu.getId() %>" />
                                <select name="status" style="width:auto; display:inline-block;">
                                    <option value="AVAILABLE">Available</option>
                                    <option value="OCCUPIED">Occupied</option>
                                    <option value="MAINTENANCE">Maintenance</option>
                                </select>
                                <button type="submit" class="btn btn-success btn-sm">Update</button>
                            </form>
                            <form action="/admin/resources/icu/delete" method="post" class="inline-form"
                                  data-confirm="Delete this ICU unit?">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= icu.getId() %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
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

        <div class="stats-row cols-3">
            <div class="stat-card"><div class="value"><%= totalOt %></div><div class="label">Total OTs</div></div>
            <div class="stat-card"><div class="value"><%= availableOt %></div><div class="label">Available</div></div>
            <div class="stat-card"><div class="value"><%= totalOt - availableOt %></div><div class="label">In Use / Maintenance</div></div>
        </div>

        <div class="add-form">
            <h4><i class="icon icon-plus"></i> Add New Operation Theatre</h4>
            <form action="/admin/resources/ot/add" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-row">
                    <button type="submit" class="btn btn-primary">Add OT</button>
                </div>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>All Operation Theatres</h3></div>
            <% if (ots == null || ots.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-scissors"></i><p>No OTs added yet.</p></div>
            <% } else { %>
                <table>
                    <tr><th>OT ID</th><th>Name</th><th>Status</th><th>Actions</th></tr>
                    <% for (Ot ot : ots) { %>
                    <tr>
                        <td>#<%= ot.getId() %></td>
                        <td><strong>OT-<%= ot.getId() %></strong></td>
                        <td>
                            <% if ("AVAILABLE".equals(ot.getStatus())) { %>
                                <span class="badge green">Available</span>
                            <% } else if ("OCCUPIED".equals(ot.getStatus())) { %>
                                <span class="badge red">In Use</span>
                            <% } else { %>
                                <span class="badge orange">Maintenance</span>
                            <% } %>
                        </td>
                        <td>
                            <form action="/admin/resources/ot/status" method="post" class="inline-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= ot.getId() %>" />
                                <select name="status" style="width:auto; display:inline-block;">
                                    <option value="AVAILABLE">Available</option>
                                    <option value="OCCUPIED">In Use</option>
                                    <option value="MAINTENANCE">Maintenance</option>
                                </select>
                                <button type="submit" class="btn btn-success btn-sm">Update</button>
                            </form>
                            <form action="/admin/resources/ot/delete" method="post" class="inline-form"
                                  data-confirm="Delete this OT?">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= ot.getId() %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

    <% } %>

    <!-- OXYGEN TAB -->
    <% if ("oxygen".equals(activeTab)) { %>

        <div class="stats-row cols-3">
            <div class="stat-card"><div class="value"><%= totalOxygen %></div><div class="label">Total Tanks</div></div>
            <div class="stat-card"><div class="value"><%= availableOxygen %></div><div class="label">Available</div></div>
            <div class="stat-card"><div class="value"><%= totalOxygen - availableOxygen %></div><div class="label">In Use / Empty</div></div>
        </div>

        <div class="add-form">
            <h4><i class="icon icon-plus"></i> Add New Oxygen Tank</h4>
            <form action="/admin/resources/oxygen/add" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-row">
                    <div class="form-group">
                        <label>Tank Number</label>
                        <input type="number" name="tankNo" placeholder="e.g. 101" required />
                    </div>
                    <div class="form-group">
                        <label>Capacity (L)</label>
                        <input type="number" name="capacity" placeholder="e.g. 50" required />
                    </div>
                    <div class="form-group">
                        <label>Current Level (L)</label>
                        <input type="number" step="0.1" name="currentLevel" placeholder="e.g. 45.5" required />
                    </div>
                    <button type="submit" class="btn btn-primary">Add Tank</button>
                </div>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>All Oxygen Tanks</h3></div>
            <% if (oxygenTanks == null || oxygenTanks.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-wind"></i><p>No oxygen tanks added yet.</p></div>
            <% } else { %>
                <table>
                    <tr><th>Tank No</th><th>Capacity</th><th>Current Level</th><th>Fill %</th><th>Status</th><th>Actions</th></tr>
                    <% for (OxygenTank tank : oxygenTanks) { %>
                    <%
                        float fillPct = tank.getCapacity() != null && tank.getCapacity() > 0
                            ? (tank.getCurrentLevel() / tank.getCapacity()) * 100 : 0;
                    %>
                    <tr>
                        <td><strong>Tank #<%= tank.getTankNo() %></strong></td>
                        <td><%= tank.getCapacity() %> L</td>
                        <td><%= tank.getCurrentLevel() %> L</td>
                        <td>
                            <span class="badge <%= fillPct > 50 ? "green" : fillPct > 20 ? "orange" : "red" %>">
                                <%= String.format("%.0f", fillPct) %>%
                            </span>
                        </td>
                        <td>
                            <% if ("AVAILABLE".equals(tank.getStatus())) { %>
                                <span class="badge green">Available</span>
                            <% } else if ("IN_USE".equals(tank.getStatus())) { %>
                                <span class="badge orange">In Use</span>
                            <% } else { %>
                                <span class="badge red">Empty</span>
                            <% } %>
                        </td>
                        <td>
                            <form action="/admin/resources/oxygen/update" method="post" class="inline-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= tank.getId() %>" />
                                <input type="number" step="0.1" name="currentLevel"
                                       value="<%= tank.getCurrentLevel() %>" style="width:80px; display:inline-block;" />
                                <select name="status" style="width:auto; display:inline-block;">
                                    <option value="AVAILABLE">Available</option>
                                    <option value="IN_USE">In Use</option>
                                    <option value="EMPTY">Empty</option>
                                </select>
                                <button type="submit" class="btn btn-success btn-sm">Update</button>
                            </form>
                            <form action="/admin/resources/oxygen/delete" method="post" class="inline-form"
                                  data-confirm="Delete this tank?">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= tank.getId() %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                            </form>
                        </td>
                    </tr>
                    <% } %>
                </table>
            <% } %>
        </div>

    <% } %>

    <!-- BLOOD BANK TAB -->
    <% if ("blood".equals(activeTab)) { %>

        <div class="add-form">
            <h4><i class="icon icon-plus"></i> Add Blood Component</h4>
            <form action="/admin/resources/blood/add" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-row">
                    <div class="form-group">
                        <label>Component</label>
                        <select name="component" required>
                            <option value="" disabled selected>Select</option>
                            <option value="Red Blood Cells">Red Blood Cells</option>
                            <option value="Platelets">Platelets</option>
                            <option value="Fresh Frozen Plasma">Fresh Frozen Plasma</option>
                            <option value="Cryoprecipitate">Cryoprecipitate</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Blood Group</label>
                        <select name="bloodGroup" required>
                            <option value="" disabled selected>Select</option>
                            <option value="A+">A+</option>
                            <option value="A-">A-</option>
                            <option value="B+">B+</option>
                            <option value="B-">B-</option>
                            <option value="O+">O+</option>
                            <option value="O-">O-</option>
                            <option value="AB+">AB+</option>
                            <option value="AB-">AB-</option>
                            <option value="ANY">ANY</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Units</label>
                        <input type="number" name="quantityUnits" placeholder="e.g. 10" required />
                    </div>
                    <div class="form-group">
                        <label>Collection Date</label>
                        <input type="date" name="collectionDate" required />
                    </div>
                    <div class="form-group">
                        <label>Expiry Date</label>
                        <input type="date" name="expiryDate" required />
                    </div>
                    <button type="submit" class="btn btn-primary">Add</button>
                </div>
            </form>
        </div>

        <div class="card">
            <div class="card-header"><h3>Blood Bank Inventory</h3></div>
            <% if (bloodBanks == null || bloodBanks.isEmpty()) { %>
                <div class="empty-state"><i class="icon icon-droplet"></i><p>No blood components added yet.</p></div>
            <% } else { %>
                <table>
                    <tr>
                        <th>ID</th><th>Component</th><th>Blood Group</th><th>Units</th>
                        <th>Collection</th><th>Expiry</th><th>Days Left</th><th>Status</th><th>Actions</th>
                    </tr>
                    <% for (BloodBank b : bloodBanks) { %>
                    <tr>
                        <td>#<%= b.getId() %></td>
                        <td><%= Esc.h(b.getComponent()) %></td>
                        <td><strong><%= Esc.h(b.getBloodGroup()) %></strong></td>
                        <td><%= b.getQuantityUnits() %> units</td>
                        <td><%= b.getCollectionDate() %></td>
                        <td><%= b.getExpiryDate() %></td>
                        <td>
                            <span class="badge <%= b.getDaysUntilExpiry() > 7 ? "green" : b.getDaysUntilExpiry() > 0 ? "orange" : "red" %>">
                                <%= b.isExpired() ? "Expired" : b.getDaysUntilExpiry() + " days" %>
                            </span>
                        </td>
                        <td>
                            <% if ("AVAILABLE".equals(b.getStatus())) { %>
                                <span class="badge green">Available</span>
                            <% } else { %>
                                <span class="badge red"><%= b.getStatus() %></span>
                            <% } %>
                        </td>
                        <td>
                            <form action="/admin/resources/blood/update" method="post" class="inline-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= b.getId() %>" />
                                <input type="number" name="quantityUnits"
                                       value="<%= b.getQuantityUnits() %>" style="width:60px; display:inline-block;" />
                                <select name="status" style="width:auto; display:inline-block;">
                                    <option value="AVAILABLE">Available</option>
                                    <option value="RESERVED">Reserved</option>
                                    <option value="EXPIRED">Expired</option>
                                </select>
                                <button type="submit" class="btn btn-success btn-sm">Update</button>
                            </form>
                            <form action="/admin/resources/blood/delete" method="post" class="inline-form"
                                  data-confirm="Delete this record?">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <input type="hidden" name="id" value="<%= b.getId() %>" />
                                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
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
