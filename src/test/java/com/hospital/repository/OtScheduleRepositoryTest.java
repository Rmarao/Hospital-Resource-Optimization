package com.hospital.repository;

import com.hospital.model.OtSchedule;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@DataJpaTest
class OtScheduleRepositoryTest {

    @Autowired private OtScheduleRepository otScheduleRepository;

    private void seedScheduledProcedure() {
        OtSchedule existing = new OtSchedule();
        existing.setOtId(1);
        existing.setPatientId(100L);
        existing.setDoctorId(5L);
        existing.setProcedureName("Appendectomy");
        existing.setScheduleDate(LocalDate.of(2026, 3, 1));
        existing.setStartTime(LocalTime.of(9, 0));
        existing.setEndTime(LocalTime.of(11, 0));
        existing.setStatus("SCHEDULED");
        otScheduleRepository.save(existing);
    }

    @Test
    void detectsOtTimeConflictOnTheSameOt() {
        seedScheduledProcedure();

        List<OtSchedule> conflicts = otScheduleRepository.findConflictingSchedules(
            1, LocalDate.of(2026, 3, 1), LocalTime.of(10, 0), LocalTime.of(12, 0));

        assertEquals(1, conflicts.size());
    }

    @Test
    void noOtConflictForADifferentOt() {
        seedScheduledProcedure();

        List<OtSchedule> conflicts = otScheduleRepository.findConflictingSchedules(
            2, LocalDate.of(2026, 3, 1), LocalTime.of(10, 0), LocalTime.of(12, 0));

        assertTrue(conflicts.isEmpty());
    }

    @Test
    void detectsDoctorDoubleBookingAcrossDifferentOts() {
        seedScheduledProcedure();

        // same doctor, overlapping time, but a DIFFERENT OT — this is exactly
        // the case findDoctorConflicts exists to catch that findConflictingSchedules alone would miss
        List<OtSchedule> doctorConflicts = otScheduleRepository.findDoctorConflicts(
            5L, LocalDate.of(2026, 3, 1), LocalTime.of(10, 0), LocalTime.of(12, 0));

        assertEquals(1, doctorConflicts.size());
    }

    @Test
    void noConflictForNonOverlappingTime() {
        seedScheduledProcedure();

        List<OtSchedule> conflicts = otScheduleRepository.findConflictingSchedules(
            1, LocalDate.of(2026, 3, 1), LocalTime.of(12, 0), LocalTime.of(13, 0));

        assertTrue(conflicts.isEmpty());
    }
}
