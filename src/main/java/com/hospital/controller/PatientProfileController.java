package com.hospital.controller;

import com.hospital.model.Patient;
import com.hospital.repository.PatientRepository;
import com.hospital.service.AuditLogService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@Validated
public class PatientProfileController {

    @Autowired private PatientRepository patientRepository;
    @Autowired private PasswordEncoder passwordEncoder;
    @Autowired private AuditLogService auditLogService;

    @GetMapping("/patient/profile")
    public String profilePage(HttpSession session, Model model) {
        Long patientId = (Long) session.getAttribute("loggedInId");
        Patient patient = patientRepository.findById(patientId).orElse(null);
        model.addAttribute("patient", patient);
        return "patient/profile";
    }

    @PostMapping("/patient/profile/update")
    public String updateProfile(
            @RequestParam @NotBlank String name,
            @RequestParam @NotBlank String phone,
            @RequestParam(required = false) String gender,
            @RequestParam(required = false) String bloodGroup,
            @RequestParam(required = false) String address,
            @RequestParam(required = false) String emergencyContact,
            @RequestParam(required = false) String medicalHistory,
            HttpSession session) {

        Long patientId = (Long) session.getAttribute("loggedInId");
        Patient patient = patientRepository.findById(patientId).orElse(null);
        if (patient == null) {
            return "redirect:/patient/profile?error=notfound";
        }

        patient.setName(name);
        patient.setPhone(phone);
        patient.setGender(gender);
        patient.setBloodGroup(bloodGroup);
        patient.setAddress(address);
        patient.setEmergencyContact(emergencyContact);
        patient.setMedicalHistory(medicalHistory);
        patientRepository.save(patient);

        session.setAttribute("userName", name);
        auditLogService.record(session, "UPDATE", "Patient", patientId, "Profile updated");
        return "redirect:/patient/profile?success=Profile updated successfully";
    }

    @PostMapping("/patient/profile/password")
    public String updatePassword(
            @RequestParam @NotBlank String currentPassword,
            @RequestParam @NotBlank @Size(min = 8, message = "Password must be at least 8 characters") String newPassword,
            HttpSession session) {

        Long patientId = (Long) session.getAttribute("loggedInId");
        Patient patient = patientRepository.findById(patientId).orElse(null);
        if (patient == null) {
            return "redirect:/patient/profile?error=notfound";
        }

        if (!passwordEncoder.matches(currentPassword, patient.getPassword())) {
            return "redirect:/patient/profile?error=wrongpassword";
        }

        patient.setPassword(passwordEncoder.encode(newPassword));
        patientRepository.save(patient);

        auditLogService.record(session, "UPDATE", "Patient", patientId, "Password changed");
        return "redirect:/patient/profile?success=Password changed successfully";
    }
}
