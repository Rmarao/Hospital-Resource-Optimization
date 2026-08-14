package com.hospital.controller;

import com.hospital.model.*;
import com.hospital.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Controller
public class DashboardController {

    @Autowired private AdminRepository adminRepository;
    @Autowired private DoctorRepository doctorRepository;
    @Autowired private PatientRepository patientRepository;
    @Autowired private BedRepository bedRepository;
    @Autowired private IcuRepository icuRepository;
    @Autowired private OtRepository otRepository;
    @Autowired private OxygenTankRepository oxygenTankRepository;
    @Autowired private BloodBankRepository bloodBankRepository;
    @Autowired private BedAdmissionRepository bedAdmissionRepository;
    @Autowired private IcuAdmissionRepository icuAdmissionRepository;
    @Autowired private OtScheduleRepository otScheduleRepository;
    @Autowired private DoctorPatientRepository doctorPatientRepository;
    @Autowired private PatientNoteRepository patientNoteRepository;
    @Autowired private com.hospital.service.DashboardStatsService dashboardStatsService;
    @Autowired private PatientRecommendationRepository recommendationRepository;

    // ─── ADMIN DASHBOARD ──────────────────────────────────────

    @GetMapping("/admin/dashboard")
    public String adminDashboard(HttpSession session, Model model) {
        Long adminId = (Long) session.getAttribute("loggedInId");
        Admin admin = adminRepository.findById(adminId).orElse(null);
        model.addAttribute("admin", admin);

        // Resource counts — cached 30s (see DashboardStatsService) instead of
        // 10 separate COUNT queries on every dashboard load.
        Map<String, Long> stats = dashboardStatsService.getResourceCounts();
        model.addAttribute("totalBeds", stats.get("totalBeds"));
        model.addAttribute("availableBeds", stats.get("availableBeds"));
        model.addAttribute("occupiedBeds", stats.get("occupiedBeds"));

        model.addAttribute("totalIcu", stats.get("totalIcu"));
        model.addAttribute("availableIcu", stats.get("availableIcu"));
        model.addAttribute("occupiedIcu", stats.get("occupiedIcu"));

        model.addAttribute("totalOt", stats.get("totalOt"));
        model.addAttribute("availableOt", stats.get("availableOt"));

        model.addAttribute("totalOxygen", stats.get("totalOxygen"));
        model.addAttribute("availableOxygen", stats.get("availableOxygen"));

        model.addAttribute("totalDoctors", stats.get("totalDoctors"));
        model.addAttribute("totalPatients", stats.get("totalPatients"));

        // Recent doctors and patients (last 5)
        List<Doctor> allDoctors = doctorRepository.findAll();
        List<Patient> allPatients = patientRepository.findAll();
        model.addAttribute("recentDoctors",
            allDoctors.subList(Math.max(0, allDoctors.size() - 5), allDoctors.size()));
        model.addAttribute("recentPatients",
            allPatients.subList(Math.max(0, allPatients.size() - 5), allPatients.size()));

        // Today's OT schedules
        model.addAttribute("todayOtSchedules",
            otScheduleRepository.findByScheduleDate(LocalDate.now()));

        // Active admissions
        model.addAttribute("activeBedAdmissions",
            bedAdmissionRepository.findByStatus("ACTIVE"));
        model.addAttribute("activeIcuAdmissions",
            icuAdmissionRepository.findByStatus("ACTIVE"));

        // Blood bank
        model.addAttribute("bloodBanks", bloodBankRepository.findAll());

        // Helper maps for names
        java.util.Map<Long, String> patientNameMap = new java.util.HashMap<>();
        java.util.Map<Long, String> doctorNameMap = new java.util.HashMap<>();
        for (Patient p : allPatients) patientNameMap.put(p.getId(), p.getName());
        for (Doctor d : allDoctors) doctorNameMap.put(d.getId(), d.getName());
        model.addAttribute("patientNameMap", patientNameMap);
        model.addAttribute("doctorNameMap", doctorNameMap);

        // Risk-level distribution across each patient's latest AI recommendation
        Map<String, Integer> riskDistribution = new java.util.LinkedHashMap<>();
        riskDistribution.put("LOW", 0);
        riskDistribution.put("MEDIUM", 0);
        riskDistribution.put("HIGH", 0);
        riskDistribution.put("CRITICAL", 0);
        for (Patient p : allPatients) {
            recommendationRepository.findTopByPatientIdOrderByCreatedAtDesc(p.getId())
                .ifPresent(rec -> riskDistribution.merge(rec.getSeverityLevel(), 1, Integer::sum));
        }
        model.addAttribute("riskDistribution", riskDistribution);

        return "admin/dashboard";
    }

    // ─── DOCTOR DASHBOARD ─────────────────────────────────────

