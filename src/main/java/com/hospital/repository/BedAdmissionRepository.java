package com.hospital.repository;

import com.hospital.model.BedAdmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface BedAdmissionRepository extends JpaRepository<BedAdmission, Integer> {
    List<BedAdmission> findByPatientId(Long patientId);
    List<BedAdmission> findByDoctorId(Long doctorId);
    List<BedAdmission> findByStatus(String status);
    BedAdmission findByBedIdAndStatus(Integer bedId, String status);
 // Check if bed is already booked during the requested date range
    @Query("SELECT b FROM BedAdmission b WHERE b.bedId = :bedId " +
           "AND b.status = 'ACTIVE' " +
           "AND b.admittedDate < :dischargeDate " +
           "AND b.dischargeDate > :admittedDate")
    List<BedAdmission> findOverlappingBedBookings(
        @Param("bedId") Integer bedId,
        @Param("admittedDate") LocalDate admittedDate,
        @Param("dischargeDate") LocalDate dischargeDate
    );
}