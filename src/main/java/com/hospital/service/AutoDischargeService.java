package com.hospital.service;

import com.hospital.model.*;
import com.hospital.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;

@Service
public class AutoDischargeService {
	@Autowired private BedAdmissionRepository bedAdmissionRepository;
    @Autowired private IcuAdmissionRepository icuAdmissionRepository;
    @Autowired private OtScheduleRepository otScheduleRepository;
    @Autowired private BedRepository bedRepository;
    @Autowired private IcuRepository icuRepository;
    @Autowired private OtRepository otRepository;
    @Autowired private MachinePredictionService machinePredictionService;

    // Runs every day at midnight
    @Scheduled(cron = "0 0 0 * * *")
    public void autoDischarge() {
        LocalDate today = LocalDate.now();

        // ── Auto discharge beds ──────────────────────────────
        List<BedAdmission> activeBeds =
            bedAdmissionRepository.findByStatus("ACTIVE");

        for (BedAdmission ba : activeBeds) {
            if (ba.getDischargeDate() != null
                    && !ba.getDischargeDate().isAfter(today)) {
                ba.setStatus("DISCHARGED");
                bedAdmissionRepository.save(ba);

                // Free up the bed
                Bed bed = bedRepository.findById(ba.getBedId()).orElse(null);
                if (bed != null) {
                    bed.setStatus("AVAILABLE");
                    bedRepository.save(bed);
                }
                System.out.println("Auto-discharged bed admission ID: " + ba.getId());
            }
        }

        // ── Auto discharge ICU ───────────────────────────────
        List<IcuAdmission> activeIcus =
            icuAdmissionRepository.findByStatus("ACTIVE");

        for (IcuAdmission ia : activeIcus) {
            if (ia.getDischargeDate() != null
                    && !ia.getDischargeDate().isAfter(today)) {
                ia.setStatus("DISCHARGED");
                icuAdmissionRepository.save(ia);

                // Free up the ICU unit
                Icu icu = icuRepository.findById(ia.getIcuId()).orElse(null);
                if (icu != null) {
                    icu.setStatus("AVAILABLE");
                    icuRepository.save(icu);
                }
                System.out.println("Auto-discharged ICU admission ID: " + ia.getId());
            }
        }

        // ── Auto complete past OT schedules ──────────────────
        List<OtSchedule> scheduledOts =
            otScheduleRepository.findByStatus("SCHEDULED");

        for (OtSchedule os : scheduledOts) {
            if (os.getScheduleDate() != null
                    && os.getScheduleDate().isBefore(today)) {
                os.setStatus("COMPLETED");
                otScheduleRepository.save(os);

                // Free up the OT
                Ot ot = otRepository.findById(os.getOtId()).orElse(null);
                if (ot != null) {
                    ot.setStatus("AVAILABLE");
                    otRepository.save(ot);
                }
                System.out.println("Auto-completed OT schedule ID: " + os.getId());
            }
        }
    }

    // Also runs on every app startup to catch any missed discharges
    @Scheduled(initialDelay = 5000, fixedDelay = Long.MAX_VALUE)
    public void autoDischargeOnStartup() {
        System.out.println("Running startup discharge check...");
        autoDischarge();
    }
 // Auto simulate equipment readings every 6 hours
    @Scheduled(fixedRate = 21600000) // 6 hours in milliseconds
    public void autoSimulateEquipment() {
        machinePredictionService.simulateAndPredict("X_RAY", 1);
        machinePredictionService.simulateAndPredict("CT_SCAN", 1);
        machinePredictionService.simulateAndPredict("MRI", 1);
        System.out.println("Auto simulated equipment readings.");
    }
}
