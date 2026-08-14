package com.hospital.repository;

import com.hospital.model.BedAdmission;
import org.junit.jupiter.api.Test;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Exercises the overlap-detection @Query directly against an in-memory H2
 * database — this is the most business-critical, bug-prone logic in the
 * app (it's what prevents double-booking a bed).
 */
@DataJpaTest
class BedAdmissionRepositoryTest {

    @Autowired private BedAdmissionRepository bedAdmissionRepository;

    private void seedActiveBooking() {
        BedAdmission existing = new BedAdmission();
        existing.setBedId(1);
        existing.setPatientId(100L);
        existing.setDoctorId(1L);
        existing.setAdmittedDate(LocalDate.of(2026, 1, 1));
        existing.setDischargeDate(LocalDate.of(2026, 1, 10));
        existing.setStatus("ACTIVE");
        bedAdmissionRepository.save(existing);
    }

    @Test
    void detectsOverlappingDateRange() {
        seedActiveBooking();

        List<BedAdmission> overlapping = bedAdmissionRepository.findOverlappingBedBookings(
            1, LocalDate.of(2026, 1, 5), LocalDate.of(2026, 1, 15));

        assertEquals(1, overlapping.size());
    }

    @Test
    void detectsPartialOverlapAtTheBoundary() {
        seedActiveBooking();

        // new booking starts the day the existing one ends — still overlapping
        // per the strict-inequality query (admittedDate < dischargeDate AND
        // dischargeDate > admittedDate)
        List<BedAdmission> overlapping = bedAdmissionRepository.findOverlappingBedBookings(
            1, LocalDate.of(2026, 1, 9), LocalDate.of(2026, 1, 20));

        assertEquals(1, overlapping.size());
    }

    @Test
    void noOverlapAfterExistingBookingEnds() {
        seedActiveBooking();

        List<BedAdmission> overlapping = bedAdmissionRepository.findOverlappingBedBookings(
            1, LocalDate.of(2026, 2, 1), LocalDate.of(2026, 2, 10));

        assertTrue(overlapping.isEmpty());
    }

    @Test
    void noOverlapForADifferentBed() {
        seedActiveBooking();

        List<BedAdmission> overlapping = bedAdmissionRepository.findOverlappingBedBookings(
            2, LocalDate.of(2026, 1, 5), LocalDate.of(2026, 1, 15));

        assertTrue(overlapping.isEmpty());
    }
}
