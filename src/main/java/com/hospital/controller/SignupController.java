package com.hospital.controller;

import com.hospital.model.Patient;
import com.hospital.repository.PatientRepository;
import com.hospital.service.RateLimiterService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;

@Controller
@Validated
public class SignupController {

	@Autowired
    private PatientRepository patientRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private RateLimiterService rateLimiterService;

    @GetMapping("/signup")
    public String showSignup() {
        return "signup";
    }

    @PostMapping("/signup")
    public String handleSignup(
            @RequestParam @NotBlank String name,
            @RequestParam @NotBlank @Email String email,
            @RequestParam @NotBlank @Size(min = 8, message = "Password must be at least 8 characters") String password,
            @RequestParam @NotBlank String phone,
            @RequestParam String dateOfBirth,
            @RequestParam @NotBlank String gender,
            @RequestParam @NotBlank String bloodGroup,
            @RequestParam @NotBlank String address,
            @RequestParam @NotBlank String emergencyContact,
            @RequestParam(required = false) String medicalHistory,
            HttpServletRequest request) {

        String clientIp = request.getRemoteAddr();
        if (rateLimiterService.isBlocked(clientIp)) {
            return "redirect:/signup?error=toomanyattempts";
        }

        // Check if email already exists
        Patient existing = patientRepository.findByEmail(email);
        if (existing != null) {
            rateLimiterService.recordFailure(clientIp);
            return "redirect:/signup?error=emailexists";
        }

        Patient patient = new Patient();
        patient.setName(name);
        patient.setEmail(email);
        patient.setPassword(passwordEncoder.encode(password));
        patient.setPhone(phone);
        patient.setDateOfBirth(LocalDate.parse(dateOfBirth));
        patient.setGender(gender);
        patient.setBloodGroup(bloodGroup);
        patient.setAddress(address);
        patient.setEmergencyContact(emergencyContact);
        patient.setMedicalHistory(medicalHistory);

        patientRepository.save(patient);
        rateLimiterService.recordSuccess(clientIp);

        return "redirect:/?success=true";
    }
}
