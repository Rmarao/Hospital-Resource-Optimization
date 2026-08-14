package com.hospital.controller;

import com.hospital.model.Doctor;
import com.hospital.repository.DoctorAvailabilityRepository;
import com.hospital.repository.DoctorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin")
public class AdminAvailabilityController {

    @Autowired private DoctorRepository doctorRepository;
    @Autowired private DoctorAvailabilityRepository availabilityRepository;

    @GetMapping("/availability")
    public String availabilityCalendar(Model model) {
        List<Doctor> doctors = doctorRepository.findAll();

        // doctorId -> (day -> available)
        Map<Long, Map<String, Boolean>> grid = new LinkedHashMap<>();
        for (Doctor d : doctors) {
            grid.put(d.getId(), DoctorAvailabilityController.availabilityForDoctor(d.getId(), availabilityRepository));
        }

        model.addAttribute("doctors", doctors);
        model.addAttribute("grid", grid);
        model.addAttribute("days", DoctorAvailabilityController.DAYS);
        return "admin/availability";
    }
}
