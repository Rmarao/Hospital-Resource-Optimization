package com.hospital.repository;

import com.hospital.model.DoctorPatient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DoctorPatientRepository extends JpaRepository<DoctorPatient, Integer> {
    List<DoctorPatient> findByDoctorId(Long doctorId);
    List<DoctorPatient> findByPatientId(Long patientId);
    DoctorPatient findByPatientIdAndStatus(Long patientId, String status);
    boolean existsByDoctorIdAndPatientIdAndStatus(Long doctorId, Long patientId, String status);
}