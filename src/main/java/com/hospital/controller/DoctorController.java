package com.hospital.controller;

import com.hospital.model.*;
import com.hospital.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/doctor")
@Validated
public class DoctorController {

    @Autowired private DoctorPatientRepository doctorPatientRepository;
    @Autowired private PatientRepository patientRepository;
    @Autowired private BedAdmissionRepository bedAdmissionRepository;
    @Autowired private IcuAdmissionRepository icuAdmissionRepository;
    @Autowired private OtScheduleRepository otScheduleRepository;
    @Autowired private BedRepository bedRepository;
    @Autowired private IcuRepository icuRepository;
    @Autowired private PatientNoteRepository patientNoteRepository;
    @Autowired private OtRepository otRepository;
    @Autowired private AppointmentRequestRepository appointmentRequestRepository;
    @Autowired private com.hospital.service.AuditLogService auditLogService;

    @GetMapping("/patients")
    public String patientsPage(HttpSession session, Model model) {

        Long doctorId = (Long) session.getAttribute("loggedInId");

        // Get all active assigned patients
        List<DoctorPatient> assignments = doctorPatientRepository
            .findByDoctorId(doctorId).stream()
            .filter(a -> "ACTIVE".equals(a.getStatus()))
            .collect(Collectors.toList());

        // Fetch full patient details in one batched query instead of N findById calls
        List<Long> assignedPatientIds = assignments.stream()
            .map(DoctorPatient::getPatientId)
            .collect(Collectors.toList());
        List<Patient> patients = patientRepository.findAllById(assignedPatientIds);

        // Bed admissions for this doctor
        Map<Long, BedAdmission> patientBedMap = new HashMap<>();
        List<BedAdmission> bedAdmissions = bedAdmissionRepository
            .findByDoctorId(doctorId).stream()
            .filter(b -> "ACTIVE".equals(b.getStatus()))
            .collect(Collectors.toList());
        for (BedAdmission ba : bedAdmissions) {
            patientBedMap.put(ba.getPatientId(), ba);
        }

        // ICU admissions for this doctor
        Map<Long, IcuAdmission> patientIcuMap = new HashMap<>();
        List<IcuAdmission> icuAdmissions = icuAdmissionRepository
            .findByDoctorId(doctorId).stream()
            .filter(i -> "ACTIVE".equals(i.getStatus()))
            .collect(Collectors.toList());
        for (IcuAdmission ia : icuAdmissions) {
            patientIcuMap.put(ia.getPatientId(), ia);
        }

        // OT schedules for all patients in one batched query instead of N findByPatientId calls
        Map<Long, List<OtSchedule>> patientOtMap = new HashMap<>();
        for (Patient p : patients) {
            patientOtMap.put(p.getId(), new ArrayList<>());
        }
        for (OtSchedule os : otScheduleRepository.findByPatientIdInAndStatus(assignedPatientIds, "SCHEDULED")) {
            patientOtMap.get(os.getPatientId()).add(os);
        }

        // Bed details map
        Map<Integer, Bed> bedMap = new HashMap<>();
        for (Bed b : bedRepository.findAll()) {
            bedMap.put(b.getId(), b);
        }

        // ICU details map
        Map<Integer, Icu> icuMap = new HashMap<>();
        for (Icu i : icuRepository.findAll()) {
            icuMap.put(i.getId(), i);
        }

        model.addAttribute("patients", patients);
        model.addAttribute("patientBedMap", patientBedMap);
        model.addAttribute("patientIcuMap", patientIcuMap);
        model.addAttribute("patientOtMap", patientOtMap);
        model.addAttribute("bedMap", bedMap);
        model.addAttribute("icuMap", icuMap);
        model.addAttribute("totalPatients", patients.size());

        // Clinical notes / prescriptions per patient
        Map<Long, List<PatientNote>> patientNotesMap = new HashMap<>();
        for (Patient p : patients) {
            patientNotesMap.put(p.getId(),
                patientNoteRepository.findByPatientIdOrderByCreatedAtDesc(p.getId()));
        }
        model.addAttribute("patientNotesMap", patientNotesMap);
        model.addAttribute("availableOts", otRepository.findByStatus("AVAILABLE"));

        return "doctor/patients";
    }

    // ── Doctor-created OT booking ──────────────────────────────

