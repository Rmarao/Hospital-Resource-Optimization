package com.hospital.repository;

import com.hospital.model.DoctorAvailability;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface DoctorAvailabilityRepository extends JpaRepository<DoctorAvailability, Long> {
    List<DoctorAvailability> findByDoctorId(Long doctorId);
    Optional<DoctorAvailability> findByDoctorIdAndDayOfWeek(Long doctorId, String dayOfWeek);
    List<DoctorAvailability> findByDayOfWeek(String dayOfWeek);
}
