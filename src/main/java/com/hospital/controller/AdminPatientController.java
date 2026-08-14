package com.hospital.controller;

import com.hospital.model.*;
import com.hospital.repository.*;
import com.hospital.util.Csv;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.GetMapping;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.hospital.repository.PatientRecommendationRepository;
import com.hospital.service.LLMAnalysisService;
import com.hospital.service.AuditLogService;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;
import java.io.PrintWriter;
import java.util.Map;
import java.util.HashMap;
import java.time.LocalDate;
import java.util.List;
import java.util.Locale;

@Controller
@RequestMapping("/admin")
public class AdminPatientController {

    @Autowired private PatientRepository patientRepository;
    @Autowired private DoctorRepository doctorRepository;
    @Autowired private DoctorPatientRepository doctorPatientRepository;
    @Autowired private BedRepository bedRepository;
    @Autowired private IcuRepository icuRepository;
    @Autowired private OtRepository otRepository;
    @Autowired private BedAdmissionRepository bedAdmissionRepository;
    @Autowired private IcuAdmissionRepository icuAdmissionRepository;
    @Autowired private OtScheduleRepository otScheduleRepository;
    @Autowired private LLMAnalysisService llmAnalysisService;
    @Autowired private PatientRecommendationRepository recommendationRepository;
    @Autowired private AuditLogService auditLogService;

    // ─── PATIENTS PAGE ────────────────────────────────────────

    @GetMapping("/patients")
    public String patientsPage(
            @RequestParam(required = false) String q,
            HttpSession session, Model model) {

        List<Patient> patients = patientRepository.findAll();
        if (q != null && !q.isBlank()) {
            String needle = q.trim().toLowerCase(Locale.ROOT);
            patients = patients.stream().filter(p -> matches(p, needle)).toList();
        }
        List<Doctor> doctors = doctorRepository.findAll();
        List<DoctorPatient> assignments = doctorPatientRepository.findAll();

        // ✅ Build recommendation map for each patient
        Map<Long, PatientRecommendation> recommendationMap =
            new HashMap<>();
        for (Patient p : patients) {
            recommendationRepository
                .findTopByPatientIdOrderByCreatedAtDesc(p.getId())
                .ifPresent(rec -> recommendationMap.put(p.getId(), rec));
        }

        model.addAttribute("patients", patients);
        model.addAttribute("doctors", doctors);
        model.addAttribute("totalPatients", patientRepository.count());
        model.addAttribute("assignments", assignments);
        model.addAttribute("recommendationMap", recommendationMap);
        model.addAttribute("q", q);

        return "admin/patients";
    }

    private boolean matches(Patient p, String needle) {
        return containsIgnoreCase(p.getName(), needle)
            || containsIgnoreCase(p.getEmail(), needle)
            || containsIgnoreCase(p.getPhone(), needle)
            || containsIgnoreCase(p.getGender(), needle)
            || containsIgnoreCase(p.getBloodGroup(), needle);
    }

    private boolean containsIgnoreCase(String haystack, String needle) {
        return haystack != null && haystack.toLowerCase(Locale.ROOT).contains(needle);
    }

    @GetMapping("/patients/export.csv")
    public void exportPatientsCsv(
            @RequestParam(required = false) String q,
            HttpSession session, HttpServletResponse response) throws java.io.IOException {
        List<Patient> patients = patientRepository.findAll();
        if (q != null && !q.isBlank()) {
            String needle = q.trim().toLowerCase(Locale.ROOT);
            patients = patients.stream().filter(p -> matches(p, needle)).toList();
        }

        response.setContentType("text/csv");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"patients.csv\"");

        // Medical history is left out of the export — it's sensitive PHI that
        // doesn't belong in an unencrypted bulk-download file.
        PrintWriter writer = response.getWriter();
        writer.println("ID,Name,Email,Phone,Age,Gender,Blood Group,Address,Emergency Contact");
        for (Patient p : patients) {
            writer.println(String.join(",",
                Csv.field(p.getId()),
                Csv.field(p.getName()),
                Csv.field(p.getEmail()),
                Csv.field(p.getPhone()),
                Csv.field(p.getAge()),
                Csv.field(p.getGender()),
                Csv.field(p.getBloodGroup()),
                Csv.field(p.getAddress()),
                Csv.field(p.getEmergencyContact())));
        }
        writer.flush();

