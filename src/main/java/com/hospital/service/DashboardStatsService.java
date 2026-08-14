package com.hospital.service;

import com.hospital.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class DashboardStatsService {

    @Autowired private BedRepository bedRepository;
    @Autowired private IcuRepository icuRepository;
    @Autowired private OtRepository otRepository;
    @Autowired private OxygenTankRepository oxygenTankRepository;
    @Autowired private DoctorRepository doctorRepository;
    @Autowired private PatientRepository patientRepository;

    /**
     * Bundles the admin dashboard's resource-count queries into one
     * 30s-cached call instead of 10 separate COUNT queries on every
     * dashboard load (see CacheConfig).
     */
    @Cacheable("dashboardStats")
    public Map<String, Long> getResourceCounts() {
        Map<String, Long> stats = new HashMap<>();
        stats.put("totalBeds", bedRepository.count());
        stats.put("availableBeds", bedRepository.countByStatus("AVAILABLE"));
        stats.put("occupiedBeds", bedRepository.countByStatus("OCCUPIED"));

        stats.put("totalIcu", icuRepository.count());
        stats.put("availableIcu", icuRepository.countByStatus("AVAILABLE"));
        stats.put("occupiedIcu", icuRepository.countByStatus("OCCUPIED"));

        stats.put("totalOt", otRepository.count());
        stats.put("availableOt", otRepository.countByStatus("AVAILABLE"));

        stats.put("totalOxygen", oxygenTankRepository.count());
        stats.put("availableOxygen", oxygenTankRepository.countByStatus("AVAILABLE"));

        stats.put("totalDoctors", doctorRepository.count());
        stats.put("totalPatients", patientRepository.count());

        return stats;
    }
}
