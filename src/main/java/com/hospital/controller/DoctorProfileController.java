package com.hospital.controller;

import com.hospital.model.Doctor;
import com.hospital.repository.DoctorRepository;
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
public class DoctorProfileController {

    @Autowired private DoctorRepository doctorRepository;
    @Autowired private PasswordEncoder passwordEncoder;
    @Autowired private AuditLogService auditLogService;

    @GetMapping("/doctor/profile")
    public String profilePage(HttpSession session, Model model) {
        Long doctorId = (Long) session.getAttribute("loggedInId");
        Doctor doctor = doctorRepository.findById(doctorId).orElse(null);
        model.addAttribute("doctor", doctor);
        return "doctor/profile";
    }

    @PostMapping("/doctor/profile/update")
    public String updateProfile(
            @RequestParam @NotBlank String name,
            @RequestParam @NotBlank String phone,
            @RequestParam @NotBlank String specialization,
            @RequestParam @NotBlank String qualification,
            @RequestParam @NotBlank String department,
            HttpSession session) {

        Long doctorId = (Long) session.getAttribute("loggedInId");
        Doctor doctor = doctorRepository.findById(doctorId).orElse(null);
        if (doctor == null) {
            return "redirect:/doctor/profile?error=notfound";
        }

        String cleanName = com.hospital.util.Names.stripDoctorTitle(name);
        doctor.setName(cleanName);
        doctor.setPhone(phone);
        doctor.setSpecialization(specialization);
        doctor.setQualification(qualification);
        doctor.setDepartment(department);
        doctorRepository.save(doctor);

        session.setAttribute("userName", cleanName);
        auditLogService.record(session, "UPDATE", "Doctor", doctorId, "Profile updated");
        return "redirect:/doctor/profile?success=Profile updated successfully";
    }

    @PostMapping("/doctor/profile/password")
    public String updatePassword(
            @RequestParam @NotBlank String currentPassword,
            @RequestParam @NotBlank @Size(min = 8, message = "Password must be at least 8 characters") String newPassword,
            HttpSession session) {

        Long doctorId = (Long) session.getAttribute("loggedInId");
        Doctor doctor = doctorRepository.findById(doctorId).orElse(null);
        if (doctor == null) {
            return "redirect:/doctor/profile?error=notfound";
        }

        if (!passwordEncoder.matches(currentPassword, doctor.getPassword())) {
            return "redirect:/doctor/profile?error=wrongpassword";
        }

        doctor.setPassword(passwordEncoder.encode(newPassword));
        doctorRepository.save(doctor);

        auditLogService.record(session, "UPDATE", "Doctor", doctorId, "Password changed");
        return "redirect:/doctor/profile?success=Password changed successfully";
    }
}
