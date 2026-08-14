package com.hospital.controller;

import com.hospital.model.Doctor;
import com.hospital.repository.DoctorRepository;
import com.hospital.util.Csv;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;
import java.util.Locale;

@Controller
@RequestMapping("/admin")
@Validated
public class AdminDoctorController {

    @Autowired
    private DoctorRepository doctorRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private com.hospital.service.AuditLogService auditLogService;

    @GetMapping("/doctors")
    public String doctorsPage(
            @RequestParam(required = false) String q,
            HttpSession session, Model model) {
        List<Doctor> doctors = doctorRepository.findAll();
        if (q != null && !q.isBlank()) {
            String needle = q.trim().toLowerCase(Locale.ROOT);
            doctors = doctors.stream()
                .filter(d -> matches(d, needle))
                .toList();
        }
        model.addAttribute("doctors", doctors);
        model.addAttribute("totalDoctors", doctorRepository.count());
        model.addAttribute("q", q);
        return "admin/doctors";
    }

    private boolean matches(Doctor d, String needle) {
        return containsIgnoreCase(d.getName(), needle)
            || containsIgnoreCase(d.getEmail(), needle)
            || containsIgnoreCase(d.getDepartment(), needle)
            || containsIgnoreCase(d.getSpecialization(), needle)
            || containsIgnoreCase(d.getQualification(), needle)
            || containsIgnoreCase(d.getPhone(), needle);
    }

    private boolean containsIgnoreCase(String haystack, String needle) {
        return haystack != null && haystack.toLowerCase(Locale.ROOT).contains(needle);
    }

    @GetMapping("/doctors/export.csv")
    public void exportDoctorsCsv(
            @RequestParam(required = false) String q,
            HttpSession session, HttpServletResponse response) throws java.io.IOException {
        List<Doctor> doctors = doctorRepository.findAll();
        if (q != null && !q.isBlank()) {
            String needle = q.trim().toLowerCase(Locale.ROOT);
            doctors = doctors.stream().filter(d -> matches(d, needle)).toList();
        }

        response.setContentType("text/csv");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"doctors.csv\"");

        PrintWriter writer = response.getWriter();
        writer.println("ID,Name,Email,Phone,Department,Specialization,Qualification,Years of Experience");
        for (Doctor d : doctors) {
            writer.println(String.join(",",
                Csv.field(d.getId()),
                Csv.field(d.getName()),
                Csv.field(d.getEmail()),
                Csv.field(d.getPhone()),
                Csv.field(d.getDepartment()),
                Csv.field(d.getSpecialization()),
                Csv.field(d.getQualification()),
                Csv.field(d.getYearsOfExperience())));
        }
        writer.flush();

        auditLogService.record(session, "EXPORT", "Doctor", null, "CSV export, " + doctors.size() + " rows");
    }

    @PostMapping("/doctors/add")
    public String addDoctor(
            @RequestParam @NotBlank String name,
            @RequestParam @NotBlank @Email String email,
            @RequestParam @NotBlank @Size(min = 8, message = "Password must be at least 8 characters") String password,
            @RequestParam @NotBlank String phone,
            @RequestParam @NotBlank String specialization,
            @RequestParam @NotBlank String qualification,
            @RequestParam @NotBlank String department,
            @RequestParam String practiceStartDate,
            HttpSession session) {


        // Check if email already exists
        Doctor existing = doctorRepository.findByEmail(email);
        if (existing != null) {
            return "redirect:/admin/doctors?error=emailexists";
        }

        Doctor doctor = new Doctor();
        doctor.setName(com.hospital.util.Names.stripDoctorTitle(name));
        doctor.setEmail(email);
        doctor.setPassword(passwordEncoder.encode(password));
        doctor.setPhone(phone);
        doctor.setSpecialization(specialization);
        doctor.setQualification(qualification);
        doctor.setDepartment(department);
        doctor.setPracticeStartDate(LocalDate.parse(practiceStartDate));

        doctorRepository.save(doctor);
        auditLogService.record(session, "CREATE", "Doctor", doctor.getId(), "email=" + email);
        return "redirect:/admin/doctors?success=Doctor added successfully";
    }

    @PostMapping("/doctors/delete")
    public String deleteDoctor(@RequestParam Long id, HttpSession session) {
        doctorRepository.deleteById(id);
        auditLogService.record(session, "DELETE", "Doctor", id, null);
        return "redirect:/admin/doctors?success=Doctor removed successfully";
    }
}
