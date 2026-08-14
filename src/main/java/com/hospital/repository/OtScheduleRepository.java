package com.hospital.repository;

import com.hospital.model.OtSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface OtScheduleRepository extends JpaRepository<OtSchedule, Integer> {
    List<OtSchedule> findByDoctorId(Long doctorId);
    List<OtSchedule> findByPatientId(Long patientId);
    List<OtSchedule> findByScheduleDate(LocalDate date);
    List<OtSchedule> findByOtIdAndScheduleDate(Integer otId, LocalDate date);
    List<OtSchedule> findByStatus(String status);
    List<OtSchedule> findByPatientIdInAndStatus(List<Long> patientIds, String status);

    // ✅ Check for OT time conflicts
    @Query("SELECT o FROM OtSchedule o WHERE o.otId = :otId " +
           "AND o.scheduleDate = :date " +
           "AND o.status = 'SCHEDULED' " +
           "AND o.startTime < :endTime " +
           "AND o.endTime > :startTime")
    List<OtSchedule> findConflictingSchedules(
        @Param("otId") Integer otId,
        @Param("date") LocalDate date,
        @Param("startTime") LocalTime startTime,
        @Param("endTime") LocalTime endTime
    );

    // ✅ Check for doctor time conflicts
    @Query("SELECT o FROM OtSchedule o WHERE o.doctorId = :doctorId " +
           "AND o.scheduleDate = :date " +
           "AND o.status = 'SCHEDULED' " +
           "AND o.startTime < :endTime " +
           "AND o.endTime > :startTime")
    List<OtSchedule> findDoctorConflicts(
        @Param("doctorId") Long doctorId,
        @Param("date") LocalDate date,
        @Param("startTime") LocalTime startTime,
        @Param("endTime") LocalTime endTime
    );
}