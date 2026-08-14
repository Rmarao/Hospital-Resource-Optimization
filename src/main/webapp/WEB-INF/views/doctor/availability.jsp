<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <title>Doctor - Availability</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body data-role="doctor">

<%
    String activePage = "availability";

    Map<String, Boolean> availability = (Map<String, Boolean>) request.getAttribute("availability");
    String successMsg = request.getParameter("success") == null ? null
        : org.springframework.web.util.HtmlUtils.htmlEscape(request.getParameter("success"));
%>

<%@ include file="/WEB-INF/views/fragments/doctor-navbar.jspf" %>

<div class="page-main">
    <h1 style="font-size:22px; margin-bottom:16px;"><i class="icon icon-calendar"></i> Weekly Availability</h1>

    <% if (successMsg != null) { %>
        <div class="alert success"><i class="icon icon-check-circle"></i> <%= successMsg %></div>
    <% } %>

    <div class="card">
        <div class="card-header">
            <h3>Set your on-duty days</h3>
        </div>
        <table>
            <tr><th>Day</th><th>Status</th><th>Action</th></tr>
            <% for (Map.Entry<String, Boolean> entry : availability.entrySet()) {
                boolean isAvailable = entry.getValue();
            %>
            <tr>
                <td><%= entry.getKey().substring(0,1) + entry.getKey().substring(1).toLowerCase() %></td>
                <td>
                    <% if (isAvailable) { %>
                        <span class="badge green">Available</span>
                    <% } else { %>
                        <span class="badge grey">Unavailable</span>
                    <% } %>
                </td>
                <td>
                    <form action="/doctor/availability/update" method="post" class="inline-form">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        <input type="hidden" name="dayOfWeek" value="<%= entry.getKey() %>" />
                        <input type="hidden" name="available" value="<%= !isAvailable %>" />
                        <button type="submit" class="btn btn-sm <%= isAvailable ? "btn-danger" : "btn-primary" %>">
                            Mark <%= isAvailable ? "Unavailable" : "Available" %>
                        </button>
                    </form>
                </td>
            </tr>
            <% } %>
        </table>
    </div>
</div>

</body>
</html>
