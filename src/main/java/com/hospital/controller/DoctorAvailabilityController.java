package com.hospital.controller;

import com.hospital.model.DoctorAvailability;
import com.hospital.repository.DoctorAvailabilityRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Controller
public class DoctorAvailabilityController {

    static final List<String> DAYS = List.of(
        "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY");

    @Autowired private DoctorAvailabilityRepository availabilityRepository;

    @GetMapping("/doctor/availability")
    public String availabilityPage(HttpSession session, Model model) {
        Long doctorId = (Long) session.getAttribute("loggedInId");
        model.addAttribute("availability", availabilityForDoctor(doctorId));
        return "doctor/availability";
    }

    @PostMapping("/doctor/availability/update")
    public String updateAvailability(
            @RequestParam String dayOfWeek,
            @RequestParam boolean available,
            HttpSession session) {
        Long doctorId = (Long) session.getAttribute("loggedInId");
        if (!DAYS.contains(dayOfWeek)) {
            return "redirect:/doctor/availability?error=invalidday";
        }
        DoctorAvailability entry = availabilityRepository
            .findByDoctorIdAndDayOfWeek(doctorId, dayOfWeek)
            .orElseGet(() -> {
                DoctorAvailability a = new DoctorAvailability();
                a.setDoctorId(doctorId);
                a.setDayOfWeek(dayOfWeek);
                return a;
            });
        entry.setAvailable(available);
        availabilityRepository.save(entry);
        return "redirect:/doctor/availability?success=Availability updated";
    }

    /** Days default to available until the doctor explicitly turns one off. */
    static Map<String, Boolean> availabilityForDoctor(Long doctorId, DoctorAvailabilityRepository repo) {
        Map<String, Boolean> byDay = new LinkedHashMap<>();
        for (String day : DAYS) byDay.put(day, true);
        for (DoctorAvailability a : repo.findByDoctorId(doctorId)) {
            byDay.put(a.getDayOfWeek(), a.isAvailable());
        }
        return byDay;
    }

    private Map<String, Boolean> availabilityForDoctor(Long doctorId) {
        return availabilityForDoctor(doctorId, availabilityRepository);
    }
}
