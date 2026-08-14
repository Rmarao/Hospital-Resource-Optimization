package com.hospital.repository;

import com.hospital.model.AppointmentRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AppointmentRequestRepository extends JpaRepository<AppointmentRequest, Long> {
    List<AppointmentRequest> findByPatientIdOrderByCreatedAtDesc(Long patientId);
    List<AppointmentRequest> findByDoctorIdOrderByCreatedAtDesc(Long doctorId);
    List<AppointmentRequest> findByDoctorIdAndStatusOrderByCreatedAtDesc(Long doctorId, String status);
}
