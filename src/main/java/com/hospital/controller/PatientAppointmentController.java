package com.hospital.controller;

import com.hospital.model.AppointmentRequest;
import com.hospital.model.DoctorPatient;
import com.hospital.repository.AppointmentRequestRepository;
import com.hospital.repository.DoctorPatientRepository;
import com.hospital.service.AuditLogService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.constraints.NotBlank;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;

@Controller
@Validated
public class PatientAppointmentController {

    @Autowired private AppointmentRequestRepository appointmentRequestRepository;
    @Autowired private DoctorPatientRepository doctorPatientRepository;
    @Autowired private AuditLogService auditLogService;

    @GetMapping("/patient/appointments")
    public String appointmentsPage(HttpSession session, Model model) {
        Long patientId = (Long) session.getAttribute("loggedInId");

        DoctorPatient assignment = doctorPatientRepository.findByPatientIdAndStatus(patientId, "ACTIVE");
        model.addAttribute("hasAssignedDoctor", assignment != null);
        model.addAttribute("requests", appointmentRequestRepository.findByPatientIdOrderByCreatedAtDesc(patientId));
        return "patient/appointments";
    }

    @PostMapping("/patient/appointments/request")
    public String createRequest(
            @RequestParam @NotBlank String reason,
            @RequestParam String preferredDate,
            HttpSession session) {

        Long patientId = (Long) session.getAttribute("loggedInId");

        DoctorPatient assignment = doctorPatientRepository.findByPatientIdAndStatus(patientId, "ACTIVE");
        if (assignment == null) {
            return "redirect:/patient/appointments?error=nodoctor";
        }

        LocalDate date = LocalDate.parse(preferredDate);
        if (date.isBefore(LocalDate.now())) {
            return "redirect:/patient/appointments?error=pastdate";
        }

        AppointmentRequest request = new AppointmentRequest();
        request.setPatientId(patientId);
        request.setDoctorId(assignment.getDoctorId());
        request.setReason(reason);
        request.setPreferredDate(date);
        appointmentRequestRepository.save(request);
        auditLogService.record(session, "CREATE", "AppointmentRequest", request.getId(), "doctorId=" + assignment.getDoctorId());

        return "redirect:/patient/appointments?success=Request submitted successfully";
    }
}