        auditLogService.record(session, "EXPORT", "Patient", null, "CSV export, " + patients.size() + " rows");
    }

    // ─── ASSIGN DOCTOR TO PATIENT ─────────────────────────────

    @PostMapping("/patients/assign-doctor")
    public String assignDoctor(@RequestParam Long patientId,
                               @RequestParam Long doctorId,
                               HttpSession session) {

        // Check if already assigned
        boolean exists = doctorPatientRepository
            .existsByDoctorIdAndPatientIdAndStatus(doctorId, patientId, "ACTIVE");
        if (exists) {
            return "redirect:/admin/patients?error=alreadyassigned";
        }

        // Deactivate any existing assignment for this patient
        DoctorPatient existing = doctorPatientRepository
            .findByPatientIdAndStatus(patientId, "ACTIVE");
        if (existing != null) {
            existing.setStatus("INACTIVE");
            doctorPatientRepository.save(existing);
        }

        // Create new assignment
        DoctorPatient assignment = new DoctorPatient();
        assignment.setPatientId(patientId);
        assignment.setDoctorId(doctorId);
        assignment.setStatus("ACTIVE");
        doctorPatientRepository.save(assignment);
        auditLogService.record(session, "ASSIGN_DOCTOR", "Patient", patientId, "doctorId=" + doctorId);

        return "redirect:/admin/patients?success=Doctor assigned successfully";
    }

    // ─── REMOVE DOCTOR ASSIGNMENT ─────────────────────────────

    @PostMapping("/patients/remove-doctor")
    public String removeDoctor(@RequestParam Long patientId, HttpSession session) {

        DoctorPatient existing = doctorPatientRepository
            .findByPatientIdAndStatus(patientId, "ACTIVE");
        if (existing != null) {
            existing.setStatus("INACTIVE");
            doctorPatientRepository.save(existing);
        }
        auditLogService.record(session, "REMOVE_DOCTOR", "Patient", patientId, null);
        return "redirect:/admin/patients?success=Doctor assignment removed";
    }

    // ─── SCHEDULE PAGE ────────────────────────────────────────

    @GetMapping("/schedule")
    public String schedulePage(HttpSession session, Model model) {

        model.addAttribute("patients", patientRepository.findAll());
        model.addAttribute("doctors", doctorRepository.findAll());

        // ✅ Show ALL beds/ICUs not just available ones
        // Date conflict check handles availability
        model.addAttribute("availableBeds", bedRepository.findAll());
        model.addAttribute("availableIcus", icuRepository.findAll());
        model.addAttribute("availableOts", otRepository.findByStatus("AVAILABLE"));

        model.addAttribute("bedAdmissions",
            bedAdmissionRepository.findByStatus("ACTIVE"));
        model.addAttribute("icuAdmissions",
            icuAdmissionRepository.findByStatus("ACTIVE"));
        model.addAttribute("otSchedules",
            otScheduleRepository.findByStatus("SCHEDULED"));

        return "admin/schedule";
    }

    // ─── ASSIGN BED ───────────────────────────────────────────

    @PostMapping("/schedule/assign-bed")
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public String assignBed(@RequestParam Long patientId,
                            @RequestParam Long doctorId,
                            @RequestParam Integer bedId,
                            @RequestParam String admittedDate,
                            @RequestParam String dischargeDate,
                            HttpSession session) {

        LocalDate admitted = LocalDate.parse(admittedDate);
        LocalDate discharge = LocalDate.parse(dischargeDate);

        // ✅ Check 1: discharge must be after admission
        if (!discharge.isAfter(admitted)) {
            return "redirect:/admin/schedule?tab=bed&error=invaliddates";
        }

        // ✅ Check 2: date overlap check
        List<BedAdmission> overlapping = bedAdmissionRepository
            .findOverlappingBedBookings(bedId, admitted, discharge);
        if (!overlapping.isEmpty()) {
            return "redirect:/admin/schedule?tab=bed&error=bedbooked";
        }

        // All good — save
        Bed bed = bedRepository.findById(bedId).orElse(null);
        if (bed == null) {
            return "redirect:/admin/schedule?tab=bed&error=bednotfound";
        }
        bed.setStatus("OCCUPIED");
        bedRepository.save(bed);

        BedAdmission admission = new BedAdmission();
        admission.setBedId(bedId);
        admission.setPatientId(patientId);
        admission.setDoctorId(doctorId);
        admission.setAdmittedDate(admitted);
        admission.setDischargeDate(discharge);
        admission.setStatus("ACTIVE");
        bedAdmissionRepository.save(admission);
        auditLogService.record(session, "ASSIGN_BED", "Patient", patientId, "bedId=" + bedId);

        return "redirect:/admin/schedule?tab=bed&success=Bed assigned successfully";
    }

    // ─── RELEASE BED ──────────────────────────────────────────

    @PostMapping("/schedule/release-bed")
    public String releaseBed(@RequestParam Integer admissionId, HttpSession session) {

        BedAdmission admission = bedAdmissionRepository.findById(admissionId).orElse(null);
        if (admission != null) {
            admission.setStatus("DISCHARGED");
            bedAdmissionRepository.save(admission);

            Bed bed = bedRepository.findById(admission.getBedId()).orElse(null);
            if (bed != null) {
                bed.setStatus("AVAILABLE");
                bedRepository.save(bed);
            }
            auditLogService.record(session, "RELEASE_BED", "Patient", admission.getPatientId(), "admissionId=" + admissionId);
        }
        return "redirect:/admin/schedule?tab=bed&success=Patient discharged successfully";
    }

    // ─── ADMIT TO ICU ─────────────────────────────────────────

    @PostMapping("/schedule/assign-icu")
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public String assignIcu(@RequestParam Long patientId,
                            @RequestParam Long doctorId,
                            @RequestParam Integer icuId,
                            @RequestParam String admittedDate,
                            @RequestParam String dischargeDate,
                            HttpSession session) {

        LocalDate admitted = LocalDate.parse(admittedDate);
        LocalDate discharge = LocalDate.parse(dischargeDate);

        // ✅ Check 1: discharge must be after admission
        if (!discharge.isAfter(admitted)) {
            return "redirect:/admin/schedule?tab=icu&error=invaliddates";
        }

        // ✅ Check 2: date overlap check
        List<IcuAdmission> overlapping = icuAdmissionRepository
            .findOverlappingIcuBookings(icuId, admitted, discharge);
        if (!overlapping.isEmpty()) {
            return "redirect:/admin/schedule?tab=icu&error=icubooked";
        }

        Icu icu = icuRepository.findById(icuId).orElse(null);
        if (icu == null) {
            return "redirect:/admin/schedule?tab=icu&error=icunotfound";
        }
        icu.setStatus("OCCUPIED");
        icuRepository.save(icu);

        IcuAdmission admission = new IcuAdmission();
        admission.setIcuId(icuId);
        admission.setPatientId(patientId);
        admission.setDoctorId(doctorId);
        admission.setAdmittedDate(admitted);
        admission.setDischargeDate(discharge);
        admission.setStatus("ACTIVE");
        icuAdmissionRepository.save(admission);
        auditLogService.record(session, "ASSIGN_ICU", "Patient", patientId, "icuId=" + icuId);

        return "redirect:/admin/schedule?tab=icu&success=Patient admitted to ICU successfully";
    }

    // ─── RELEASE ICU ──────────────────────────────────────────

    @PostMapping("/schedule/release-icu")
    public String releaseIcu(@RequestParam Integer admissionId, HttpSession session) {

        IcuAdmission admission = icuAdmissionRepository.findById(admissionId).orElse(null);
        if (admission != null) {
            admission.setStatus("DISCHARGED");
            icuAdmissionRepository.save(admission);

            Icu icu = icuRepository.findById(admission.getIcuId()).orElse(null);
            if (icu != null) {
                icu.setStatus("AVAILABLE");
                icuRepository.save(icu);
            }
            auditLogService.record(session, "RELEASE_ICU", "Patient", admission.getPatientId(), "admissionId=" + admissionId);
        }
        return "redirect:/admin/schedule?tab=icu&success=Patient discharged from ICU";
    }

    // ─── SCHEDULE OT ──────────────────────────────────────────

    @PostMapping("/schedule/assign-ot")
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public String assignOt(@RequestParam Long patientId,
                           @RequestParam Long doctorId,
                           @RequestParam Integer otId,
                           @RequestParam String procedureName,
                           @RequestParam String scheduleDate,
                           @RequestParam String startTime,
                           @RequestParam String endTime,
                           HttpSession session) {


        LocalDate date = LocalDate.parse(scheduleDate);
        java.time.LocalTime start = java.time.LocalTime.parse(startTime);
        java.time.LocalTime end = java.time.LocalTime.parse(endTime);

        // ✅ Check 1: end time must be after start time
        if (!end.isAfter(start)) {
            return "redirect:/admin/schedule?tab=ot&error=invalidtime";
        }

        // ✅ Check 2: OT conflict — same OT, overlapping time
        List<OtSchedule> otConflicts = otScheduleRepository
            .findConflictingSchedules(otId, date, start, end);
        if (!otConflicts.isEmpty()) {
            return "redirect:/admin/schedule?tab=ot&error=otconflict";
        }

        // ✅ Check 3: Doctor conflict — same doctor, overlapping time
        List<OtSchedule> doctorConflicts = otScheduleRepository
            .findDoctorConflicts(doctorId, date, start, end);
        if (!doctorConflicts.isEmpty()) {
            return "redirect:/admin/schedule?tab=ot&error=doctorconflict";
        }

        // ✅ Check 4: Can't schedule in the past
        if (date.isBefore(LocalDate.now())) {
            return "redirect:/admin/schedule?tab=ot&error=pastdate";
        }

        // All checks passed — save schedule
        Ot ot = otRepository.findById(otId).orElse(null);
        if (ot == null) {
            return "redirect:/admin/schedule?tab=ot&error=otnotfound";
        }
        ot.setStatus("OCCUPIED");
        otRepository.save(ot);

        OtSchedule schedule = new OtSchedule();
        schedule.setOtId(otId);
        schedule.setPatientId(patientId);
        schedule.setDoctorId(doctorId);
        schedule.setProcedureName(procedureName);
        schedule.setScheduleDate(date);
        schedule.setStartTime(start);
        schedule.setEndTime(end);
        schedule.setStatus("SCHEDULED");
        otScheduleRepository.save(schedule);
        auditLogService.record(session, "ASSIGN_OT", "Patient", patientId, "otId=" + otId + ", procedure=" + procedureName);

        return "redirect:/admin/schedule?tab=ot&success=OT scheduled successfully";
    }

    // ─── COMPLETE / CANCEL OT ─────────────────────────────────

    @PostMapping("/schedule/update-ot")
    public String updateOt(@RequestParam Integer scheduleId,
                           @RequestParam String status,
                           HttpSession session) {

        OtSchedule schedule = otScheduleRepository.findById(scheduleId).orElse(null);
        if (schedule != null) {
            schedule.setStatus(status);
            otScheduleRepository.save(schedule);
            auditLogService.record(session, "UPDATE_OT", "Patient", schedule.getPatientId(), "status=" + status);

            // If completed or cancelled, free up the OT
            if ("COMPLETED".equals(status) || "CANCELLED".equals(status)) {
                Ot ot = otRepository.findById(schedule.getOtId()).orElse(null);
                if (ot != null) {
                    ot.setStatus("AVAILABLE");
                    otRepository.save(ot);
                }
            }
        }
        return "redirect:/admin/schedule?tab=ot";
    }
    
 // ── Analyse patient with LLM ──────────────────────────────────

    @PostMapping("/patients/analyse")
    public String analysePatient(
            @RequestParam Long patientId,
            HttpSession session) {

        Patient patient = patientRepository.findById(patientId)
            .orElse(null);
        if (patient == null) {
            return "redirect:/admin/patients?error=patientnotfound";
        }
        llmAnalysisService.analysePatient(patient);
        auditLogService.record(session, "ANALYSE", "Patient", patientId, "AI triage analysis run");
        return "redirect:/admin/patients?success=Patient analysed successfully";
    }

    // ── Auto assign doctor ────────────────────────────────────────

    @PostMapping("/patients/auto-assign-doctor")
    public String autoAssignDoctor(
            @RequestParam Long patientId,
            HttpSession session) {

        // Get latest recommendation
        PatientRecommendation rec = recommendationRepository
            .findTopByPatientIdOrderByCreatedAtDesc(patientId)
            .orElse(null);

        if (rec == null) {
            return "redirect:/admin/patients?error=noanalysis";
        }

        // Get best doctor
        Map<String, Object> result =
            llmAnalysisService.autoAssignDoctor(patientId, rec);

        if (!(boolean) result.get("success")) {
            return "redirect:/admin/patients?error=nodoctoravailable";
        }

        Doctor doctor = (Doctor) result.get("doctor");

        // Check if already assigned
        DoctorPatient existing = doctorPatientRepository
            .findByPatientIdAndStatus(patientId, "ACTIVE");
        if (existing != null) {
            existing.setStatus("INACTIVE");
            doctorPatientRepository.save(existing);
        }

        // Create new assignment
        DoctorPatient assignment = new DoctorPatient();
        assignment.setPatientId(patientId);
        assignment.setDoctorId(doctor.getId());
        assignment.setStatus("ACTIVE");
        doctorPatientRepository.save(assignment);

        // Update recommendation status
        rec.setStatus("ASSIGNED");
        recommendationRepository.save(rec);
        auditLogService.record(session, "AUTO_ASSIGN_DOCTOR", "Patient", patientId, "doctorId=" + doctor.getId());

        return "redirect:/admin/patients?success=Doctor auto-assigned: Dr. "
            + doctor.getName();
    }
 // ── Auto allocate resources for a patient ─────────────────────

    @PostMapping("/schedule/auto-allocate")
    public String autoAllocate(
            @RequestParam Long patientId,
            HttpSession session) {

        // Get recommendation
        PatientRecommendation rec = recommendationRepository
            .findTopByPatientIdOrderByCreatedAtDesc(patientId)
            .orElse(null);

        if (rec == null) {
            return "redirect:/admin/schedule?error=noanalysis";
        }

        Map<String, Object> resources =
            llmAnalysisService.getResourceRecommendation(rec);

        boolean needsBed = (boolean) resources.get("needsBed");
        boolean needsICU = (boolean) resources.get("needsICU");
        boolean needsOT  = (boolean) resources.get("needsOT");

        // Get assigned doctor
        DoctorPatient dp = doctorPatientRepository
            .findByPatientIdAndStatus(patientId, "ACTIVE");
        Long doctorId = dp != null ? dp.getDoctorId() : null;

        StringBuilder allocated = new StringBuilder();

        // Auto assign bed
        if (needsBed) {
            List<Bed> availableBeds = bedRepository
                .findByStatus("AVAILABLE");
            if (!availableBeds.isEmpty() && doctorId != null) {
                Bed bed = availableBeds.get(0);
                bed.setStatus("OCCUPIED");
                bedRepository.save(bed);

                BedAdmission admission = new BedAdmission();
                admission.setBedId(bed.getId());
                admission.setPatientId(patientId);
                admission.setDoctorId(doctorId);
                admission.setAdmittedDate(LocalDate.now());
                admission.setDischargeDate(
                    LocalDate.now().plusDays(
                        rec.getSeverityScore() >= 7 ? 7 : 3));
                admission.setStatus("ACTIVE");
                bedAdmissionRepository.save(admission);
                auditLogService.record(session, "AUTO_ASSIGN_BED", "Patient", patientId, "bedId=" + bed.getId());
                allocated.append("Bed " + bed.getBedNumber() + " ");
            }
        }

        // Auto assign ICU
        if (needsICU) {
            List<Icu> availableIcus = icuRepository
                .findByStatus("AVAILABLE");
            if (!availableIcus.isEmpty() && doctorId != null) {
                Icu icu = availableIcus.get(0);
                icu.setStatus("OCCUPIED");
                icuRepository.save(icu);

                IcuAdmission admission = new IcuAdmission();
                admission.setIcuId(icu.getId());
                admission.setPatientId(patientId);
                admission.setDoctorId(doctorId);
                admission.setAdmittedDate(LocalDate.now());
                admission.setDischargeDate(
                    LocalDate.now().plusDays(5));
                admission.setStatus("ACTIVE");
                icuAdmissionRepository.save(admission);
                auditLogService.record(session, "AUTO_ASSIGN_ICU", "Patient", patientId, "icuId=" + icu.getId());
                allocated.append("ICU #" + icu.getId() + " ");
            }
        }

        // Auto assign OT
        if (needsOT) {
            List<Ot> availableOts = otRepository.findByStatus("AVAILABLE");
            if (!availableOts.isEmpty() && doctorId != null) {
                Ot ot = availableOts.get(0);
                ot.setStatus("OCCUPIED");
                otRepository.save(ot);

                OtSchedule schedule = new OtSchedule();
                schedule.setOtId(ot.getId());
                schedule.setPatientId(patientId);
                schedule.setDoctorId(doctorId);
                schedule.setProcedureName(
                    (rec.getDepartment() != null ? rec.getDepartment().replace("_", " ") : "General") + " Procedure");
                schedule.setScheduleDate(LocalDate.now().plusDays(1));
                schedule.setStartTime(java.time.LocalTime.of(9, 0));
                schedule.setEndTime(java.time.LocalTime.of(10, 0));
                schedule.setStatus("SCHEDULED");
                otScheduleRepository.save(schedule);
                auditLogService.record(session, "AUTO_ASSIGN_OT", "Patient", patientId, "otId=" + ot.getId());
                allocated.append("OT-" + ot.getId() + " ");
            }
        }

        if (allocated.length() == 0) {
            return "redirect:/admin/schedule?error=noavailableresources";
        }

        return "redirect:/admin/schedule?success=Auto allocated: "
            + allocated.toString().trim();
    }
}