    @GetMapping("/doctor/dashboard")
    public String doctorDashboard(HttpSession session, Model model) {
        Long doctorId = (Long) session.getAttribute("loggedInId");
        Doctor doctor = doctorRepository.findById(doctorId).orElse(null);
        model.addAttribute("doctor", doctor);

        // Assigned patients
        List<DoctorPatient> assignments =
            doctorPatientRepository.findByDoctorId(doctorId);
        List<DoctorPatient> activeAssignments = assignments.stream()
            .filter(a -> "ACTIVE".equals(a.getStatus()))
            .collect(java.util.stream.Collectors.toList());
        model.addAttribute("activeAssignments", activeAssignments);

        // Fetch patient details for each assignment
        java.util.Map<Long, Patient> patientMap = new java.util.HashMap<>();
        for (DoctorPatient dp : activeAssignments) {
            patientRepository.findById(dp.getPatientId())
                .ifPresent(p -> patientMap.put(p.getId(), p));
        }
        model.addAttribute("patientMap", patientMap);

        // Today's OT schedules for this doctor
        List<OtSchedule> todayOt = otScheduleRepository
            .findByScheduleDate(LocalDate.now())
            .stream()
            .filter(o -> doctorId.equals(o.getDoctorId()))
            .collect(java.util.stream.Collectors.toList());
        model.addAttribute("todayOtSchedules", todayOt);

        // Active bed admissions for this doctor
        List<BedAdmission> bedAdmissions = bedAdmissionRepository
            .findByDoctorId(doctorId)
            .stream()
            .filter(b -> "ACTIVE".equals(b.getStatus()))
            .collect(java.util.stream.Collectors.toList());
        model.addAttribute("bedAdmissions", bedAdmissions);

        // Counts
        model.addAttribute("totalPatients", activeAssignments.size());
        model.addAttribute("todayAppointments", todayOt.size());
        model.addAttribute("activeBeds", bedAdmissions.size());

        return "doctor/dashboard";
    }

    // ─── PATIENT DASHBOARD ────────────────────────────────────

    @GetMapping("/patient/dashboard")
    public String patientDashboard(HttpSession session, Model model) {
        Long patientId = (Long) session.getAttribute("loggedInId");
        Patient patient = patientRepository.findById(patientId).orElse(null);
        model.addAttribute("patient", patient);

        // Assigned doctor
        DoctorPatient assignment = doctorPatientRepository
            .findByPatientIdAndStatus(patientId, "ACTIVE");
        if (assignment != null) {
            Doctor assignedDoctor = doctorRepository
                .findById(assignment.getDoctorId()).orElse(null);
            model.addAttribute("assignedDoctor", assignedDoctor);
        }

        // Active bed admission
        BedAdmission bedAdmission = bedAdmissionRepository
            .findByStatus("ACTIVE").stream()
            .filter(b -> patientId.equals(b.getPatientId()))
            .findFirst().orElse(null);
        model.addAttribute("bedAdmission", bedAdmission);

        if (bedAdmission != null) {
            Bed bed = bedRepository.findById(bedAdmission.getBedId()).orElse(null);
            model.addAttribute("assignedBed", bed);
        }

        // Active ICU admission
        IcuAdmission icuAdmission = icuAdmissionRepository
            .findByStatus("ACTIVE").stream()
            .filter(i -> patientId.equals(i.getPatientId()))
            .findFirst().orElse(null);
        model.addAttribute("icuAdmission", icuAdmission);

        if (icuAdmission != null) {
            Icu icu = icuRepository.findById(icuAdmission.getIcuId()).orElse(null);
            model.addAttribute("assignedIcu", icu);
        }

        // Upcoming OT schedules
        List<OtSchedule> upcomingOt = otScheduleRepository
            .findByPatientId(patientId).stream()
            .filter(o -> "SCHEDULED".equals(o.getStatus()))
            .collect(java.util.stream.Collectors.toList());
        model.addAttribute("upcomingOtSchedules", upcomingOt);

        if (!upcomingOt.isEmpty()) {
            Ot ot = otRepository.findById(upcomingOt.get(0).getOtId()).orElse(null);
            model.addAttribute("scheduledOt", ot);
        }

        // Clinical notes / prescriptions from doctors
        List<PatientNote> notes =
            patientNoteRepository.findByPatientIdOrderByCreatedAtDesc(patientId);
        model.addAttribute("notes", notes);

        java.util.Map<Long, String> noteDoctorNameMap = new java.util.HashMap<>();
        for (PatientNote n : notes) {
            if (!noteDoctorNameMap.containsKey(n.getDoctorId())) {
                doctorRepository.findById(n.getDoctorId())
                    .ifPresent(d -> noteDoctorNameMap.put(n.getDoctorId(), d.getName()));
            }
        }
        model.addAttribute("noteDoctorNameMap", noteDoctorNameMap);

        return "patient/dashboard";
    }
}