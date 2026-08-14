package com.hospital.config;

import com.hospital.model.AppointmentRequest;
import com.hospital.repository.AppointmentRequestRepository;
import com.hospital.service.AlertsService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.ArrayList;
import java.util.List;

/**
 * Injects the navbar notification-bell counts into every admin/doctor page's
 * model, without every controller having to fetch them individually.
 */
@ControllerAdvice
public class NavbarNotificationAdvice {

    @Autowired private AlertsService alertsService;
    @Autowired private AppointmentRequestRepository appointmentRequestRepository;

    @ModelAttribute
    public void addNotificationCounts(HttpServletRequest request, Model model) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        String role = (String) session.getAttribute("role");
        String uri = request.getRequestURI();

        if ("ADMIN".equals(role) && uri.startsWith("/admin")) {
            AlertsService.Summary summary = alertsService.getSummary();
            model.addAttribute("navAlertCount", summary.totalAlerts);

            List<String> preview = new ArrayList<>();
            summary.expiredBlood.forEach(b -> preview.add(b.getComponent() + " (" + b.getBloodGroup() + ") expired"));
            summary.expiringSoonBlood.forEach(b -> preview.add(b.getComponent() + " (" + b.getBloodGroup() + ") expiring soon"));
            summary.lowStockBlood.forEach(b -> preview.add(b.getComponent() + " (" + b.getBloodGroup() + ") low stock"));
            summary.lowOxygenTanks.forEach(t -> preview.add("Oxygen tank #" + t.getTankNo() + " running low"));
            summary.highRiskEquipment.forEach(e -> preview.add(e.getEquipmentType() + " #" + e.getEquipmentId() + " — high failure risk"));
            model.addAttribute("navAlertPreview", preview.subList(0, Math.min(3, preview.size())));
        } else if ("DOCTOR".equals(role) && uri.startsWith("/doctor")) {
            Long doctorId = (Long) session.getAttribute("loggedInId");
            List<AppointmentRequest> pending = appointmentRequestRepository
                .findByDoctorIdAndStatusOrderByCreatedAtDesc(doctorId, "PENDING");
            model.addAttribute("navAppointmentCount", pending.size());

            List<String> preview = new ArrayList<>();
            pending.stream().limit(3).forEach(r -> preview.add(r.getReason() + " (" + r.getPreferredDate() + ")"));
            model.addAttribute("navAppointmentPreview", preview);
        }
    }
}
