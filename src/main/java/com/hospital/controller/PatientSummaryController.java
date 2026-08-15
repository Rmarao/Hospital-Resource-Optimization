package com.hospital.controller;

import com.hospital.model.*;
import com.hospital.repository.*;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
public class PatientSummaryController {

    @Autowired private PatientRepository patientRepository;
    @Autowired private DoctorRepository doctorRepository;
    @Autowired private DoctorPatientRepository doctorPatientRepository;
    @Autowired private BedAdmissionRepository bedAdmissionRepository;
    @Autowired private IcuAdmissionRepository icuAdmissionRepository;
    @Autowired private OtScheduleRepository otScheduleRepository;
    @Autowired private PatientNoteRepository patientNoteRepository;
    @Autowired private BedRepository bedRepository;
    @Autowired private IcuRepository icuRepository;

    @GetMapping("/patient/summary")
    public String summaryPage(HttpSession session, Model model) {
        Long patientId = (Long) session.getAttribute("loggedInId");
        Patient patient = patientRepository.findById(patientId).orElse(null);
        model.addAttribute("patient", patient);

        DoctorPatient assignment = doctorPatientRepository.findByPatientIdAndStatus(patientId, "ACTIVE");
        Doctor assignedDoctor = assignment != null
            ? doctorRepository.findById(assignment.getDoctorId()).orElse(null) : null;
        model.addAttribute("assignedDoctor", assignedDoctor);

        List<BedAdmission> bedAdmissions = bedAdmissionRepository.findByPatientId(patientId);
        List<IcuAdmission> icuAdmissions = icuAdmissionRepository.findByPatientId(patientId);
        List<OtSchedule> otSchedules = otScheduleRepository.findByPatientId(patientId);
        List<PatientNote> notes = patientNoteRepository.findByPatientIdOrderByCreatedAtDesc(patientId);

        model.addAttribute("bedAdmissions", bedAdmissions);
        model.addAttribute("icuAdmissions", icuAdmissions);
        model.addAttribute("otSchedules", otSchedules);
        model.addAttribute("notes", notes);

        // Doctor name lookup for anything referenced across the history (admissions, notes)
        java.util.Set<Long> doctorIds = new java.util.HashSet<>();
        bedAdmissions.forEach(b -> doctorIds.add(b.getDoctorId()));
        icuAdmissions.forEach(i -> doctorIds.add(i.getDoctorId()));
        otSchedules.forEach(o -> doctorIds.add(o.getDoctorId()));
        notes.forEach(n -> doctorIds.add(n.getDoctorId()));
        Map<Long, String> doctorNameMap = new HashMap<>();
        for (Doctor d : doctorRepository.findAllById(doctorIds)) {
            doctorNameMap.put(d.getId(), d.getName());
        }
        model.addAttribute("doctorNameMap", doctorNameMap);

        // Bed/ICU number lookups
        Map<Integer, Bed> bedMap = bedRepository.findAll().stream()
            .collect(Collectors.toMap(b -> b.getId(), b -> b));
        Map<Integer, Icu> icuMap = icuRepository.findAll().stream()
            .collect(Collectors.toMap(i -> i.getId(), i -> i));
        model.addAttribute("bedMap", bedMap);
        model.addAttribute("icuMap", icuMap);

        return "patient/summary";
    }
}