    @PostMapping("/patients/book-ot")
    @org.springframework.transaction.annotation.Transactional(
        isolation = org.springframework.transaction.annotation.Isolation.SERIALIZABLE)
    public String bookOt(
            @RequestParam Long patientId,
            @RequestParam Integer otId,
            @RequestParam @NotBlank String procedureName,
            @RequestParam String scheduleDate,
            @RequestParam String startTime,
            @RequestParam String endTime,
            HttpSession session) {

        Long doctorId = (Long) session.getAttribute("loggedInId");

        boolean isAssigned = doctorPatientRepository
            .existsByDoctorIdAndPatientIdAndStatus(doctorId, patientId, "ACTIVE");
        if (!isAssigned) {
            return "redirect:/doctor/patients?error=notassigned";
        }

        LocalDate date = LocalDate.parse(scheduleDate);
        java.time.LocalTime start = java.time.LocalTime.parse(startTime);
        java.time.LocalTime end = java.time.LocalTime.parse(endTime);

        if (!end.isAfter(start)) {
            return "redirect:/doctor/patients?error=invalidtime";
        }
        if (date.isBefore(LocalDate.now())) {
            return "redirect:/doctor/patients?error=pastdate";
        }

        List<OtSchedule> otConflicts = otScheduleRepository
            .findConflictingSchedules(otId, date, start, end);
        if (!otConflicts.isEmpty()) {
            return "redirect:/doctor/patients?error=otconflict";
        }

        List<OtSchedule> doctorConflicts = otScheduleRepository
            .findDoctorConflicts(doctorId, date, start, end);
        if (!doctorConflicts.isEmpty()) {
            return "redirect:/doctor/patients?error=doctorconflict";
        }

        Ot ot = otRepository.findById(otId).orElse(null);
        if (ot == null) {
            return "redirect:/doctor/patients?error=otnotfound";
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

        return "redirect:/doctor/patients?success=OT scheduled successfully";
    }

    // ── Add a clinical note / prescription for an assigned patient ────────

    @PostMapping("/patients/add-note")
    public String addNote(
            @RequestParam Long patientId,
            @RequestParam @NotBlank String diagnosis,
            @RequestParam @NotBlank String prescription,
            @RequestParam(required = false) String advice,
            @RequestParam(required = false) String followUpDate,
            HttpSession session) {


        Long doctorId = (Long) session.getAttribute("loggedInId");

        boolean isAssigned = doctorPatientRepository
            .existsByDoctorIdAndPatientIdAndStatus(doctorId, patientId, "ACTIVE");
        if (!isAssigned) {
            return "redirect:/doctor/patients?error=notassigned";
        }

        PatientNote note = new PatientNote();
        note.setPatientId(patientId);
        note.setDoctorId(doctorId);
        note.setDiagnosis(diagnosis);
        note.setPrescription(prescription);
        note.setAdvice(advice);
        if (followUpDate != null && !followUpDate.isBlank()) {
            note.setFollowUpDate(LocalDate.parse(followUpDate));
        }
        patientNoteRepository.save(note);
        auditLogService.record(session, "ADD_NOTE", "Patient", patientId, "diagnosis=" + diagnosis);

        return "redirect:/doctor/patients?success=Note added successfully";
    }

    // ── Doctor-initiated discharge ─────────────────────────────

    @PostMapping("/patients/discharge-bed")
    public String dischargeBed(@RequestParam Integer admissionId, HttpSession session) {
        Long doctorId = (Long) session.getAttribute("loggedInId");

        BedAdmission admission = bedAdmissionRepository.findById(admissionId).orElse(null);
        if (admission == null) {
            return "redirect:/doctor/patients?error=notfound";
        }
        if (!doctorId.equals(admission.getDoctorId())) {
            return "redirect:/doctor/patients?error=notauthorized";
        }

        admission.setStatus("DISCHARGED");
        bedAdmissionRepository.save(admission);

        Bed bed = bedRepository.findById(admission.getBedId()).orElse(null);
        if (bed != null) {
            bed.setStatus("AVAILABLE");
            bedRepository.save(bed);
        }
        auditLogService.record(session, "RELEASE_BED", "Patient", admission.getPatientId(), "admissionId=" + admissionId);

        return "redirect:/doctor/patients?success=Patient discharged successfully";
    }

    @PostMapping("/patients/discharge-icu")
    public String dischargeIcu(@RequestParam Integer admissionId, HttpSession session) {
        Long doctorId = (Long) session.getAttribute("loggedInId");

        IcuAdmission admission = icuAdmissionRepository.findById(admissionId).orElse(null);
        if (admission == null) {
            return "redirect:/doctor/patients?error=notfound";
        }
        if (!doctorId.equals(admission.getDoctorId())) {
            return "redirect:/doctor/patients?error=notauthorized";
        }

        admission.setStatus("DISCHARGED");
        icuAdmissionRepository.save(admission);

        Icu icu = icuRepository.findById(admission.getIcuId()).orElse(null);
        if (icu != null) {
            icu.setStatus("AVAILABLE");
            icuRepository.save(icu);
        }
        auditLogService.record(session, "RELEASE_ICU", "Patient", admission.getPatientId(), "admissionId=" + admissionId);

        return "redirect:/doctor/patients?success=Patient discharged from ICU";
    }

    // ── Appointment / follow-up requests ───────────────────────

    @GetMapping("/appointments")
    public String appointmentsPage(HttpSession session, Model model) {
        Long doctorId = (Long) session.getAttribute("loggedInId");

        List<AppointmentRequest> requests = appointmentRequestRepository
            .findByDoctorIdOrderByCreatedAtDesc(doctorId);

        List<Long> patientIds = requests.stream()
            .map(AppointmentRequest::getPatientId)
            .distinct()
            .collect(Collectors.toList());
        Map<Long, Patient> patientMap = new HashMap<>();
        for (Patient p : patientRepository.findAllById(patientIds)) {
            patientMap.put(p.getId(), p);
        }

        model.addAttribute("requests", requests);
        model.addAttribute("patientMap", patientMap);
        return "doctor/appointments";
    }

    @PostMapping("/appointments/respond")
    public String respondToAppointment(
            @RequestParam Long requestId,
            @RequestParam String decision,
            @RequestParam(required = false) String doctorNote,
            HttpSession session) {

        Long doctorId = (Long) session.getAttribute("loggedInId");

        AppointmentRequest request = appointmentRequestRepository.findById(requestId).orElse(null);
        if (request == null) {
            return "redirect:/doctor/appointments?error=notfound";
        }
        if (!doctorId.equals(request.getDoctorId())) {
            return "redirect:/doctor/appointments?error=notauthorized";
        }
        if (!"APPROVED".equals(decision) && !"REJECTED".equals(decision)) {
            return "redirect:/doctor/appointments?error=invaliddecision";
        }

        request.setStatus(decision);
        request.setDoctorNote(doctorNote);
        request.setRespondedAt(java.time.LocalDateTime.now());
        appointmentRequestRepository.save(request);
        auditLogService.record(session, "UPDATE", "AppointmentRequest", requestId, "status=" + decision);

        return "redirect:/doctor/appointments?success=Request " + decision.toLowerCase() + " successfully";
    }
}